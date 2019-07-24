namespace :user do
  desc 'Set default active status to all users'
  task :set_default_active_state => [:environment] do
    User.update_all(status: 2)
  end

  desc 'Set offline phone for all users'
  task :set_default_active_state => [:environment] do
    @drivers = Driver.all
    @drivers.each do |driver|
    	driver.update!(offline_phone => driver.user.phone)
    end
  end


  desc 'Whitelist all user phones'
  task :whitelist_all_existing_users => [:environment] do
    @users = User.all

    @users.each do |user|
      params = {
        :VirtualNumber => ENV['EXOTEL_CALLER_ID'],
        :Number => user.phone
      }
      
      @response = HTTParty.post(URI.escape("https://#{ENV['EXOTEL_SID']}:#{ENV['EXOTEL_TOKEN']}@api.exotel.com/v1/Accounts/#{ENV['EXOTEL_SID']}/CustomerWhitelist"),
      {
        :query => params,
        :body => params
      })

      puts @response
    end
  end
end
