# logwatch.pp
#
# Installs and sets up a logwatch.

class logwatch($logwatch_email = 'root', $frequency = 'weekly') {
  # Make sure the logwatch package is installed
  package { 'logwatch':
    ensure => 'present'
  }

  ## And the configuration file, but the configuration file
  ## gets installed after the package, so it overwrites
  file { '/etc/logwatch/conf/logwatch.conf.erb':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    content => template('logwatch/logwatch.conf.erb'),
    require => Package['logwatch'],
  }

  file { '/etc/logwatch/conf/ignore.conf':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///logwatch/ignore.conf',
    require => Package['logwatch'],
  }

  file { '/etc/logwatch/conf/override.conf':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///logwatch/override.conf',
    require => Package['logwatch'],
  }

  ## Cron Entry for logrotate to run
  #
  case ($frequency) {
    'weekly': {
      file { '/etc/cron.weekly/00logwatch':
        ensure  => file,
        mode    => 0755,
        owner   => 'root',
        group   => 'root',
        content => template('logwatch/00logwatch.erb'),
      }

      file { '/etc/cron.daily/00logwatch':
        ensure  => absent,
      }
    }
    'daily': {
      file { '/etc/cron.weekly/00logwatch':
        ensure  => absent,
      }

      file { '/etc/cron.daily/00logwatch':
        ensure  => file,
        mode    => 0755,
        owner   => 'root',
        group   => 'root',
        content => template('logwatch/00logwatch.erb'),
      }
    }
    default: {
      fail "frequency '${frequency}' not supported for logwatch module."
    }
  }



  ## Logwatch requires this directory to Cache
  #
  file { '/var/cache/logwatch':
    ensure  => 'directory',
    mode    => 0744,
    owner   => 'root',
    group   => 'root',
  }
}
