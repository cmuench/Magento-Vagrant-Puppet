class apt {
    exec { "/usr/bin/aptitude -y safe-upgrade":
         refreshonly => true,
    }
}
