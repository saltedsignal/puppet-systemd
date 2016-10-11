require 'spec_helper'

describe 'systemd' do

  let(:facts) { {
      :path => '/usr/bin',
  } }

  context 'with default' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_exec('systemctl-daemon-reload').with(
      :command     => 'systemctl daemon-reload',
      :refreshonly => true,
      :path        => '/usr/bin',
    )}

    it { is_expected.to contain_exec('systemd-tmpfiles-create').with(
      :command     => 'systemd-tmpfiles --create',
      :refreshonly => true,
      :path        => '/usr/bin',
    )}
    it { is_expected.to contain_service('systemd-journald').with(
      :ensure => 'running',
    ) }
    it { is_expected.to have_ini_setting_resource_count(0) }
  end
  context 'with journald options' do
    let(:params){
      {
        :journald_settings => {
          'Storage'         => 'auto',
          'MaxRetentionSec' => '5day',
        }
      }
    }
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_service('systemd-journald').with(
      :ensure => 'running'
    ) }
    it { is_expected.to have_ini_setting_resource_count(2) }
    it { is_expected.to contain_ini_setting('/etc/systemd/journald.conf [Journal] Storage').with(
      :path    => '/etc/systemd/journald.conf',
      :section => 'Journal',
      :notify  => 'Service[systemd-journald]',
      :value   => 'auto',
    )}
    it { is_expected.to contain_ini_setting('/etc/systemd/journald.conf [Journal] MaxRetentionSec').with(
      :path    => '/etc/systemd/journald.conf',
      :section => 'Journal',
      :notify  => 'Service[systemd-journald]',
      :value   => '5day',
    )}
  end
end
