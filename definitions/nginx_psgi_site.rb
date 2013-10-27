#
# Cookbook Name:: apache2
# Definition:: web_app
#
# Copyright 2008-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :nginx_psgi_site, :template => 'psgi_site.erb', :enable => true do

  application_name = params[:name]
  static_files_path = params[:static_files_path] 

  port = params[:port] || 80
  service_location = params[:service_location] || '/'
  uwsgi_socket = params[:uwsgi_socket] || node["appserver"]["uwsgi"]["socket"]
  uwsgi_socket.gsub!(/^(unix|tcp|udp)?(\:\/\/)?/,'')

  # nos aseguramos de que se incluan as recetas basicas
  include_recipe 'appserver_nginx::default'
  include_recipe 'appserver_uwsgi::psgi'


  template "#{node['nginx']['dir']}/sites-enabled/#{application_name}" do
    source   params[:template]
    owner    "root"
    group    "root"
    mode     '0644'
    cookbook params[:cookbook] || 'appserver_nginx'
    variables(
      :name              => application_name,
      :port              => port,
      :uwsgi_socket      => uwsgi_socket,
      :static_files_path => static_files_path,
      :service_location  => service_location
    )
    # if ::File.exists?("#{node['apache']['dir']}/sites-enabled/#{application_name}.conf")
    #   notifies :reload, 'service[apache2]'
    # end
  end

  site_enabled = params[:enable]
  nginx_site "#{params[:name]}" do
    enable site_enabled
  end
end
