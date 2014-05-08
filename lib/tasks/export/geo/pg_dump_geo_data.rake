namespace :tw do
  namespace :export do
    namespace :geo do
    # rake tw:initialization:pg_dump_geo_data[../gaz/data/internal/dump/]
    desc 'Save geographic area information in native pg_dump compressed form.'
    task :pg_dump_geo_data, [:dump_to_path] => [:environment] do |t, args|
      database = ActiveRecord::Base.connection.database
      args.with_defaults(:dump_to_path => '/tmp/' )
      data_store = args[:dump_to_path]
      begin
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_area_types.dump"
        a = pg_dump(database, 'geographic_area_types', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_items.dump"
        b = pg_dump(database, 'geographic_items', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_areas.dump"
        c = pg_dump(database, 'geographic_areas', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}."
      rescue
        raise
      end
    end
    end   
  end
end
