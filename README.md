# puppet-jss

Deployment of JAMF Software's JSS is, by no means, an unmanageable task. There are, however, a lot of steps. This module seeks to resolve that.

## TL;DR:
Go to "My Products - JAMF Nation" (https://my.jamfsoftware.com/products.html) and authenticate.
Download the desired version of the JSS Manual Installation.

```bash
git clone git@github.com:tscopp/puppet-jss.git
unzip JSSInstallationX.X.zip
cp JSSInstallation/JSS Components/ROOT.war puppet-jss/modules/jss/files/
cd puppet-jss

## All in one, multicontext -- http://${ip}:8080/production, http://${ip}/development
vagrant up default

## Separate hosts -- http://${ip}:8081/dev
vagrant up db
vagrant up jss

## Clustered -- http://${ip}:8082/production, http://${ip}:8083/production
vagrant up db
vagrant up jss01
vagrant up jss02
```

## Deployment

Very little is required to get a fully functional JSS running on port 8080 supported by a mysql database on port 3306. Many assumptions are made, 'best practices' are followed where possible.

### Single Context
```ruby
node default{
    jss::context{'production':
        ensure  => present,
        war_url => 'http://internal_web/jss982.war',
    }
    jss::db{'production':
        ensure   => present,
    }
}
```

```bash
vagrant up default
```

The module will assign very weak (un:${context_name}user pw:${context_name}pw) credentials unless otherwise specified. Let's set our own credentials and separate the hosts while we're at it. In order to maintain functionality of the firewall (see below) we must specify both $jss_addr and $db_addr.
```ruby
node jss{
    jss::context{'production':
        ensure          => present,
        api             => false,
        db_addr         => '192.168.56.101',
        db_passwd       => 'jamfsw03',
        db_user         => 'jamfuser',
        user_enrollment => true,
        war_url         => 'http://internal_web/jss982.war',
    }
}
node db{
    jss::db{'production':
        ensure    => present,
        db_passwd => 'jamfsw03',
        db_user   => 'jamfuser',
        jss_addr  => '192.168.56.102',
    }
}
```
```bash
vagrant up db
vagrant up jss
```

### Multi-context
```ruby
node default{
    jss::context{'production':
        ensure  => present,
        war_url => 'http://internal_web/jss982.war',
    }
    jss::db{'production':
        ensure => present,
    }
    jss::context{'development':
        ensure  => present,
        war_url => 'http://internal_web/jss99.war',
    }
    jss::db{'development':
        ensure => present,
    }
```
```bash
vagrant up default
```

### Clustered
```ruby
node jss01{
    jss::context{'jssprod01':
        ensure    => present,
        context   => 'production',
        db_user   => 'jamfsoftware',
        db_passwd => 'jamfsw03',
        war_url   => 'http://internal_web/jss982.war',
    }
}
node jss02 {
    jss::context{'jssprod02':
        ensure    => present,
        context   => 'production',
        db_user   => 'jamfsoftware',
        db_passwd => 'jamfsw03',
        war_url   => 'http://internal_web/jss982.war',
    }
}
node db {
    jss::db{'production':
        ensure    => present,
        db_user   => 'jamfsoftware',
        db_passwd => 'jamfsw03',
        jss_addr  => ['192.168.56.101',
                        '192.168.56.102',],
    }
```
```bash
vagrant up db
vagrant up jss01
vagrant up jss02
```

### SSL Enabled

First we'll need to bring up a plain ol' http JSS. We'll disable the API and user enrollment just for kicks.
```ruby
node default{
    jss::context{'production':
        ensure          => present,
        api             => false,
        db_user         => 'jamfsoftware',
        db_passwd       => 'jamfsw03',
        http            => true,
        https           => false,
        user_enrollment => false,
        war_url         => 'http://internal_web/jss982.war',
    }
    jss::db{'production':
        ensure => present,
        db_user         => 'jamfsoftware',
        db_passwd       => 'jamfsw03',
    }
}
```
SSL and non-SSL hosts can NOT exist on the same tomcat instance. If you'd like SSL certs you should create a keystore:

```bash
keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 -validity 365 -keystore ~/keystore.jks
```
Create a CSR:
```bash
keytool -certreq -keyalg RSA -alias tomcat -keystore ~/keystore.jks
```
Sign the CSR in the JSS web interface. Download the ca.pem, and the signed webcert. Add them to the keystore:
```bash
keytool -import -alias root -keystore ~/keystore.jks -trustcacerts -file ~/Downloads/ca.pem
```
```bash
keytool -import -alias tomcat -keystore ~/keystore.jks -trustcacerts -file ~/Downloads/webcert.pem
```
Move keystore.jks to the modules/jss/files/ and add the following to the desired node:
```ruby
    jss::context{'production':
        ensure       => present,
        api          => false,
        db_user      => 'produser',
        db_passwd    => 'prodpw',
        keystoreFile => '/var/lib/tomcat7/keystore.jks',
        keystorePass => 'keystorepass',
        https        => true,
        war_url      => 'http://internal_web/jss982.war',
    }
    jss::db{'production':
        ensure   => present,
        context  => 'production',
        firewall => true,
    }
    File{'keystore':
        ensure => present,
        path   => '/var/lib/tomcat7/keystore.jks',
        source => 'puppet:///modules/jss/keystore.jks',
        owner  => 'tomcat7',
        group  => 'tomcat7',
        mode   => '0600',
    }
```
### All parameters
Don't specify all the paramters at once, this section is merely for reference.

```ruby
node default{
    jss::context{'super_mega_broken'
        ensure='present',
        api=true,
        context = $title,
        db_addr='localhost',
        db_port='3306',
        db_user="${title}user",
        db_passwd="${title}pw",
        db_min_pool='5',
        db_max_pool='90',
        firewall=true,
        http=true,
        http_port='8080',
        http_proxy_port='8443',
        https=false,
        https_port='8443',
        keystore_path='/var/lib/tomcat7/keystore.jks',
        keystore_pass='',
        loadbalanced=false,
        log_path='/var/lib/tomcat7/logs',
        tomcat_dir='/var/lib/tomcat7',
        tomcat_max_threads='450',
        user_enrollment=true,
        war='ROOT.war',
        war_url='http://websever/jss982.war',
    }

    jss::db{'super_mega_broken':
        ensure='present'
        context=$title,
        db_addr='localhost',
        db_name='jamfsoftware',
        db_user="${title}user",
        db_passwd="${title}pw",
        db_port='3306',
        db_root_passwd='supersecure',
        firewall=true,
        jss_addr='localhost',
        tomcat_dir='/var/lib/tomcat7',
    }
```
#### Firewall
By default the firewall will allow:
- 22 on all nodes
- 3306 on the database nodes -- to only the $jss_addr address or % if not specified
- 8080 and 8443 on the JSS nodes.
License
-------
Apache License 2.0


Contact
-------
tscopp@berkeley.edu

