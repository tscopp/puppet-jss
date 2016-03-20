# Class   : jss::jss
# Author  : tscopp@berkeley.edu

class jss::jss($firewall=true,
              $context='production') {
  if $firewall {
    firewall{'101 allow ssh':
      dport  => [22],
      proto  => tcp,
      action => accept,
    }
    firewall{'102 allow http-alt (8080)':
      dport  => [8080],
      proto  => tcp,
      action => accept,
    }
    firewall{'103 allow http-alt-alt (8443)':
      dport  => [8443],
      proto  => tcp,
      action => accept,
    }
  }
  class { 'tomcat':
    version => '7',
    port    => '8080'
  }
  file{"${context}.war":
    ensure => present,
    path   => "/var/lib/tomcat7/webapps/${context}.war",
    owner  => 'tomcat7',
    group  => 'tomcat7',
    mode   => '0644',
    source => 'puppet:///modules/jss/ROOT.war'
  }
}
