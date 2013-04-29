# Class: tomcat::package
#
# Implementation to download and configure tomcat.
#
# This class is not meant to be used by the end user of the module.  It is an implementation class of the composite
# Class

class tomcat::package ($version, $home, $user) {

   # Make Sure curl is installed
   if defined(Package['curl']) == false {
      package { "curl": ensure => "latest" }
   }

   # Make Sure unzip is installed
   if defined(Package['unzip']) == false {
      package { "unzip": ensure => "latest" }
   }

   # Make sure tomcat user is present
   if defined(User[$user]) == false {
      user { $user:
         ensure     => "present",
         shell      => "/bin/bash",
         managehome => true
      }
   }

   # Download Tomcat
   exec { "tomcat-download":
      command => "/usr/bin/curl -s --create-dirs -o ${home}/${version}.zip http://s3.amazonaws.com/repo.tomcat.apache.org/7/${version}.zip",
      creates => "${home}/${version}.zip",
      timeout => 6000,
      require => [Package["curl"],Package["unzip"]]
   }

   # Set Permissions on Tomcat Home to extract binary
   file { "tomcat-home":
       path    => $home,
       owner   => $user,
       group   => $user,
       purge   => false,
       mode    => 0754,
       force   => true,
       recurse => true,
       replace => false,
       require => [User[$user],Exec["tomcat-download"]]
   }


   # Extract Tomcat Binary File
   exec { "tomcat-binary-extract":
      command => "/usr/bin/unzip ${home}/${version}.zip && /bin/chmod -R 754 ${home}/${version}",
      cwd     => "${home}",
      creates => "${home}/${version}",
      user    => $user,
      require => [File["tomcat-home"]];
   }

   # Install Tomcat as a service
   file { "tomcat-install":
      path    => "/etc/init.d/tomcat",
      owner   => $user,
      group   => $user,
      mode    => 0754,
      ensure  => present,
      content => template("tomcat/tomcat.erb"),
      require => Exec["tomcat-binary-extract"];
    }

   service { "tomcat":
       ensure     => stopped,
       enable     => false,
       hasstatus  => false,
       hasrestart => false,
       require    => File["tomcat-install"];
  }
}