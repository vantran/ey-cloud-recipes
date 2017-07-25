#
# Cookbook Name:: nginx_cors_fix
# Recipe:: default
#
if ['app_master', 'app', 'solo'].include?(node[:instance_role])
  node[:applications].each do |app, data|

    template "/tmp/location.block" do
      source 'location.block.erb'
    end

    execute "reload-nginx" do
      action :nothing
      command "/etc/init.d/nginx reload"
    end

    execute "add header to conf" do
      command "sed -i '/error_log \\/var\\/log\\/engineyard\\/nginx\\/#{app}.error.log notice;/r /tmp/location.block' /etc/nginx/servers/#{app}.conf"
      not_if "grep -q Access-Control-Allow-Origin /etc/nginx/servers/#{app}.conf"
    end

    execute "add header to ssl conf" do
      command "sed -i '/error_log \\/var\\/log\\/engineyard\\/nginx\\/#{app}.error.log notice;/r /tmp/location.block' /etc/nginx/servers/#{app}.ssl.conf;"
      not_if "grep -q Access-Control-Allow-Origin /etc/nginx/servers/#{app}.ssl.conf"
      notifies :run, resources(:execute => "reload-nginx")
    end

  end
end
