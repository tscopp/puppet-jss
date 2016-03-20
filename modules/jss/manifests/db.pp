# Class   : jss::db
# Author  : tscopp@berkeley.edu

class jss::db($firewall=true,
              $context='production',
              $db_user='jss',
              $db_passwd='jsspw',
              $db_root_passwd='supersecure',
              $mysql_addr='',
              $jss_addr='%') {
  if $mysql_addr == '' {
    $db_addr = $::ipaddress
  } else {
    $db_addr = $mysql_addr
  }
  if $firewall {
    if $jss_addr == '%'{
      firewall{'104 allow mysql':
        dport       => [3306],
        proto       => tcp,
        destination => $db_addr,
        action      => accept,
      }
    } else {
      firewall{'104 allow mysql':
        dport       => [3306],
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
    password => $db_passwd,
    host     => $::fqdn ,
    grant    => ['ALL'],
    require  => Class['::mysql::server'],
  }
  # MySQL: select password('password');
  mysql_user{"${db_user}@${jss_addr}/${context}":
    ensure               => present,
    password_hash        => '*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19',
    max_user_connections => '90',
    require              => Class['::mysql::server'],
  }
  mysql_grant{"${db_user}@${jss_addr}/${context}.*":
    ensure     => present,
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => "${context}.*",
    user       => "${db_user}@${jss_addr}",
    require    => Class['::mysql::server'],
  }
}
