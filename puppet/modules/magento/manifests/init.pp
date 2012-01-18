class magento( $db_username, $db_password, $version, $admin_username, $admin_password, $use_rewrites) {

  exec { "create-magentodb-db":
        unless => "/usr/bin/mysql -uroot -p${mysql::root_password} magentodb",
        command => "/usr/bin/mysqladmin -uroot -p${$mysql::root_password} create magentodb",
        require => [Service["mysql"]]
  }

  exec { "grant-magentodb-db-all":
        unless => "/usr/bin/mysql -u${db_username} -p${db_password} magentodb",
        command => "/usr/bin/mysql -uroot -p${$mysql::root_password} -e \"grant all on *.* to magento@'%' identified by '${db_password}' WITH GRANT OPTION;\"",
        require => [Service["mysql"], Exec["create-magentodb-db"]]
  }

  exec { "grant-magentodb-db-localhost":
        unless => "/usr/bin/mysql -u${db_username} -p${db_password} magentodb",
        command => "/usr/bin/mysql -uroot -p${$mysql::root_password} -e \"grant all on *.* to magento@'localhost' identified by '${db_password}' WITH GRANT OPTION;\"",
        require => Exec["grant-magentodb-db-all"]
  }

  exec { "download-magento":
    cwd => "/tmp",
    command => "/usr/bin/wget http://www.magentocommerce.com/downloads/assets/${version}/magento-${version}.tar.gz",
    creates => "/tmp/magento-${version}.tar.gz",
  }

  exec { "untar-magento":
    cwd => $apache2::document_root,
    command => "/bin/tar xvzf /tmp/magento-${version}.tar.gz",
    require => [Exec["download-magento"]]
  }

  exec { "setting-permissions":
    cwd => "${apache2::document_root}/magento",
    command => "/bin/chmod 550 mage; /bin/chmod o+w var var/.htaccess app/etc; /bin/chmod -R o+w media",
    require => Exec["untar-magento"],
  }

  host { 'magento.localhost':
        ip => '127.0.0.1',
  }

  exec { "install-magento":
    cwd => "${apache2::document_root}/magento",
    creates => "${apache2::document_root}/magento/app/etc/local.xml",
    command => "/usr/bin/php -f install.php -- \
    --license_agreement_accepted \"yes\" \
    --locale \"de_DE\" \
    --timezone \"Europe/Berlin\" \
    --default_currency \"EUR\" \
    --db_host \"localhost\" \
    --db_name \"magentodb\" \
    --db_user \"${db_username}\" \
    --db_pass \"${db_password}\" \
    --url \"http://magento.localhost:8080/magento\" \
    --use_rewrites \"${use_rewrites}\" \
    --use_secure \"no\" \
    --secure_base_url \"http://magento.localhost:8080/magento\" \
    --use_secure_admin \"no\" \
    --skip_url_validation \"yes\" \
    --admin_firstname \"Store\" \
    --admin_lastname \"Owner\" \
    --admin_email \"magento@example.com\" \
    --admin_username \"${admin_username}\" \
    --admin_password \"${admin_password}\"",
    require => [Exec["setting-permissions"], Exec["create-magentodb-db"]],
  }

}
