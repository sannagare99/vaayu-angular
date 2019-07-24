namespace :tests do
  desc 'Calculate test coverage'
  task coverage: :environment do
    sh 'rm -Rf coverage'
    test_failed = false
    begin
      sh 'bundle exec rspec'
    rescue => e1
      test_failed = true
    ensure
      begin
        sh 'bundle exec cucumber'
      rescue => e2
	 test_failed = true
      end
    end
    
    if test_failed
      fail "[FAILED]"
    else
      puts "[OK]"
    end
  end

  desc 'Run performace tests'
  task :performance, [:database_size, :host_name, :threads, :rampup, :loop_count] => :environment do |t, args|
      if (ENV['RAILS_ENV'] == "test")
        system("rm -rf #{Rails.root}/jmeter/logs/*.log")
        system("rm -rf #{Rails.root}/jmeter/jmx_files/*.jmx")
        system("rm -rf #{Rails.root}/jmeter/results/*.jtl")
        host_name = args.host_name || 'http://localhost:3000'
        threads = (args.threads || 1).to_i
        rampup = (args.rampup || 1).to_i
        loop_count = (args.rampup || 1).to_i
        database_size = args.database_size || 'large'
        Rake::Task["tests:seed:#{database_size}"].invoke
        files = Dir["#{Rails.root}/jmeter/tests/*.rb"]
        files.each do |file|
          ruby "#{file} #{host_name} #{threads} #{rampup} #{loop_count}"
        end
        Rake::Task["tests:reset_db"].invoke
        Rake::Task["tests:evaluate_performance_result"].invoke
      else
        system("RAILS_ENV=test bundle exec rake tests:performance")
      end
  end

  task evaluate_performance_result: :environment do
    files = Dir["#{Rails.root}/jmeter/results/*.jtl"]
    total = 0
    success = 0
    failure = 0
    failure_array = []
    files.each do |file|
      csv_data = CSV.read(file, headers: true)
      csv_data.each_with_index do |row, i|
        total += 1
        sucessCode = row.fetch('responseCode')
        if (sucessCode.to_i / 100 == 2)
          success += 1
        else
          failure += 1
          failure_array << "#{file}: #{i} -- #{row.fetch('label')}"
        end
      end
    end
    puts '-------------------- Test Results --------------------'
    puts 'Total: ', total
    puts 'Success: ', success
    puts 'Failure: ', failure
    if failure > 0
      puts '-------------------- Failures --------------------'
      puts failure_array
    end
    puts '-------------------- End of Test Results --------------------'
  end

  namespace :seed do
    Dir[Rails.root.join('jmeter', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb')
      task task_name.to_sym => :environment do
        if (ENV['RAILS_ENV'] == "test")
          load(filename) if File.exist?(filename)
        end
      end
    end
  end

  task reset_db: :environment do
    if (ENV['RAILS_ENV'] == "test")
      system("RAILS_ENV=test DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop")
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
    else
      system("RAILS_ENV=test bundle exec rake tests:reset_db")
    end
  end
end
