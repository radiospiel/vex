module ActiveRecord::MysqlBackup
  def purge
    config = instance_variable_get("@config").easy_access

    recreate_database(config.database)  
  end
  
  def sqldump(file)
    config = instance_variable_get("@config").easy_access
    
    cmd_opts = ""
    cmd_opts << "-h #{config.host} " if config.host?
    cmd_opts << "-u #{config.username} " if config.username?
    cmd_opts += "-p#{config.password} " if config.password?

    cmd = "mysqldump #{cmd_opts} #{config.database} > #{file}"
    STDERR.puts cmd
    `#{cmd}`
  end
end

