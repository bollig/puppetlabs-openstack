#
# Copyright (C) 2016 Evan Bollig and Regents of the University of Minnestoa
#
# Author: Evan Bollig <bollig@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Class to serve Neutron API and EC2 with apache mod_wsgi in place of
# glance-api services. Based on the nova::wsgi::apache.pp from puppetlabs-nova
# (master branch; 6/2016)
#
# Serving Neutron API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses.
#
# When using this class you should disable your glance-api service.
#
# == Parameters
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $::fqdn
#
#   [*api_port*]
#     The port for Neutron API service.
#     Optional. Defaults to 9292
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*path*]
#     The prefix for the endpoint.
#     Optional. Defaults to '/'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to 1
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to $::processorcount
#
#   [*ssl_cert*]
#   [*ssl_key*]
#   [*ssl_chain*]
#   [*ssl_ca*]
#   [*ssl_crl_path*]
#   [*ssl_crl*]
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
# == Dependencies
#
#   requires Class['apache'] & Class['glance'] & Class['glance::api']
#
# == Examples
#
#   include apache
#
#   class { 'glance::wsgi::apache': }
#
define openstack::profile::glance::wsgi_apache (
  $wsgi_service_name = 'glance-api',
  $servername    = $::fqdn,
  $api_port      = 9292,
  $bind_host     = undef,
  $path          = '/',
  $ssl           = true,
  $workers       = 1,
  $ssl_cert      = undef,
  $ssl_key       = undef,
  $ssl_chain     = undef,
  $ssl_ca        = undef,
  $ssl_crl_path  = undef,
  $ssl_crl       = undef,
  $ssl_certs_dir = undef,
  $threads       = $::processorcount,
  $priority      = '10',
) {
  $wsgi_service_alias = regsubst($wsgi_service_name, '-', '_', 'G')

  include ::glance::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  # NOTE: disabled because glance::api doesnt exist yet
  if ! defined(Class[::glance::api]) {
    fail('::glance::api class must be declared in composition layer.')
  }
  file { [ "/usr/lib/python2.7/site-packages/${wsgi_service_name}/" , "/usr/lib/python2.7/site-packages/${wsgi_service_name}/wsgi" ]:
	ensure => directory,
  } ->
  file { "/usr/lib/python2.7/site-packages/${wsgi_service_name}/wsgi/${wsgi_service_name}.py": 
	ensure => present,
	source => "puppet:///modules/openstack/${wsgi_service_name}_wsgi",
  } -> 
  ::openstacklib::wsgi::apache { "${wsgi_service_alias}_wsgi":
    bind_host           => $bind_host,
    bind_port           => $api_port,
    group               => 'glance',
    path                => $path,
    priority            => $priority,
    servername          => $servername,
    ssl                 => $ssl,
    ssl_ca              => $ssl_ca,
    ssl_cert            => $ssl_cert,
    ssl_certs_dir       => $ssl_certs_dir,
    ssl_chain           => $ssl_chain,
    ssl_crl             => $ssl_crl,
    ssl_crl_path        => $ssl_crl_path,
    ssl_key             => $ssl_key,
    threads             => $threads,
    user                => 'glance',
    workers             => $workers,
    wsgi_daemon_process => $wsgi_service_name,
    wsgi_process_group  => $wsgi_service_name,
    wsgi_script_dir     => '/var/www/cgi-bin/glance',
    wsgi_script_file    => $wsgi_service_name,
# NOTE: this file does not exist. 
    wsgi_script_source  => "/usr/lib/python2.7/site-packages/${wsgi_service_name}/wsgi/${wsgi_service_name}.py",
  }

}

