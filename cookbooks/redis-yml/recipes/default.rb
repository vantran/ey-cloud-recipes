if ['app_master', 'app', 'solo', 'util'].include?(node[:instance_role])

  # If you have only one utility instance uncomment the line below
  # redis_instance = node['utility_instances'].first
  # Otherwise, if you have multiple utility instances you can specify it by uncommenting the line below
  # You can change the name of the instance based on whatever name you have chosen for your instance.
  redis_instance = node['utility_instances'].find { |instance| instance['name'] == 'redis' }
  utility_instance = node['utility_instances'].find { |instance| instance['name'] == 'utility' }

  hash = {
    environment: node[:environment][:framework_env]
  }

  hash.merge!({redis: redis_instance[:hostname]}) if redis_instance
  hash.merge!({utility: utility_instance[:hostname]}) if utility_instance

  node[:applications].each do |app, data|
    template "/data/#{app}/shared/config/redis.yml"do
      source 'redis.yml.erb'
      owner node[:owner_name]
      group node[:owner_name]
      mode 0655
      backup 0
      variables(hash)
    end
  end
end
