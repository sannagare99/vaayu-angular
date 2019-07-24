class ClusterVehicle < ApplicationRecord
  belongs_to :vehicle
  belongs_to :employee_cluster
end
