class tomcat(
   $home = $tomcat::params::home,
   $version = $tomcat::params::version,
   $user = $tomcat::params::user
) inherits tomcat::params {

   # when a class declares another class, the resources in the interior class are not contained by the exterior class.
   # This interacts badly with the pattern of composing complex modules from smaller classes,
   # as it makes it impossible for end users to specify order relationships between the exterior class and other
   # modules.
   # The anchor type lets you work around this. By sandwiching any interior classes between two no-op resources that
   # are contained by the exterior class, you can ensure that all resources in the module are contained.

   anchor { 'tomcat::begin': }
   anchor { 'tomcat::end': }

   class { 'tomcat::package':
           version      => $version,
           home         => $home,
           user         => $user,
           require      => Anchor['tomcat::begin'],
           before       => Anchor['tomcat::end'],
   }
}