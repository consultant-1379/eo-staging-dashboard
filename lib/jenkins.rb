require 'httparty'
require 'logger'

class Jenkins
  class << Jenkins
    def retrieve_artifacts_file(full_url)
      begin
        auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
        response = HTTParty.get("#{full_url}/artifact/artifact.properties/*view*/", basic_auth: auth)
        return response
      rescue => e
        raise JenkinsConnectionException, "Could not get artifacts file from Jenkins #{full_url}, details: #{e}"
      end
    end

    def get_ecm_release_version_from_jenkins_console(full_url)
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      version = response.match(/(\+ ssh 10.36.249.100 cp -r \/proj\/ecm\/ci\/VMs\/ECM_PACKAGE_BUILD_NIGHTLY).+/).to_s.split(' ')[6].split('/')[5]
      version.sub! 'R', ''
      return version
    end

    def get_policy_framework_release_version_from_jenkins_console(full_url)
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      responses = response.scan(/Removing.+/)
      version = responses[responses.size - 2]
      version.sub! 'Removing sd-', ''
      version.sub! '.tgz', ''
      return version
    end

    def get_SO_version_from_jenkins_console(full_url)
      logger = Logger.new('/proc/1/fd/1')
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      version = response.match(/SO_VERSION\s+.+/)[0].scan(/[^,]*/)[0]
      version = version.split("\n")[1].to_s.split(': ')[1]
      logger.info(version.to_s)
      return version
    end

    def get_dummy_image_from_jenkins_console(full_url)
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      version = response.match(/SERVICES_IMAGE_NAME.+/)[0].scan(/[^,]*/)[0].to_s.split(':')[1]
      version.gsub! '"', ''
      return version + ".qcow2"
    end

    def get_dummy_workflow_from_jenkins_console(full_url)
      dummy_workflow_info = {'link' => '', 'version' => ''}
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      link= response.match(/RPM_BUNDLE_LINK.+/)[0].scan(/[^,]*/)[0]
      link = link.sub! 'RPM_BUNDLE_LINK', ''
      link = link.gsub! '"', ''
      dummy_workflow_info['version'] = link.scan(/[^-]*/)[4].to_s.sub! '.rpm', ''
      dummy_workflow_info['link'] = "https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/content/groups/public/com/ericsson/vnflcm/examples/workflows/ERICvnflaf_CXP123456/#{dummy_workflow_info['version']}/ERICvnflaf_CXP123456-#{dummy_workflow_info['version']}.rpm"

      return dummy_workflow_info
    end

    def get_vnf_version_from_jenkins_console(full_url)
      vnf_info = {'version'=>'', 'link'=>''}
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get("#{full_url}consoleText", basic_auth: auth)
      version = response.match(/Latest version of Media available in Nexus:.+/)[0].to_s.split(': ')[1]
      version = version.sub ',', '.'
      vnf_info['version'] = version
      vnf_info['link'] = "https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/service/local/repositories/releases/content/com/ericsson/oss/vnflaf/media/ERICvnflcmossrcatlas_CXP9034147/#{version}/ERICvnflcmossrcatlas_CXP9034147-#{version}.tar"
      return vnf_info
    end
  end
end

class JenkinsConnectionException < StandardError
end