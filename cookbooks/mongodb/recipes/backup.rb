#
# Cookbook Name:: mongodb
# Recipe:: backup
#

ey_cloud_report "mongodb" do
  message "configuring backup"
end

# mongo_nodes = node[:utility_instances].select { |instance| instance[:name].match(/^mongodb_repl#{node[:mongo_replset]}/) }
mongo_nodes = node[:utility_instances].select { |instance| instance[:name].match(/^mongodb/) }

if node[:name] == mongo_nodes.last[:name]
  app_name = "lixibox"
  user = node[:users].first
  db_name = "#{app_name}_#{node[:environment][:framework_env]}"

  template "/usr/local/bin/mongo-backup" do
    source "mongo-backup.rb.erb"
    owner "root"
    group "root"
    mode 0700
    variables({
        :username => 'root',
        :password => user[:password],
        :database => db_name,
        :secret_key => node[:aws_secret_key],
        :id_key => node[:aws_secret_id],
        :env => node[:environment][:name],
        :app_name => app_name
      })
  end

  if node[:environment][:framework_env] == 'production'
    cron "#{app_name}-mongo-backup" do
      hour "1"
      minute "30"
      command "/usr/local/bin/mongo-backup"
    end
  end
else
  cron "mongo-backup" do
    action :delete
  end
end

