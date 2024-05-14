# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Elm < PackageManager
    def current_packages
      elm_json_content = JSON.parse File.read(detected_package_path)
      elm_version = elm_json_content['elm-version']
      packages = packages_from_json(elm_json_content, elm_version)
    end

    def prepare_command
      'elm install'
    end

    def possible_package_paths
      [project_path.join('elm.json')]
    end

    private

    def packages_from_json(elm_json, elm_version)
      packages = (elm_json.dig('dependencies', 'direct') || {})
        .merge(elm_json.dig('dependencies', 'indirect') || {})
        .map do |(author_name, version)|
          author, name = author_name.split('/')
          package_elm_json = find_package_elm_json(elm_version, author, name, version)
          ElmPackage.from_elm_json(name, version, author, package_elm_json)
        end
    end

    def find_package_elm_json(elm_version, author, name, version)
      path = File.join(ENV['ELM_HOME'] || ENV['HOME'], '.elm', elm_version, 'packages', author, name, version, 'elm.json')
      JSON.parse File.read(path)
    end
  end
end
