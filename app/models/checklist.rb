class Checklist < ApplicationRecord
  enum status: [:active, :completed]

  belongs_to :driver
  belongs_to :vehicle
  has_many :checklist_items, dependent: :destroy

  def self.create_checklist(driver=nil, vehicle=nil)
    return if driver.blank? and vehicle.blank?
    obj = driver.present? ? Driver.find_by_id(driver) : Vehicle.find_by_id(vehicle)
    return if obj.nil?
    return if obj.checklists.active.present?
    checklist = Checklist.new({ obj.class.name.downcase + "_id" => obj.id })
    compliances = driver.present? ? Compliance.driver : Compliance.vehicle
    checklist.checklist_items.build(compliances.map { |x| {checklist_id: checklist.id, key: x.key, compliance_type: x.compliance_type} })
    checklist.save
  end

  def update_checklist_items(checklist_item_params)
    checklist_item_params.each do |k, v|
      item = checklist_items.select { |x| x.to_id == k }.first
      next if item.nil?
      item.update(value: v)
    end
  end 
end
