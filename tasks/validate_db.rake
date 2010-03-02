namespace :db do
  desc "Validate all models in the database"
  task :validate => :environment do
    ActiveRecord::Validate.all
  end

  namespace :validate do
    desc "Purge all invalid models form the database"
    task :purge => :environment do
      ActiveRecord::Validate.purge
    end
  end

end
