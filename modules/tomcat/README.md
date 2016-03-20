# tomcat puppet module

### Table of Contents

1. [Overview][overview]
2. [Module Description][module-description]
3. [What Tomcat Puppet Module Affects][what-tomcat-puppet-module-affects]
4. [Usage][usage]

### Overview

Configure and Install Tomcat on Ubuntu/Debian.

### Module Description

Tomcat is an open-source web server and servlet container, and this module provides a streamlined way to install and configure Tomcat from a package.


### What Tomcat Puppet Module Affects

- configuration files and directories
- package/service/configuration files for Tomcat
- listened-to ports
- ```/etc/default/tomcat{version}```
- ```/etc/tomcat{version}/server.xml```

### Usage

If you just want a tomcat 7 server installation with the default options you can run:

```
class { 'tomcat':  }
```

If you need to customize ```port``` configuration option you need to do the following:

```
class { 'tomcat':
  version   => '7',
  port => '9999'
}
```

If you need to customize all configuration options you need to do the following:

```
class { 'tomcat':
  version   => '6',
  port => '9999',
  java_home => '/usr/lib/jvm/java-8-oracle',
  java_opts => '-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC',
  jsp_compiler => 'javac',
  logfile_days => '14',
  authbind => 'no'
}  
```

[overview]: https://github.com/arpitaggarwal/tomcat#overview
[module-description]: https://github.com/arpitaggarwal/tomcat#module-description
[what-tomcat-puppet-module-affects]: https://github.com/arpitaggarwal/tomcat#what-tomcat-puppet-module-affects
[usage]: https://github.com/arpitaggarwal/tomcat#usage
