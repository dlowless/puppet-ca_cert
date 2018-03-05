require 'spec_helper'
require 'pp'
describe 'ca_cert::update', :type => :class do

  pp on_supported_os
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ca_cert::params') }

      case facts[:osfamily]
      when 'Debian'
        it { is_expected.not_to contain_exec('enable_ca_trust') }
        it { is_expected.to contain_exec('ca_cert_update').with(
          :command     => 'update-ca-certificates',
          :refreshonly => true,
        )}
      when 'RedHat'
        if facts[:operatingsystemrelease] == '7.0'
          it { is_expected.not_to contain_exec('enable_ca_trust') }
        else
          it { is_expected.to contain_exec('enable_ca_trust').with_command('update-ca-trust enable') }
        end
        it { is_expected.to contain_exec('ca_cert_update').with(
          :command     => 'update-ca-trust extract',
          :refreshonly => true,
        )}
      when 'Suse'
        it { is_expected.not_to contain_exec('enable_ca_trust') }
        case facts[:operatingsystemmajrelease]
        when '10','11'
          it { is_expected.to contain_exec('ca_cert_update').with(
            :command     => 'c_rehash',
            :refreshonly => true,
          )}
        when '12','13','42'
          it { is_expected.to contain_exec('ca_cert_update').with(
            :command     => 'update-ca-certificates',
            :refreshonly => true,
          )}
        end
      end
    end
  end
end
