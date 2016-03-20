# Class   : jss::db
# Author  : tscopp@berkeley.edu

define jss::db($firewall=true,
              $context=$title,
              $db_user="${title}user",
              $db_passwd="${title}pw",
              $db_port='3306',
              $db_root_passwd='supersecure',
              $mysql_addr='',
              $jss_addr='localhost',
              $ensure='present') {
  if $ensure == 'present'{
    if $mysql_addr == '' {
      $db_addr = $::ipaddress
    } else {
      $db_addr = $mysql_addr
    }
    if $firewall {
      if $jss_addr == '%'{
        firewall{'104 allow mysql':
          dport       => [$db_port],
          proto       => tcp,
          destination => $db_addr,
          action      => accept,
        }
      } else {
        firewall{'104 allow mysql':
          dport       => [$db_port],
          proto       => tcp,
          source      => $jss_addr,
          destination => $db_addr,
          action      => accept,
        }
      }
    }
    class { '::mysql::server':
      root_password           => $db_root_passwd,
      remove_default_accounts => true,
    }
    mysql::db { $context:
      user     => $db_user,
      password => mysql_password($db_passwd),
      host     => $::fqdn ,
      grant    => ['ALL'],
      require  => Class['::mysql::server'],
    }

    # This should work. For some reason it does not.
    #mysql_user{"${db_user}@${jss_addr}/${context}":
    #  ensure               => present,
    #  password_hash        => mysql_password($db_passwd),
    #  max_user_connections => '90',
    #  require              => Class['::mysql::server'],
    #}
    #mysql_grant{"${db_user}@${jss_addr}/${context}.*":
    #  ensure     => present,
    #  options    => ['GRANT'],
    #  privileges => ['ALL'],
    #  table      => "${context}.*",
    #  user       => "${db_user}@${jss_addr}",
    #  require    => Class['::mysql::server'],
    #}

    # This is ugly but it works.
    exec{'db_grant':
      command => "sudo mysql -u root -p${db_root_passwd} -e \"grant all on ${context}.* to ${db_user}@${jss_addr} identified by '${db_passwd}';\"",
      path    => '/usr/bin/',
      require => Class['::mysql::server'],
    }
  }
}
