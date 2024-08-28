require 'httparty'
require 'logger'
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'json'

class Confluence
  @confluence_links = []

  def initialize
    @blue_row = get_confluence_page_blue_row.split(',')
  end

  def get_vnflcm_version_information
    index = 0
    vnflcm_versions_information = []
    vnflcm_versions_links = @confluence_links[6].reverse
    @blue_row[6].split('-').each do |vnflcm_version|
      if index == 0 #skipping as this version never has a link in the confluence page
        vnflcm_versions_information.push({'artifact' => vnflcm_version, 'link' => '', 'newEntry' => false})
      else
        vnflcm_versions_information.push({'artifact' => vnflcm_version, 'link' => vnflcm_versions_links[index - 1], 'newEntry' => false})
      end
      index += 1
    end
    return vnflcm_versions_information
  end

  def get_real_vnf_packages_information
    return get_confluence_cell_information(9)
  end

  def get_dummy_package_information
    return get_confluence_cell_information(10)
  end

  def get_dummy_image_deployed_information
    return get_confluence_cell_information(11)
  end

  def get_confluence_cell_information(cellIndex)
    artifacts = processZipFileArtifacts(@blue_row[cellIndex])
    artifacts_information = []
    artifacts_links = @confluence_links[cellIndex]
    index = 0
    unless artifacts.eql? nil
      artifacts.each do |artifact|
        artifacts_information.push({'artifact' => artifact, 'link' => "https://confluence-nam.lmera.ericsson.se#{artifacts_links[index]}", 'newEntry' => false})
        index += 1
      end
    end
    return artifacts_information
  end

  def get_dummy_workflow_version_information
    return [{'artifact' => @blue_row[12], 'link' => @confluence_links[12][0], 'newEntry' => false}]
  end

  def processZipFileArtifacts(artifacts)
    logger = Logger.new('/proc/1/fd/1')
    logger.info(artifacts)
    processArtifactList = []
    unless artifacts.eql? '""'
      artifacts.split('.zip').each do |artifact|
        processArtifactList.push(artifact + '.zip')
      end
      return processArtifactList
    end
  end

  def get_confluence_page_blue_row
    begin
      logger = Logger.new('/proc/1/fd/1')
      auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
      response = HTTParty.get(ENV['CONFLUENCE_URL'], basic_auth: auth)
      confluencePage = Nokogiri::HTML(response)
      tables = confluencePage.search('table')
      table = tables.last
      cells = table.search('tr')[1].search('td')
      @confluence_links = get_confluence_links(cells)
      splitCellInformation = CSV.generate_line(cells)
      return splitCellInformation
    rescue => e
      raise SpinnakerConnectionException, "Could not get information from confluence, details: #{e}"
    end
  end

  def get_confluence_links(cells)
    links = []
    logger = Logger.new('/proc/1/fd/1')
    cells.each do |cell|
      allLinks = cell.css('a')
      links.push(allLinks.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?})
    end
    return links
  end
end

class SpinnakerConnectionException < StandardError
end
