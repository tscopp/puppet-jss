# Class   : jss::jss
# Author  : tscopp@berkeley.edu

define jss::context($ensure='present',
              $context = $title,
              $firewall=true,
              $db_addr='localhost',
              $db_port='3306',
              $db_user="${title}user",
              $db_passwd="${title}pw",
              $db_min_pool='5',
              $db_max_pool='90',
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
      ensure  => present,
      path    => "/var/lib/tomcat7/webapps/${title}.war",
      owner   => 'tomcat7',
      group   => 'tomcat7',
      mode    => '0644',
      source  => "puppet:///modules/jss/${war}",
      require => Class['tomcat'],
    }
    exec{'pause_for_tomcat_deploy':
      command => 'sleep 15',
      path    => '/usr/bin:/bin',
      require => [File["${context}.war"],
                  Service['tomcat7'],],
    }
    file{'DataBase.xml':
      content => template('jss/DataBase.xml.erb'),
      path    => "/var/lib/tomcat7/webapps/${context}/WEB-INF/xml/DataBase.xml",
      owner   => tomcat7,
      group   => tomcat7,
      mode    => '0644',
      require => Exec['pause_for_tomcat_deploy'],
    }
    file { '/tmp/link-to-motd':
    ensure     => 'link',
      target => '/etc/motd',
    }
  }
}
