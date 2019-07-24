# IMPORTANT
# For large seed data, add a sql dump file named 'large.sql' inside dump folder
#

config   = Rails.configuration.database_configuration
host     = config[Rails.env]['host'] || 'localhost'
database = config[Rails.env]['database'] || 'moove_test'
username = config[Rails.env]['username'] || 'root'
password = config[Rails.env]['password']
port = config[Rails.env]["port"]
dump = File.dirname(__FILE__) + '/dump/large.sql'
if File.exist?(dump)
	if password
		system("mysql -u #{username} -p#{password} -h #{host} -P #{port} #{database} < #{dump}")
	else
		system("mysql -u #{username} -h #{host} -P #{port} #{database} < #{dump}")
	end

	# NOTE: Uncomment the below lines if using the dump without users

	# ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS users")
	# ActiveRecord::Base.connection.execute("CREATE TABLE users (
	#   id int(11) NOT NULL AUTO_INCREMENT,
	#   email varchar(255) NOT NULL DEFAULT '',
	#   username varchar(255) DEFAULT NULL,
	#   f_name varchar(255) DEFAULT NULL,
	#   m_name varchar(255) DEFAULT NULL,
	#   l_name varchar(255) DEFAULT NULL,
	#   role int(11) DEFAULT '0',
	#   entity_type varchar(255) DEFAULT NULL,
	#   entity_id int(11) DEFAULT NULL,
	#   phone varchar(255) DEFAULT NULL,
	#   encrypted_password varchar(255) NOT NULL DEFAULT '',
	#   reset_password_token varchar(255) DEFAULT NULL,
	#   reset_password_sent_at datetime DEFAULT NULL,
	#   remember_created_at datetime DEFAULT NULL,
	#   sign_in_count int(11) NOT NULL DEFAULT '0',
	#   current_sign_in_at datetime DEFAULT NULL,
	#   last_sign_in_at datetime DEFAULT NULL,
	#   current_sign_in_ip varchar(255) DEFAULT NULL,
	#   last_sign_in_ip varchar(255) DEFAULT NULL,
	#   created_at datetime NOT NULL,
	#   updated_at datetime NOT NULL,
	#   tokens text,
	#   provider varchar(255) NOT NULL DEFAULT 'email',
	#   uid varchar(255) NOT NULL DEFAULT '',
	#   avatar_file_name varchar(255) DEFAULT NULL,
	#   avatar_content_type varchar(255) DEFAULT NULL,
	#   avatar_file_size int(11) DEFAULT NULL,
	#   avatar_updated_at datetime DEFAULT NULL,
	#   last_active_time datetime DEFAULT '2009-01-01 00:00:00',
	#   status int(11) DEFAULT NULL,
	#   passcode varchar(255) DEFAULT NULL,
	#   invite_count int(11) DEFAULT '0',
	#   current_location text,
	#   PRIMARY KEY (id),
	#   UNIQUE KEY index_users_on_email (email),
	#   UNIQUE KEY index_users_on_username (username),
	#   UNIQUE KEY index_users_on_phone (phone),
	#   UNIQUE KEY index_users_on_reset_password_token (reset_password_token),
	#   KEY index_users_on_entity_type_and_entity_id (entity_type,entity_id)
	# ) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8")
	# ActiveRecord::Base.connection.execute("INSERT INTO users (f_name, l_name, username, phone, email, role, entity_id, entity_type, created_at, updated_at) values ('#{Faker::Name.first_name}', '#{Faker::Name.last_name}', 'user1', '#{Faker::PhoneNumber.cell_phone}', '#user1@n3wnormal.com', 0, '#{Employee.first.id}', 'Employee', '2017-12-04 18:24:41', '2017-12-04 18:24:41')")
	# ActiveRecord::Base.connection.execute("INSERT INTO users (f_name, l_name, username, phone, email, role, entity_id, entity_type, created_at, updated_at) values ('#{Faker::Name.first_name}', '#{Faker::Name.last_name}', 'user2', '#{Faker::PhoneNumber.cell_phone}', '#user2@n3wnormal.com', 1, '#{Employer.first.id}', 'Employer', '2017-12-04 18:24:41', '2017-12-04 18:24:41')")
	# ActiveRecord::Base.connection.execute("INSERT INTO users (f_name, l_name, username, phone, email, role, entity_id, entity_type, created_at, updated_at) values ('#{Faker::Name.first_name}', '#{Faker::Name.last_name}', 'user3', '#{Faker::PhoneNumber.cell_phone}', '#user3@n3wnormal.com', 2, '#{Operator.first.id}', 'Operator', '2017-12-04 18:24:41', '2017-12-04 18:24:41')")
	# ActiveRecord::Base.connection.execute("INSERT INTO users (f_name, l_name, username, phone, email, role, entity_id, entity_type, created_at, updated_at) values ('#{Faker::Name.first_name}', '#{Faker::Name.last_name}', 'user4', '#{Faker::PhoneNumber.cell_phone}', '#user4@n3wnormal.com', 3, '#{Driver.first.id}', 'Driver', '2017-12-04 18:24:41', '2017-12-04 18:24:41')")

	User.all.each{|u| u.update(password: 'password')}
else
	#load small seed as backup
	dump = File.dirname(__FILE__) + '/small.rb'
	load(dump) if File.exist?(dump)
end