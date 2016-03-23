# Class   : jss::db
# Author  : tscopp@berkeley.edu

define jss::db($firewall=true,
              $context=$title,
              $db_addr='localhost',
              $db_name='jamfsoftware',
              $db_user="${title}user",
              $db_passwd="${title}pw",
              $db_port='3306',
              $db_root_passwd='supersecure',
              $jss_addr='localhost',
              $tomcat_dir='/var/lib/tomcat7',
              $ensure='present') {
  if $ensure == 'present'{
    if $firewall {
      if $jss_addr == 'localhost'{
        firewall{"300 allow mysql traffic for ${context}":
          dport       => [$db_port],
          proto       => tcp,
          #destination => $db_addr,
          action      => accept,
        }
      } else {
        firewall{"300 allow mysql traffic for ${context}":
          dport       => [$db_port],
          proto       => tcp,
          #source      => $jss_addr,
          #destination => $db_addr,
          action      => accept,
        }
      }
    }
    if !defined(Class['::mysql::server']) {
      class { '::mysql::server':
        root_password           => $db_root_passwd,
        remove_default_accounts => true,
        override_options        => {'mysqld' => {'bind-address' => $db_addr}},
      }
    }
    exec{"${context}.restart_mysql":
      command     => '/etc/init.d/mysql restart',
      refreshonly => true,
      require     => Service['mysql'],
    }
    mysql::db { $context:
      user     => $db_user,
      password => mysql_password($db_passwd),
      host     => $::fqdn ,
      grant    => ['ALL'],
      require  => Service['mysql'],
    }
    if defined(Service['tomcat7']){
      exec{"${context}_db_grant":
        command => "sudo mysql -u root -p${db_root_passwd} -e \"grant all on ${db_name}.* to ${db_user}@${jss_addr} identified by '${db_passwd}';\"",
        path    => '/usr/bin/',
        notify  => Service['tomcat7'],
        require => Mysql::Db[$context],
        creates => "${tomcat_dir}/webapps/${context}/.grants",
      }
      file{"${context}.grants":
        ensure  => present,
        path    => "${tomcat_dir}/webapps/${context}/.grants",
        content => 'keytar',
        require => Exec["${context}_db_grant"],
      }
    } else {
        exec{"${context}_db_grant":
          command => "sudo mysql -u root -p${db_root_passwd} -e \"grant all on ${context}.* to ${db_user}@${jss_addr} identified by '${db_passwd}';\"",
          path    => '/usr/bin/',
          require => Mysql::Db[$context],
          notify  => Exec["${context}.restart_mysql"],
      }
    }
  }
}
