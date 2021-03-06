require 'date'
require 'time'

backup_location  = ARGV[0]
environment      = ARGV[1]
databases        = ARGV[2].split(',')
db_pass          = ARGV[3]
db_user          = ARGV[4]
mode             = ARGV[5]
output           = []
timestamp_dirs   = []
check_dirs       = []
target_dir       = ""
backup_dir_count = 0

start_time = Time.now

schema_commands = [
  "DROP SCHEMA public CASCADE;",
  "CREATE SCHEMA public;",
  "GRANT ALL ON SCHEMA public TO postgres;",
  "GRANT ALL ON SCHEMA public TO public;"
]

Dir.foreach("#{ backup_location }/main_backup") do |timestamp_dir|
  next if timestamp_dir == '.' || timestamp_dir == '..'

  timestamp_dirs << timestamp_dir
end

timestamp_dirs.each do |dir|
  if check_dirs.empty?
    check_dirs << dir
    target_dir  = dir
  else
    check_dirs.each do |cdir|
      target_dir = dir if Date.parse(dir) >= Date.parse(target_dir)
    end
  end
end

puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Starting backup unpacking"

puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Starting tar extraction for #{ backup_location }/main_backup/#{ target_dir }/main_backup.tar"

`tar -xvf #{ backup_location }/main_backup/#{ target_dir }/main_backup.tar -C #{ backup_location }/main_backup/#{ target_dir }`

sleep 30

Dir.foreach("#{ backup_location }/main_backup/#{ target_dir }/main_backup/databases") do |gzipped_file|
  next if gzipped_file == '.' || gzipped_file == '..'

  target_database = ""

  databases.each do |database|
    target_database = database.strip if gzipped_file.include?(database.split('-').first.strip)
  end

  next if target_database == ''

  if mode =~ /postgresql/
    puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Starting schema removal for #{ target_database }"
    schema_commands.each do |cmnd|
      puts `su - postgres -c "psql #{ target_database }_#{ environment } -c '#{ cmnd }'"`
    end
  end

  (0..10).each do |tries|
    puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Checking if #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.gz','') } exists..."

    check = File.exist?("#{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.gz','') }")

    puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Checking if #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.gz','') }'s state is #{ check }"

    break if check

    sleep 60
  end

  puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Starting restore for #{ target_database }_#{ environment }"

  case mode
  when 'postgresql'
    `PGPASSWORD=#{ db_pass } pg_restore --verbose --no-acl --no-owner -j 4 -h localhost -U #{ db_user } -d #{ target_database }_#{ environment } #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.tar','') }`

    puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Starting VACUUM ANALYZE for #{ target_database }"
    puts `su - postgres -c "psql #{ target_database }_#{ environment } -c 'VACUUM VERBOSE ANALYZE;'"`
  when 'mongodb'
    puts "Unpacking #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file }"
    puts `tar -xvf #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file } -C #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases`

    puts "Restoring #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.tar','') }/#{ target_database }"

    puts `mongorestore --dbpath /mnt/mongo/mongodb --username #{ db_user } --password #{ db_pass } --db #{ target_database } --drop #{ backup_location }/main_backup/#{ target_dir }/main_backup/databases/#{ gzipped_file.gsub('.tar','') }/#{ target_database }`
  end
end

`rm -rf #{ backup_location }/main_backup/#{ target_dir }/main_backup`

#cleanup possible extra dirs
#Dir.foreach("#{ backup_location }/main_backup") do |timestamp_dir|
#  next if timestamp_dir == '.' || timestamp_dir == '..'

#  `rm -rf #{ backup_location }/main_backup/#{ timestamp_dir }` if timestamp_dir != target_dir
#end

puts "[#{ Time.now.strftime('%Y-%m-%d %l:%M:%S %P') }] Done in #{ Time.now - start_time } seconds."
