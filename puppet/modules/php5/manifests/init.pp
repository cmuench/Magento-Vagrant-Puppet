class php5 {
   package { 
	["php5-cli", "php5-common", "php5-mysql", "php5-curl", "php5-gd", "php5-intl", "php5-mcrypt"]: 
 	ensure => latest 
   }
   package { 
        ["libapache2-mod-php5"]: 
        ensure => latest 
   }
}
