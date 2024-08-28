require File.expand_path('../../lib/spinnaker', __FILE__)
require File.expand_path('../../lib/jenkins', __FILE__)
require File.expand_path('../../lib/confluence', __FILE__)
require File.expand_path('../../lib/test_entry', __FILE__)
require File.expand_path('../../lib/formatter', __FILE__)
require 'logger'
require 'date'

SPINNAKER_PIPELINES = [
    '2fc11ad1-a672-42cf-aa41-ea86b6afec16', # 1. ECM & LCM Initial Install
    'dfd52a0b-2dbb-43c8-b0f8-4216bd6eab7b', # 2. SO Upgrade
    '74e9275e-7637-4c3a-9446-641e495ec42b', # 3. Full Int. Tests case
    '3a552cf9-e456-4695-9217-be48d104d405'  # 4. LCM Upgrade
]

SO = 'SO_deploy_onwards'
ECM = 'ecm-release-promotion'
WANO = 'WANO_baseline_Release'
POLICY_FRAMEWORK = 'sd-baseline-packaging_Release'
FULL_INT_TEST = 'Full Integration test cases'
LCM = 'LCM Upgrade'
LOGGER = Logger.new('/proc/1/fd/1')

SCHEDULER.every '1m', :first_in => 0 do
  SPINNAKER_PIPELINES.each do |spinnakerPipeline|
    LOGGER.info(spinnakerPipeline)
    spinnakerResponse = Spinnaker.retrieve_json("#{ENV['SPINNAKER_URL']}/executions?pipelineConfigIds=#{spinnakerPipeline}")
    testInfo = YAML.load_file('/usr/dashboard/info.yaml')
    date = DateTime.now
    testInfo[0]['Date'] = date.strftime("%d/%m/%Y")
    unless spinnakerResponse[0].eql? nil
      if spinnakerResponse[0]['name'].eql? FULL_INT_TEST
        processSpinnakerResponse('Dummy-Image-Deployed', testInfo, spinnakerResponse)
        processSpinnakerResponse('Dummy-Workflow-Version', testInfo, spinnakerResponse)
      elsif spinnakerResponse[0]['name'].eql? LCM
        processSpinnakerResponse('VNF-LCM-Versions', testInfo, spinnakerResponse)
      elsif spinnakerResponse[0]['name'].eql? SO
        processSpinnakerResponse('EO-SO', testInfo, spinnakerResponse)
      elsif spinnakerResponse[0]['trigger']['buildInfo']['name'].eql? ECM
        processSpinnakerResponse('EO-CM', testInfo, spinnakerResponse)
      end
    end
    retrieveInformationFromConfluence(testInfo)
  end
end

def retrieveInformationFromConfluence(testInfo)

  confluence = Confluence.new
  # This method retrieves information from the EO-MT Confluence page to fill in the gaps of data that are currently present
  #ENM VERSION
  testInfo[0]['ENM'] = [{'artifact' => 'ENM 18.18 (ISO Version: 1.67.83)', 'newEntry' => false}]

  #Real VNF Packages
  testInfo[0]['Real-VNF Packages'] = confluence.get_real_vnf_packages_information

  #Dummy package
  testInfo[0]['Dummy-Package'] = confluence.get_dummy_package_information

  writeTestInfoToFile(testInfo)
end

def processSpinnakerResponse(testArtifact, testInfo, spinnakerResponse)

  if testArtifact.eql? 'EO-CM'
    version = Jenkins.get_ecm_release_version_from_jenkins_console(spinnakerResponse[0]['trigger']['buildInfo']['url'])
    testInfo[0][testArtifact] = [{
                                     'artifact' => "R#{version}",
                                     'link' => "https://arm.epk.ericsson.se/artifactory/proj-ecm-product-generic-local/ecm/product/all/#{version}/"
                                 }]
  elsif testArtifact.eql? 'EO-SO'
    jenkinsLink = spinnakerResponse[0]['stages'][1]['context']['buildInfo']['url']
    version = Jenkins.get_SO_version_from_jenkins_console(jenkinsLink)
    testInfo[0][testArtifact] = [{
                                     'artifact' => "#{version}",
                                     'link' => "https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-adp-helm-dev-generic-local/cd/sandbox/eso/baseline/eric-eo-so-#{version}.tgz"
                                 }]
  elsif testArtifact.eql? 'Dummy-Image-Deployed'
    jenkinsLink = spinnakerResponse[0]['stages'][0]['context']['buildInfo']['url']
    version = Jenkins.get_dummy_image_from_jenkins_console(jenkinsLink)
    testInfo[0][testArtifact] = [{
                                     'artifact' => "#{version}",
                                     'link' => "https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/service/local/repositories/releases/content/com/ericsson/oss/vnflaf/images/ERICrhelvnflafimage_CXP9032490/4.8.13/#{version}"
                                 }]
  elsif testArtifact.eql? 'Dummy-Workflow-Version'
    jenkinsLink = spinnakerResponse[0]['stages'][0]['context']['buildInfo']['url']
    dummy_workflow_info = Jenkins.get_dummy_workflow_from_jenkins_console(jenkinsLink)
    testInfo[0][testArtifact] = [{
                                     'artifact' => "#{dummy_workflow_info['version']}",
                                     'link' => "#{dummy_workflow_info['link']}"
                                 }]
  elsif testArtifact.eql? 'VNF-LCM-Versions'
    jenkinsLink = spinnakerResponse[0]['trigger']['buildInfo']['url']
    vnf_info = Jenkins.get_vnf_version_from_jenkins_console(jenkinsLink)
    testInfo[0][testArtifact] = [{
                                     'artifact' => "#{vnf_info['version']}",
                                     'link' => "#{vnf_info['link']}"
                                 }]
  else
    testInfo[0][testArtifact] = [{
                                     'artifact' => "Jenkins: ##{buildNumberFromSpinnaker}",
                                     'link' => spinnakerResponse[0]['trigger']['buildInfo']['url']
                                 }]
  end
  writeTestInfoToFile(testInfo)
end

def writeTestInfoToFile(testInfo)
  f = File.open('/usr/dashboard/info.yaml', 'w')
  f.write(testInfo.to_yaml)
  f.close
end
