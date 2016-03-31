# Class   : jss::db
# Author  : tscopp@berkeley.edu

define jss::db($firewall=true,
              $context=$title,
              $db_addr='localhost',
              $db_name=$title,
              $db_user="${title}user",
              $db_passwd="${title}pw",
              $db_port='3306',
              $db_root_passwd='supersecure',
              $jss_addr='localhost',
              $tomcat_dir='/var/lib/tomcat7',
              $ensure='present') {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  if $ensure == 'present'{
    if $firewall {
      if $jss_addr == 'localhost'{
        firewall{"300 allow mysql traffic for ${context}":
          dport       => [$db_port],
          proto       => tcp,
          destination => $db_addr,
          action      => accept,
        }
      } else {
        firewall{"300 allow mysql traffic for ${context}":
          dport       => [$db_port],
          proto       => tcp,
          source      => $jss_addr,
          destination => $db_addr,
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
    if is_array($jss_addr) {
      $jss01 = $jss_addr[0]
      $jss02 = $jss_addr[1]
      exec{"${context}@${jss01}_db_grant":
          command => "sudo mysql -u root -p'${db_root_passwd}' -e \"grant all on ${context}.* to ${db_user}@${jss01} identified by '${db_passwd}';\"",
          path    => '/usr/bin/',
          require => Mysql::Db[$context],
          notify  => Exec["${context}.restart_mysql"],
      }
      exec{"${context}@${jss02}_db_grant":
          command => "sudo mysql -u root -p'${db_root_passwd}' -e \"grant all on ${context}.* to ${db_user}@${jss02} identified by '${db_passwd}';\"",
          path    => '/usr/bin/',
          require => Mysql::Db[$context],
          notify  => Exec["${context}.restart_mysql"],
      }
    } else {
      exec{"${context}_db_grant":
          command => "sudo mysql -u root -p'${db_root_passwd}' -e \"grant all on ${context}.* to ${db_user}@${jss_addr} identified by '${db_passwd}';\"",
          path    => '/usr/bin/',
          require => Mysql::Db[$context],
          notify  => Exec["${context}.restart_mysql"],
      }
    }
  }
}
