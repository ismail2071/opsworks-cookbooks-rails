puts "Inflating template mongoid.yml.erb"
template "#{deploy[:deploy_to]}/shared/config/mongoid.yml" do
  source "mongoid.yml.erb"
  cookbook "rails"
  group 'root'
  owner "#{node[:deploy][:user]}"
  mode   "0755"
end