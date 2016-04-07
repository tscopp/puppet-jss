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
    ensure          => present,
    api             => false,
    user_enrollment => false,
    war_url         => 'http://internal_web/jss982.war'
  }
  jss::db{'production':
    ensure  => present,
  }
  jss::context{'development':
    ensure  => present,
    war_url => 'http://internal_web/jss99.war'
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
    war_url   => 'http://internal_web/jss99.war'
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
    war_url   => 'http://internal_web/jss982.war'
  }
}
node jss02 {
  jss::context{'jssprod02':
    ensure    => present,
    context   => 'production',
    db_addr   => '192.168.56.104',
    db_user   => 'jamfsoftware',
    db_passwd => 'jamfsw03',
    war_url   => 'http://internal_web/jss982.war'
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
