namespace :tw do

  desc 'Sets $user_id via "user_id=1" option. checks to see it exists.'
  task :user_id => [:environment] do
    raise "You must specify a user_id like 'user_id=2'" unless ENV["user_id"]
    raise "User #{ENV['user_id']} doesn't exist." if !User.find(ENV["user_id"])
    $user_id = ENV["user_id"].to_i
  end

  desc 'Sets $project_id via "project_id=1" option. checks to see it exists.'
  task :project_id => [:environment] do
    raise "You must specify a project_id like 'project_id=1" unless ENV["project_id"]
    raise "Project #{ENV['project_id']} doesn't exist." if !Project.find(ENV["project_id"])
    $project_id = ENV["project_id"].to_i
  end

  desc 'Sets $table_name via "table_name=taxon_names" option.'
  task :table_name do
    raise "You must specify a table_name like 'table_name=collection_objects" unless ENV['table_name']
    $table_name = ENV['table_name']
  end

  desc 'Require both user_id and project_id.'
  task :with_user_and_project => [:environment, :user_id, :project_id] do
    raise "User is not a member of project." if !ProjectMember.where(project_id: $project_id, user_id: $user_id)
  end

  desc 'a default method to add a data_directory_argument'
  task  :data_directory do |t| 
    default = "#{ENV['HOME']}/src/sf/tmp/"
    @args ||= {} 
    puts "no data_directory passed, using default (#{default})" if ENV['data_directory'].blank?
    @args.merge!(data_directory: (ENV['data_directory'] || default ))
    raise "path (#{default}) not found" if !File.exists?(@args[:data_directory])
    @args
  end

  desc 'a default method to add a data_directory_argument'
  task  :database_role do |t| 
    @args ||= {}
    @args.merge!(database_role: (ENV['database_role'] || 'postgres'))
  end



end

