if node[:utility_instances].empty?
  # no-op here as there are no utility instances, do not pass.
else
  user = node[:users].first
  mongo_app_name = "lixibox"

  #Mongoid.yml_v3
  template "/data/#{mongo_app_name}/shared/config/mongoid.yml" do
    source "mongoid_v3.yml.erb"
    owner user[:username]
    group user[:username]
    mode 0755

    hosts = node[:mongo_utility_instances].map { |instance| [ instance[:hostname], node[:mongo_port].to_i ] }
    variables(environment: node[:environment][:framework_env],
              hosts: hosts,
              database: "#{mongo_app_name}_#{node[:environment][:framework_env]}" )
  end
end
