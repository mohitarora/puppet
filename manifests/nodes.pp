# This will contain the node definitions that are managed by puppet.

# Base Node, Every Node should inherit base node. What base node will make sure is that custom facts scripts get
# executed when client connects to master.

node base {
	include base
}

node /^.*apache_tomcat_server$/ inherits base {

   # Install Apache
   class {'apache':  }

   # Required to Install Http Proxy Module
   apache::mod { 'proxy_http': }

   # Define a vhost with proxy settings
   apache::vhost::proxy {  $vhost_server_name:
      port            => $vhost_port,
      no_proxy_uris   => [$vhost_no_proxy_uris],
      dest            => $proxy_destination
   }

   # Install Tomcat
   class { 'tomcat':
      version      => $tomcat_version,
      home         => $tomcat_home
   }

   # Deploy App, GWT and Web assets
   jenkins::deploy {

      'app':
         artifact_url => $war_file_url,
         artifact_name => $war_file_name,
         artifact_type => 'war',
         destination_dir => "${tomcat_home}/${tomcat_version}/webapps",
         require => File["tomcat-install"],
         notify  => Service['tomcat'];

      'web-assets':
         artifact_url => $web_assets_url,
         artifact_name => $web_assets_file_name,
         artifact_type => 'zip',
         destination_dir => $docroot,
         require => Package['httpd'],
         notify  => Service['httpd'];
   }

   tomcat::properties { 'app-properties':
      version      => $tomcat_version,
      home         => $tomcat_home,
      override_properties  => $override_properties,
      override_properties_filename  => $override_properties_filename
   }
}


node /^.*apache_tomcat_gwt_server$/ inherits base {

   # Install Apache
   class {'apache':  }

   # Required to Install Http Proxy Module
   apache::mod { 'proxy_http': }

   # Define a vhost with proxy settings
   apache::vhost::proxy {  $vhost_server_name:
      port            => $vhost_port,
      no_proxy_uris   => [$vhost_no_proxy_uris],
      dest            => $proxy_destination
   }

   # Install Tomcat
   class { 'tomcat':
      version      => $tomcat_version,
      home         => $tomcat_home
   }

   # Deploy App, GWT and Web assets
   jenkins::deploy {

      'app':
         artifact_url => $war_file_url,
         artifact_name => $war_file_name,
         artifact_type => 'war',
         destination_dir => "${tomcat_home}/${tomcat_version}/webapps",
         require => File["tomcat-install"],
         notify  => Service['tomcat'];

      'web-assets':
         artifact_url => $web_assets_url,
         artifact_name => $web_assets_file_name,
         artifact_type => 'zip',
         destination_dir => $docroot,
         require => Package['httpd'],
         notify  => Service['httpd'];

      'gwt-assets':
         artifact_url => $gwt_assets_url,
         artifact_name => $gwt_assets_file_name,
         artifact_type => 'zip',
         destination_dir => $docroot,
         require => Package['httpd'],
         notify  => Service['httpd'];
   }

   tomcat::properties { 'app-properties':
      version      => $tomcat_version,
      home         => $tomcat_home,
      override_properties  => $override_properties,
      override_properties_filename  => $override_properties_filename
   }
}


node /^.*tomcat_server$/ inherits base {

   class { 'tomcat':
      version      => $tomcat_version,
      home         => $tomcat_home
   }

   jenkins::deploy { 'app':
      artifact_url => $war_file_url,
      artifact_name => $war_file_name,
      artifact_type => 'war',
      destination_dir => "${tomcat_home}/${tomcat_version}/webapps",
      require => File["tomcat-install"],
      notify  => Service['tomcat'],
   }

   tomcat::properties { 'app-properties':
      version      => $tomcat_version,
      home         => $tomcat_home,
      override_properties  => $override_properties,
      override_properties_filename  => $override_properties_filename
   }
}


node /^.*apache_php$/ inherits base {

   # Install Apache
   class {'apache':  }

   class {'apache::mod::php' : }

   class { 'mysql': }

   class { 'mysql::php': }

   apache::vhost { $vhost_server_name:
      port            => $vhost_port,
      docroot         => $docroot,
      ssl 	          => false,
      override        => ['All',],
   }

   # Deploy App, GWT and Web assets
   jenkins::deploy {

      'web-assets':
         artifact_url => $web_assets_url,
         artifact_name => $web_assets_file_name,
         artifact_type => 'zip',
         destination_dir => $docroot,
         require => Package['httpd'],
         notify  => Service['httpd'];
   }

}

node default {

}
