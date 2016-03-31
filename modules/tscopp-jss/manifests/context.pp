# Class   : jss::jss
# Author  : tscopp@berkeley.edu

define jss::context($ensure='present',
              $activation_code='',
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
              $institution_name='',
              $keystore_path='/var/lib/tomcat7/keystore.jks',
              $keystore_pass='',
              $loadbalanced=false,
              $log_path='/var/lib/tomcat7/logs',
              $tomcat_dir='/var/lib/tomcat7',
              $tomcat_max_threads='450',
              $user_enrollment=true,
              $war='ROOT.war'){
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  if $ensure == 'present'{
    if !defined(Package['tomcat7']){
      package{['tar',
                'unzip',
                'java1.6',
                'tomcat7']:
        ensure => present,
      }
    }
    if $firewall {
      firewall{"100 allow ssh for ${context}":
        dport  => 22,
        proto  => tcp,
        action => accept,
      }
      firewall{"200 allow http (${http_port}) for ${context}":
        dport       => $http_port,
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
    if !defined(Service['tomcat7']){
      service{'tomcat7':
        ensure  => running,
        require => Package['tomcat7'],
      }
    }
    if !defined(File['server.xml']){
      file{'server.xml':
        content => template('jss/server.xml.erb'),
        path    => "${tomcat_dir}/conf/server.xml",
        owner   => 'tomcat7',
        group   => 'tomcat7',
        mode    => '0644',
        notify  => Service['tomcat7'],
        require => Package['tomcat7'],
      }
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
    #file{"${tomcat_dir}/webapps/${context}":
    #  ensure  => directory,
    #  owner   => 'tomcat7',
    #  group   => 'tomcat7',
    #  mode    => '0755',
    #  require => Exec["pause_for_${context}_deploy"],
    #  }
    exec{"pause_for_${context}_deploy":
      command => 'sleep 15',
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
    if $activation_code != '' {
      exec{"inject_${context}_activation_code":
        command => "mysql -u ${db_user} -p${db_passwd} --host ${db_addr} -e 'INSERT into ${context}.activation_code (activation_code, institution_name) VALUES ('${activation_code}', '${institution_name}')",
        path    => '/usr/bin:/bin',
        require => File["${context}.DataBase.xml"],
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
