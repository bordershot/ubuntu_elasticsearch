#
# Cookbook Name:: ubuntu_elasticsearch
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_repository 'elastic' do
  uri 'https://packages.elastic.co/elasticsearch/2.x/debian'
  distribution ''
  components ['stable', 'main']
  key 'https://packages.elastic.co/GPG-KEY-elasticsearch'
  cache_rebuild false
end

apt_repository 'logstash' do
  uri 'https://packages.elastic.co/logstash/2.4/debian'
  distribution ''
  components ['stable', 'main']
  cache_rebuild false
end

apt_repository 'kibana' do
  uri 'https://packages.elastic.co/kibana/4.6/debian'
  distribution ''
  components ['stable', 'main']
  cache_rebuild false
end

apt_repository 'curator' do
  uri 'https://packages.elastic.co/curator/4/debian'
  distribution ''
  components ['stable', 'main']
end

apt_repository 'oracle' do
  uri          'http://ppa.launchpad.net/webupd8team/java/ubuntu'
  distribution 'xenial'
  components   ['main']
  key          'EEA14886'
end

bash 'accept java license' do
  code <<-EOH
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
  export SKIP_IPLIKE_INSTALL=1
  apt-get -q -y install oracle-java8-installer
  EOH
end

package ['elasticsearch', 'logstash', 'kibana', 'elasticsearch-curator']

service 'elasticsearch' do
  action [ :enable, :start ]
end

service 'logstash' do
  action [ :enable, :start ]
end

service 'kibana' do
  action [ :enable, :start ]
end

directory '/root/.curator' do
  action :create
end

cookbook_file '/root/.curator/curator.yml' do
  source 'curator.yml'
end

template '/root/expire_indices.yml' do
  source 'expire_indices.yml.erb'
end

cron 'curator_expire_indices' do
  command '/usr/bin/curator --config /root/.curator/curator.yml /root/expire_indices.yml'
  hour '1'
  minute '0'
end

#need to add a flag and setup kibana to listen only on 127.0.0.1
# use with nginx_https_proxy
#/opt/kibana/config/kibana.yml
#server.host: "127.0.0.1"
