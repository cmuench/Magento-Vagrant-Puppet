class { "apache2":
    document_root => "/vagrant",
}

/**
 * MySQL Config
 */
class { "mysql":
    root_password => "root",
}

/**
 * Magento config
 */
class { "magento":
    /* magento version */
    version        => "1.6.1.0",

    /* magento database settings */
    db_username    => "magento",
    db_password    => "magento",

    /* magento admin user */
    admin_username => "admin",
    admin_password => "123123abc",

    /* "yes|no */
    use_rewrites   => "no",
}

/**
 * Import modules
 */
include apt
include mysql
include apache2
include php5
include magento
