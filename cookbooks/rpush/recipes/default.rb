#
# Cookbook Name:: rpush
# Recipe:: default
#
if node[:name] == "utility"
  node[:applications].each do |app, data|
    template "/etc/monit.d/rpush_#{app}.monitrc" do
      owner 'root'
      group 'root'
      mode 0644
      source "rpush.monitrc.erb"
      variables({
        :app_name => app
      })
    end

    remote_file "/data/#{app}/shared/bin/rpush" do
      source "rpush"
      owner 'root'
      group 'root'
      mode 0755
      backup 0
    end
  end

  execute "ensure-rpush-is-setup-with-monit" do
    command %Q{
    monit reload
    }
  end
end
