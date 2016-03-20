# Class   : jss::jss
# Author  : tscopp@berkeley.edu

define jss::context($ensure='present',
              $context = $title,
              $firewall=true,
              $db_host='localhost',
              $war='ROOT.war'){
  if $ensure == 'present'{
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
      path   => "/var/lib/tomcat7/webapps/${title}.war",
      owner  => 'tomcat7',
      group  => 'tomcat7',
      mode   => '0644',
      source => "puppet:///modules/jss/${war}"
    }
    file{"/var/lib/tomcat7/webapps/${context}/WEB-INF/xml/DataBase.xml":
    content => template('jss/DataBase.xml.erb'),
    owner   => tomcat7,
    group   => tomcat7,
    mode    => '0644',
    notify  => Service['tomcat7'],
  }
  }
}
