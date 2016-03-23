# Class   : jss::jss
# Author  : tscopp@berkeley.edu

define jss::context($ensure='present',
              $api=true,
              $context = $title,
              $db_addr='localhost',
              $db_port='3306',
              $db_user="${title}user",
              $db_passwd="${title}pw",
              $db_min_pool='5',
              $db_max_pool='90',
              $firewall=true,
              $http=true,
              $http_port='8080',
              $http_proxy_port='8443',
              $https=false,
              $https_port='8443',
              $keystore_path='/var/lib/tomcat7/keystore.jks',
              $keystore_pass='',
              $loadbalanced=false,
              $log_path='/var/lib/tomcat7/logs',
              $tomcat_dir='/var/lib/tomcat7',
              $tomcat_max_threads='450',
              $user_enrollment=true,
              $war='ROOT.war'){
  if $ensure == 'present'{
    package{['tar', 'unzip', 'java1.6', 'tomcat7']:
      ensure => present,
    }
    if $firewall {
      firewall{"100 allow ssh for ${context}":
        dport  => 22,
        proto  => tcp,
        action => accept,
      }
      firewall{"200 allow http-alt (8080) for ${context}":
        dport       => [8080],
        proto       => tcp,
        destination => $::ipaddress,
        action      => accept,
      }
      firewall{"200 allow http-alt-alt (8443)for ${context}":
        dport       => [8443],
        proto       => tcp,
        destination => $::ipaddress,
        action      => accept,
      }
    }
    service{'tomcat7':
      ensure  => running,
      require => Package['tomcat7'],
    }
    file{"${context}.server.xml":
      content => template('jss/server.xml.erb'),
      path    => "${tomcat_dir}/conf/server.xml",
      owner   => 'tomcat7',
      group   => 'tomcat7',
      mode    => '0644',
      notify  => Service['tomcat7'],
      require => Package['tomcat7'],
    }
    file{"${context}.war":
      ensure  => present,
      path    => "${tomcat_dir}/webapps/${context}.war",
      owner   => 'tomcat7',
      group   => 'tomcat7',
      mode    => '0644',
      source  => "puppet:///modules/jss/${war}",
      require => Package['tomcat7'],
    }
    exec{"pause_for_${context}_deploy":
      command => 'sleep 10',
      path    => '/usr/bin:/bin',
      require => File["${context}.war"],
      creates => "${tomcat_dir}/webapps/${context}",
    }
    file{"${context}.DataBase.xml":
      content => template('jss/DataBase.xml.erb'),
      path    => "${tomcat_dir}/webapps/${context}/WEB-INF/xml/DataBase.xml",
      owner   => 'tomcat7',
      group   => 'tomcat7',
      mode    => '0644',
      notify  => Service['tomcat7'],
      require => Exec["pause_for_${context}_deploy"],
    }
    file{"${context}.log4j.properties":
      content => template('jss/log4j.properties.erb'),
      path    => "${tomcat_dir}/webapps/${context}/WEB-INF/classes/log4j.properties",
      owner   => 'tomcat7',
      group   => 'tomcat7',
      mode    => '0644',
      require => Exec["pause_for_${context}_deploy"],
    }
    if $api == false {
      file{"${context}.api":
        ensure  => absent,
        path    => "${tomcat_dir}/webapps/${context}/api",
        force   => true,
        recurse => true,
        notify  => Service['tomcat7'],
      }
    }
    if $https {
      file{"${context}.keystore":
        ensure => present,
        path   => $keystore_path,
        source => 'puppet:///modules/jss/keystore.jks',
        owner  => 'tomcat7',
        group  => 'tomcat7',
        mode   => '0600',
      }
    }
  }
}
