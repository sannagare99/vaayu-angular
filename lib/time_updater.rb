module TimeUpdater
  # Apply hours and time from new_time to changed_time
  # I.e. changed_time = 2012-02-19 17:19:00 +0300
  # new_time = 2016-10-25 19:00:36 +0300
  # the result will be 2012-02-19 19:00:00 +0300
  def change_time(changed_time, new_time)
    changed_time.change hour: new_time.hour, min: new_time.min, sec: 0
  end
end