class EmployeeClustersController < ApplicationController
  def index
  end

  def decluster
    employee_clusters = EmployeeCluster.where(id: params['ids'])
    employee_clusters.each do |ec|
      if ec.employee_trips.first.bus_rider?
        ec.employee_trips.update(is_clustered: false, employee_cluster: nil)
        ec.destroy
      else
        # if ENV['CLUSTER_ALGORITHM'] == 'historical'
        #   ec.employee_trips.update(is_clustered: false)
        # elsif ENV['CLUSTER_ALGORITHM'] == 'clustering_service'
        ec.employee_trips.update(is_clustered: false, employee_cluster: nil)
        ec.destroy
        # end
      end
    end
    render json: {success: true}
  end
end
