# == Class: tomcat
#
# Tomcat is an open-source web server and servlet container,
# and this module provides a streamlined way to install and
# configure Tomcat from a package on Ubuntu/Debian.
#
# === Parameters
#
# version (default: 7) - Version of a Tomcat Server to be installed.
#
# java_home - Home directory of the Java development kit (JDK).
#
# port (default: 8080) - Port on which Tomcat Server Instance is running.
#
# java_opts (default: -Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC) - JVM startup parameters.
#
# jsp_compiler - Java compiler to use for translating JavaServer Pages (JSPs).
#
# logfile_days - Number of days to keep logfiles in /var/log/tomcat.
#
# authbind - Used for binding Tomcat to port numbers lower than 1023.
#
#
# === Examples
#
# To install with defaults from the package on Ubuntu/Debian:
# class { 'tomcat':  }
#
# To install with customize configuration:
# class { 'tomcat':
#   version   => '6',
#   port => '9999',
#   java_home => '/usr/lib/jvm/java-8-oracle',
#   java_opts => '-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC',
#   jsp_compiler => 'javac',
#   logfile_days => '14',
#   authbind => 'no'
#  }
#
# === Authors
#
# Arpit Aggarwal <aggarwalarpit.89@gmail.com>

class tomcat($version = $tomcat::default::version,
  $java_home    = $tomcat::default::java_home,
  $port         = $tomcat::default::port,
  $java_opts    = $tomcat::default::java_opts,
  $jsp_compiler = $tomcat::default::jsp_compiler,
  $logfile_days = $tomcat::default::logfile_days,
  $authbind     = $tomcat::default::authbind
  ) inherits tomcat::default{

  package {"tomcat${version}":
    ensure  => installed,
    require => Exec['execute-apt-update'],
  }

  file { "/etc/default/tomcat${version}":
    ensure  => file,
    content => template('tomcat/tomcat.erb'),
    before  => Service["tomcat${version}"],
    require => Package["tomcat${version}"],
  }

  file { "/etc/tomcat${version}/server.xml":
    ensure  => file,
    content => template('tomcat/server.erb'),
    before  => Service["tomcat${version}"],
    require => Package["tomcat${version}"],
  }

  exec { 'execute-apt-update':
    command  => '/usr/bin/apt-get update',
  }

  service { "tomcat${version}":
    ensure  => running,
    enable  => true,
    require => Package["tomcat${version}"],
  }

  exec { 'service-restart':
    require => Service["tomcat${version}"],
    command => "/usr/bin/service tomcat${version} restart",
  }
}
