class Time
  def beginning_of_week_in_current_month
    (self - 1.week < self.beginning_of_month) ? self.beginning_of_month : self.beginning_of_week
  end

  def end_of_week_in_current_month
    (self + 1.week > self.end_of_month) ? self.end_of_month : self.end_of_week
  end
end