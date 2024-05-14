# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Elm do
    let(:project_path) { Pathname('/fake/path') }
    subject { Elm.new(project_path:) }

    it_behaves_like 'a PackageManager'

    describe '.current_packages' do
      it 'lists all the current packages' do
        elm_json = fixture_from('elm.json')
        json_elm_json = fixture_from('elm/json/elm.json')
        core_elm_json = fixture_from('elm/core/elm.json')

        allow(ENV).to receive(:[]).with('HOME') { '/Users/home' }
        allow(ENV).to receive(:[]).with('ELM_HOME') { nil }

        allow(FileTest).to receive(:exist?).and_return(true)

        allow(File).to receive(:read).with(project_path.join('elm.json')) { elm_json }
        allow(File).to receive(:read).with('/Users/home/.elm/0.19.1/packages/elm/json/1.1.3/elm.json') { json_elm_json }
        allow(File).to receive(:read).with('/Users/home/.elm/0.19.1/packages/elm/core/1.0.5/elm.json') { core_elm_json }

        expect(subject.current_packages.map(&:name)).to eq %w[json core]
        expect(subject.current_packages.map(&:author)).to eq %w[elm elm]
        expect(subject.current_packages.map(&:version)).to eq ['1.1.3', '1.0.5']
      end
    end

    it 'should return the correct prepare command' do
      expect(subject.prepare_command).to eq('elm install')
    end
  end
end
