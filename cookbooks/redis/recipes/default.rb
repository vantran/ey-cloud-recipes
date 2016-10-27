#
# Cookbook Name:: redis
# Recipe:: default
#

if ['util'].include?(node[:instance_role])
  if node[:name] == 'utility' || node[:name] == 'redis'

    sysctl "Enable Overcommit Memory" do
      variables 'vm.overcommit_memory' => 1
    end

    enable_package "dev-db/redis" do
      version node[:redis][:version]
      override_hardmask true
      unmask :true
    end

    package "dev-db/redis" do
      version node[:redis][:version]
      action :upgrade
    end

    directory "#{node[:redis][:basedir]}" do
      owner 'redis'
      group 'redis'
      mode 0755
      recursive true
      action :create
    end

    conf_source = if node[:name] == "utility"
      "redis_util.conf.erb"
    else
      "redis.conf.erb"
    end

    template "/etc/redis_util.conf" do
      owner 'root'
      group 'root'
      mode 0644
      source conf_source
      variables({
        :pidfile => node[:redis][:pidfile],
        :basedir => node[:redis][:basedir],
        :basename => node[:redis][:basename],
        :logfile => node[:redis][:logfile],
        :loglevel => node[:redis][:loglevel],
        :port  => node[:redis][:bindport],
        :unixsocket => node[:redis][:unixsocket],
        :saveperiod => node[:redis][:saveperiod],
        :timeout => node[:redis][:timeout],
        :databases => node[:redis][:databases],
        :rdbcompression => node[:redis][:rdbcompression],
        :hz => node[:redis][:hz]
      })
    end
    
    # redis-server is in /usr/bin on stable-v2, /usr/sbin for stable-v4
    if Chef::VERSION[/^0.6/]
      bin_path = "/usr/bin/redis-server"
    else
      bin_path = "/usr/sbin/redis-server"
    end  

    template "/data/monit.d/redis_util.monitrc" do
      owner 'root'
      group 'root'
      mode 0644
      source "redis.monitrc.erb"
      variables({
        :profile => '1',
        :configfile => '/etc/redis_util.conf',
        :pidfile => node[:redis][:pidfile],
        :logfile => node[:redis][:basename],
        :port => node[:redis][:bindport],
        :bin_path => bin_path
      })
    end

    execute "monit reload" do
      action :run
    end
  end
end

# for all server, add hosts mapping for redis & utility
if ['solo', 'app', 'app_master', 'util'].include?(node[:instance_role])
  instances = node[:engineyard][:environment][:instances]

  ["redis", "utility"].each do |server_name|
    redis_instance = if node[:instance_role][/solo/] && instances.length == 1
      instances[0]
    else
      instances.find{|i| i[:name] == server_name}
    end

    if redis_instance
      ip_address = `ping -c 1 #{redis_instance[:private_hostname]} | awk 'NR==1{gsub(/\\(|\\)/,"",$3); print $3}'`.chomp
      host_mapping = "#{ip_address} #{server_name}_instance"

      execute "Remove existing redis_instance mapping from /etc/hosts" do
        command "sudo sed -i '/#{server_name}_instance/d' /etc/hosts"
        action :run
      end

      execute "Add #{server_name}_instance mapping to /etc/hosts" do
        command "sudo echo #{host_mapping} >> /etc/hosts"
        action :run
      end
    end
  end
end
