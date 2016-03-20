# == Class: jss
#
# Full description of class jss here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. 'Specify one or more upstream ntp servers as an array.'
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. 'The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames.' (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { jss:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class jss($firewall=true,
        $contexts=['production', 'testing', 'development'],
        $db_user='jss',
        $db_passwd='jsspw',
        $jss_addr='%',) {


  exec{'apt-update':
      command => '/usr/bin/apt-get update'
  }
  Exec['apt-update'] -> Package <| |>

  Exec{
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }
  package { 'tar':
    ensure => installed
  }
  package { 'unzip':
    ensure => installed
  }


  jss::context{'production':
    ensure   => present,
    firewall => true,
  }
  jss::db{'production':
    ensure    => present,
    firewall  => true,
    db_user   => 'produser',
    db_passwd => 'prodpw',
  }

  #class{ 'jss::jss':
  #  firewall => true,
  #  context  => $contexts,
  #  require  => [Package['tar'],
  #              Package['unzip'],
  #              Class['jss::db'],],
  #}
  #class{ 'jss::db':
  #  firewall  => $firewall,
  #  context   => 'production',
  #  db_user   => $db_user,
  #  db_passwd => $db_passwd,
  #  jss_addr  => $jss_addr,
  #}
}
