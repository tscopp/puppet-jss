Exec{
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}
Exec['apt-update'] -> Package <| |>
exec{'apt-update':
  command     => 'apt-get update',
}

# Multi-Context all-in-one
node default{
  jss::context{'production':
    ensure           => present,
    api              => false,
    user_enrollment  => false,
  }
  jss::db{'production':
    ensure => present,
  }
  jss::context{'development':
    ensure => present,
  }
  jss::db{'development':
    ensure => present,
  }

}

# Single-context, backed by a separate DB host
node jss {
  jss::context{'dev':
    ensure    => present,
    db_addr   => '192.168.56.104',
    db_passwd => 'devpw',
    db_user   => 'devuser',
    firewall  => false,
  }
}

# Single-context, clustered, external DB host
node jss01{
  jss::context{'jssprod01':
    ensure    => present,
    context   => 'production',
    db_addr   => '192.168.56.104',
    db_passwd => 'jamfsw03',
    db_user   => 'jamfsoftware',
  }
}
node jss02 {
  jss::context{'jssprod02':
    ensure    => present,
    context   => 'production',
    db_addr   => '192.168.56.104',
    db_user   => 'jamfsoftware',
    db_passwd => 'jamfsw03',
  }
}
node db {
  jss::db{'production':
    ensure    => present,
    db_addr   => '192.168.56.104',
    db_user   => 'jamfsoftware',
    db_passwd => 'jamfsw03',
    jss_addr  => ['192.168.56.102',
                  '192.168.56.103'],
  }
  jss::db{'dev':
    ensure    => present,
    db_addr   => '192.168.56.104',
    db_passwd => 'devpw',
    db_user   => 'devuser',
    jss_addr  => ['192.168.56.102',
                  '192.168.56.103'],
  }
}
