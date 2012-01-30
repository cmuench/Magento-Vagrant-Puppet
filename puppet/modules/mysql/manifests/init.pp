class mysql( $root_password ) {

    package { "mysql-server": ensure => latest }
    package { "mysql-client": ensure => latest }

    file { 
        "/etc/mysql/my.cnf":
            content => template("mysql/my_cnf.erb")
    } 

    exec { "Set MySQL server root password":
        subscribe => [ Package["mysql-server"], Package["mysql-client"] ],
        refreshonly => true,
        unless => "mysqladmin -uroot -p${root_password} status",
        path => "/bin:/usr/bin",
        command => "mysqladmin -uroot password ${root_password}",
    }

    exec { "Create vagrant user":
      unless => "/usr/bin/mysqladmin -uvagrant -pvagrant status",
      command => "/usr/bin/mysql -uroot -p${root_password} -e \"CREATE USER vagrant@'%' IDENTIFIED BY 'vagrant'; Grant all on *.* TO vagrant@'%';\"",
      require => Service["mysql"],
    }

    service { "mysql":
        require => [ Package["mysql-server"], Exec['Set MySQL server root password'] ],
        hasstatus => true,
    }
}
