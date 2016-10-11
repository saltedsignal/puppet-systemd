# -- Class systemd  
# This module allows triggering systemd commands once for all modules 
class systemd (
  $service_limits    = {},
  $journald_settings = {},
){

  Exec {
    refreshonly => true,
    path        => $::path,
  }

  exec {
    'systemctl-daemon-reload':
      command => 'systemctl daemon-reload',
  }

  exec {
    'systemd-tmpfiles-create':
      command => 'systemd-tmpfiles --create',
  }

  create_resources('systemd::service_limits', $service_limits, {})

  # https://www.freedesktop.org/software/systemd/man/journald.conf.html
  service{'systemd-journald':
    ensure => running,
  }
  if !empty($journald_settings) {
    $journald_defaults = {
      'path'   => '/etc/systemd/journald.conf',
      'notify' => Service['systemd-journald'],
    }
    # All options are configured in the "[Journal]" section
    $journald_ini_settings = {
      'Journal' => $journald_settings,
    }
    create_ini_settings($journald_ini_settings, $journald_defaults)
  }
}
