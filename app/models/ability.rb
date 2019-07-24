class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    alias_action :create, :read, :update, :destroy, :to => :crud

    case user.role.to_s
      when 'admin'
        can :manage, :all
      when 'operator'
        [:provisioning_tab, :trips_tab, :billing_tab, :reports_tab, :dashboard_tab, :configurators_tab].each { |page| can :view, page }
        [:people_tab, :places_tab, :things_tab].each { |page| can :view, page }
        can :crud, User do |usr|
          # employee_companies = current_user.entity&.logistics_company.employee_companies
        end
        can :update, Site
        can :crud, Driver
        can :read, :operator_shift_manager
        can :show, :reports
        can :view, :all_reports
        can :manage, Configurator
        can :manage, OperatorShiftManager do |esm|
          user == esm.user
        end
      when 'employer'
        [:provisioning_tab, :trips_tab, :billing_tab, :reports_tab, :dashboard_tab, :configurators_tab].each { |page| can :view, page }
        [:people_tab, :places_tab, :things_tab].each { |page| can :view, page }
        can :create, Employee
        can [:update, :destroy], Employee do |employee|
          user.entity.employee_company == employee.employee_company
        end
        can :manage, :guard
        can :manage, EmployerShiftManager
        can :show, :reports
        can :view, :all_reports
        can :manage, Configurator
      when 'line_manager'
        [:provisioning_tab, :trips_tab].each { |page| can :view, page }
        [:people_tab, :places_tab].each { |page| can :view, page }
        can :create, Employee
        can [:update, :destroy], Employee, employee_company: user.entity.employee_company
        can :read, Employee, line_manager_id: user.entity.id
        can(:view, :trips_tab) if ENV["ENABLE_LINE_MANAGER_APPROVE"] == "true"
        can :view, :reports_tab
        can :show, :reports
        can :view, :send_report
        can :view, :download
        [:employee_logs, :employee_wise_no_show].each { |page| can :view, page }
        cannot :view, :billing_tab
        cannot :view, :dashboard_tab
      when 'driver', 'employee'
        [:provisioning_tab, :trips_tab, :billing_tab, :dashboard_tab].each { |page| can :view, page }
        can [:read, :edit], User do |usr|
          user == usr
        end

        can [:read, :edit], [ Employee, Driver ] do |usr|
          user == usr.user
        end

        can [:read, :edit], EmployeeTrip do |employee_trip|
          user == employee_trip.employee.user
        end

        can :read, Trip do |trip|
          trip.employees.include?(user.entity) || trip.driver == user.entity
        end

        can [ :start_trip, :driver_arrived, :on_board, :not_on_board ], Trip do |trip|
          trip.employees.include?(user.entity) || trip.driver == user.entity
        end

        can :send_trip_exception, TripRoute do |trip_route|
          user == trip_route.employee.user
        end

        can :request_trip, Employee
        can :manage_trip_request, Trip do |trip|
          user == trip.driver.user
        end

        can :edit, TripRouteException do |trip_route_exception|
          # only driver can close suspending exceptions, all other - for employee
          if trip_route_exception.suspending?
            user == trip_route_exception.trip_route.driver.try(:user)
          else
            user == trip_route_exception.trip_route.employee.try(:user)
          end
        end

        can :submit_employee_no_show, TripRoute do |trip_route|
          user == trip_route.trip.driver.user
        end
      when 'transport_desk_manager'
        can :create, Employee
        can [:update, :destroy], Employee do |employee|
          user.entity.employee_company == employee.employee_company
        end
        can :manage, :guard
        can :manage, EmployerShiftManager
        [:provisioning_tab, :trips_tab, :dashboard_tab].each { |page| can :view, page }
        can :view, :people_tab
        cannot :view, :billing_tab
        cannot :view, :reports_tab
      when 'employer_shift_manager'
        can :view, :provisioning_tab
        can :view, :trips_tab
        can :read, EmployerShiftManager
        can :manage, EmployerShiftManager do |esm|
          user == esm.user
        end
        can :view, :people_tab
        cannot :view, :billing_tab
        cannot :view, :reports_tab
      when 'operator_shift_manager'
        can :update, Site
        can :crud, Driver
        can :read, :operator_shift_manager
        can :manage, OperatorShiftManager do |esm|
          user == esm.user
        end
        [:provisioning_tab, :trips_tab, :billing_tab, :dashboard_tab].each { |page| can :view, page }
        [:people_tab, :places_tab, :things_tab].each { |page| can :view, page }
        cannot :view, :reports_tab
        cannot :read, Site
        cannot :read, Employer
        cannot :read, EmployeeCompany
    end


  end
end
