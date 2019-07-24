class ShiftTime < ApplicationRecord
  enum shift_type: [:check_in, :check_out]
  attr_accessor :check_in, :check_out

  def check_in_formatted
    self.check_in.in_time_zone(Time.zone).strftime('%H:%M') if self.check_in
  end

  def check_out_formatted
    self.check_out.in_time_zone(Time.zone).strftime('%H:%M') if self.check_out
  end

  def self.fetch_checkin_and_checkout(check_in_attr, check_out_attr)
    check_in_date = Time.zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
    check_out_date = Time.zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
    check_out_date += 1.day unless check_in_date < check_out_date
    [check_in_date, check_out_date]
  end

  def self.check_in_check_out_is_invalid(check_in_attr, check_out_attr)
    begin
      check_in_date = Time.zone.parse("#{check_in_attr[:schedule_date]} #{check_in_attr[:check_in]}")
      check_out_date = Time.zone.parse("#{check_out_attr[:schedule_date]} #{check_out_attr[:check_out]}")
      return false
    rescue ArgumentError => re
      return true
    end
  end

  def self.create_or_update(klass, attributes, shift_manager)
    attributes[:check_in_attributes].values.sort_by { |x| x["schedule_date"] }.each_with_index do |check_in_attr, i|
      check_out_attr = attributes[:check_out_attributes].values.sort_by { |x| x["schedule_date"] }[i].merge(shift_manager_id: shift_manager.id)
      check_in_attr = check_in_attr.merge(shift_manager_id: shift_manager.id)
      next if (check_in_attr[:id].blank? && check_in_attr[:check_in].blank?) || (check_out_attr[:id].blank? && check_out_attr[:check_out].blank?)
      next if check_in_check_out_is_invalid(check_in_attr, check_out_attr)

      if check_in_attr[:id].present?
        if check_in_attr[:check_in].blank? || check_out_attr[:check_out].blank?
          st = klass.where("id in (?)", [check_in_attr[:id], check_out_attr[:id]])
          st.destroy_all
        else
          dates = fetch_checkin_and_checkout(check_in_attr, check_out_attr)
          update_shift_time([check_in_attr, check_out_attr], dates, klass)
        end
      else
        dates = fetch_checkin_and_checkout(check_in_attr, check_out_attr)
        create_shift_time([check_in_attr, check_out_attr], dates, klass)
      end
    end
  end

  def self.create_shift_time(attributes, dates, klass)
    attrs = []
    attributes.first.merge({site_id: attributes.last[:site_id]}) if attributes.last[:id].present?
    attributes.select { |et| et[:id].blank? }.each_with_index { |et_attr, i| attrs << et_attr.slice("site_id", "shift_manager_id").merge({date: dates[i], shift_type: i, schedule_date: Time.zone.parse("#{et_attr['schedule_date']} 10:00:00")}) if et_attr.present? }
    klass.create(attrs)
    update_shift_time([{}, attributes.last], [{}, dates.last]) if attributes.last[:id].present?
  end

  def self.update_shift_time(attributes, dates, klass)
    attributes.each_with_index do |st_attr, i|
      next if st_attr.blank?
      if st_attr["id"].present?
        st = klass.find(st_attr["id"])
        st.update_attributes(st_attr.slice("site_id").merge({date: dates[i], shift_type: i, schedule_date: Time.zone.parse("#{st_attr['schedule_date']} 10:00:00")}))
      else
        create_shift_time([{}, st_attr], ["", dates[i]])
      end
    end
  end
end
