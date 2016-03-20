# == Class: default::params
#
# Defines the default parameters for Tomcat server.
# === Authors
#
# Arpit Aggarwal <aggarwalarpit.89@gmail.com>

class tomcat::default (
  $version      = 7,
  $java_home    = undef,
  $port         = '8080',
  $java_opts    = '-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC',
  $jsp_compiler = undef,
  $logfile_days = undef,
  $authbind     = undef) {
}
