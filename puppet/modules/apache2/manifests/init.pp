class apache2( $document_root ) {

   package { "apache2":
       ensure => "latest"
   }

   file { "/etc/apache2/sites-available/default":
       content => template("apache2/vhost_default.erb")
   }

   service { "apache2":
      ensure => running,
      hasstatus => true,
      hasrestart => true,
      require => Package["apache2"],
   }

   exec { "reload-apache2":
      command => "/etc/init.d/apache2 reload",
   }

}