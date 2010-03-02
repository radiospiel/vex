module ActiveRecord::MysqlBackup
  def purge
    config = instance_variable_get("@config").with_simple_access

    recreate_database(config.database)  
  end
  
  def sqldump(file)
    config = instance_variable_get("@config").with_simple_access
    
    cmd_opts = ""
    cmd_opts << "-h #{config.host} " if config.respond_to?(:host) && !config.host.blank?
    cmd_opts << "-u #{config.username} " if config.respond_to?(:username) && !config.username.blank?
    cmd_opts += "-p#{config.password} " if config.respond_to?(:password) && !config.password.blank?

    cmd = "mysqldump #{cmd_opts} #{config.database} > #{file}"
    STDERR.puts cmd
    `#{cmd}`
  end
end

