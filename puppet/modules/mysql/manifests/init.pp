class mysql( $root_password ) {
  package { "mysql-server": ensure => installed }
  package { "mysql-client": ensure => installed }

  exec { "Set MySQL server root password":
    subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
    refreshonly => true,
    unless => "mysqladmin -uroot -p{$root_password} status",
    path => "/bin:/usr/bin",
    command => "mysqladmin -uroot password ${root_password}",
  }

  service { "mysql":
      require => [ Package["mysql-server"], Exec['Set MySQL server root password'] ],
      hasstatus => true,
  }
}