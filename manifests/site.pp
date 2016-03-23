Exec{
  path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}
Exec['apt-update'] -> Package <| |>
exec{'apt-update':
  command     => 'apt-get update',
}

node jss{
  jss::context{'production':
    ensure    => present,
    db_addr   => '192.168.56.102',
    db_user   => 'jamfsoftware',
    db_passwd => 'jamfsw03',
    firewall  => true,
  }
}
node db {
  jss::db{'production':
    ensure    => present,
    db_addr   => '192.168.56.102',
    db_user   => 'jamfsoftware',
    db_passwd => 'jamfsw03',
    jss_addr  => '192.168.56.101',
    firewall  => false,
  }
}
