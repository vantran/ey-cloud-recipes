#
# Cookbook Name:: phantomjs
# Recipe:: default
#
#

folder_name = "phantomjs-1.9.2-linux-x86_64"
file_name = "#{folder_name}.tar.bz2"
url = "https://phantomjs.googlecode.com/files/#{file_name}"

if ['solo','app_master','app','util'].include?(node[:instance_role])
  remote_file "/tmp/#{file_name}" do
    source url
    mode "0644"
    not_if { File.exists? "/tmp/#{file_name}" }
  end

  bash "unzip phantomjs" do
    user "root"
    cwd "/tmp"
    code %(tar xvfj /tmp/#{file_name})
    not_if { File.exists? "/tmp/#{folder_name}" }
  end

  bash "copy phantomjs" do
    user "root"
    cwd "/tmp"
    code %(cp -r /tmp/#{folder_name}/bin/phantomjs /usr/local/bin/phantomjs)
    not_if { File.exists? "/usr/local/bin/phantomjs" }
  end
end