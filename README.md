# jss

## Deployment

### Single Context
```ruby
    jss::context{'production':
        ensure    => present,
        firewall  => true,
    }
    jss::db{'production':
        ensure    => present,
        firewall  => true,
    }
```

### Multi-context
```ruby
    jss::context{'production':
        ensure   => present,
        firewall => true,
    }
    jss::db{'production':
        ensure   => present,
        firewall => true,
    }
    jss::context{'development':
        ensure   => present,
        firewall => true,
    }
    jss::db{'development':
        ensure   => present,
        firewall => true,
    }
```

### Clustered
```ruby
    jss::context{'jssprod01':
        ensure   => present,
        context  => 'production',
        firewall => true,
    }
    jss::db{'production':
        ensure   => present,
        context  => 'production',
        firewall => true,
    }
    jss::context{'jssprod02':
        ensure   => present,
        context  => 'production',
        firewall => true,
    }
```

### SSL Enabled

Currently SSL and NonSSL hosts can NOT exist on the same tomcat instance. If you'd like SSL certs you should create a keystore:

```bash
# keytool -genkeypair -alias tomcat -keyalg RSA -keysize 2048 -validity 365 -keystore ~/keystore.jks
```
Create a CSR:
```bash
# keytool -certreq -keyalg RSA -alias tomcat -keystore ~/keystore.jks
```
Sign the CSR in the JSS web interface. Download the ca.pem, and the signed webcert. Add them to the keystore:
```bash
# keytool -import -alias root -keystore ~/keystore.jks trustcacerts -file ~/Downloads/ca.pem
```
```bash
# keytool -import -alias tomcat -keystore ~/keystore.jks trustcacerts -file ~/Downloads/webcert.pem
```
Move keystore.jks to the modules/jss/files/ and add the following to the desired node:
```ruby
    jss::context{'production':
        ensure       => present,
        api          => false,
        firewall     => true,
        db_user      => 'produser',
        db_passwd    => 'prodpw',
        keystoreFile => '/var/lib/tomcat7/keystore.jks',
        keystorePass => 'keystorepass',
        https        => true,
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
License
-------


Contact
-------


Support
-------

Please log tickets and issues at our [Projects site](http://projects.example.com)
