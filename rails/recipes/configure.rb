include_recipe "deploy"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

ruby_v = "#{node[:opsworks][:ruby_version]}"
if node[:ruby][:patch_version]
  ruby_v = "#{ruby_v}.#{node[:ruby][:patch_version]}"
end

rbenv_ruby "#{ruby_v}"
rbenv_gem "bundler" do
  ruby_version "#{ruby_v}"
end

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
  deploy = node[:deploy][application]

  case node[:deploy][application][:database][:adapter]
  when /mysql/
    include_recipe "mysql::client_install"
  when "postgresql"
    include_recipe "opsworks_postgresql::client_install"
  end

  log_dir = "#{deploy[:deploy_to]}/shared/log"
  group_name = 'root'

  directory log_dir do
    owner "#{deploy[:user]}"
    group group_name
    mode  '0666'
    recursive true
  end

  #creating file for bug of /root/.ruby-uuid not created
  file "/tmp/ruby-uuid" do
    group 'root'
    owner "#{deploy[:user]}"
    mode   "0666"
    action :create_if_missing
  end

  file "/tmp/.ruby-uuid" do
    group 'root'
    owner "#{deploy[:user]}"
    mode   "0666"
    action :create_if_missing
  end

  execute "sudo chown -R #{deploy[:user]} #{deploy[:deploy_to]}" do
  end



end
