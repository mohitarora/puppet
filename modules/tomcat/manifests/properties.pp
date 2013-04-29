# This module will create the override properties file in tomcat lib folder for application installed on tomcat
define tomcat::properties(
   $home = $tomcat::params::home,
   $version = $tomcat::params::version,
   $user = $tomcat::params::user,
   $override_properties = '',
   $override_properties_filename = 'app.properties'
   ) {

   # Create Override Properties file
   file { "tomcat-properties-${override_properties_filename}":
      path    => "${home}/${version}/lib/${override_properties_filename}",
      owner   => $user,
      mode    => 0775,
      ensure  => present,
      content => template("tomcat/properties.erb"),
      require => File["tomcat-install"],
      notify  => Service['tomcat'],
    }

}