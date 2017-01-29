require 'spec_helper'
describe 'ax25_repos' do

  context 'with defaults for all parameters' do
    it { should contain_class('ax25_repos') }
  end
end
