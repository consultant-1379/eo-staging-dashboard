require 'yaml'
require 'logger'
require_relative '../lib/formatter'
require_relative '../lib/validator'
ROW_LIMIT = 6

SCHEDULER.every '1m', :first_in => 0 do
  getTestInformation
end

def getTestInformation
  headerRow = getTableHeaders
  testData = YAML.load_file("info.yaml")
  rows = getRowInfomation(testData)
  send_event('data-table', {hrows: headerRow, rows: rows})
end

def getTableHeaders
  headerRow = [
      { cols: [ {value: 'Date'},
                {value: 'EO-MT Version'},
                {value: 'Test Report'},
                {value: 'ENM'},
                {value: 'EO-SO'},
                {value: 'EO-CM'},
                {value: 'VNF-LCM'},
                {value: 'Real VNF Packages'},
                {value: 'Dummy Package'},
                {value: 'Dummy Image Deployed'},
                {value: 'Dummy Workflow Version'}
      ]}
  ]
  return headerRow
end

def getRowInfomation(testData)
  rows = []
  logger = Logger.new('/proc/1/fd/1')
  counter = 0
  testEntryIndex = 0
  @validator = Validator.new
  while counter < ROW_LIMIT
    info = testData[testEntryIndex]
    begin
      @validator.validateInformation(info)
      styleClass = info["Status"].downcase

      row = {class: styleClass,
             cols: [ {value: info['Date']},
                     {value: Formatter.formatTestArtifact(info['EO-MT'])},
                     {value: Formatter.formatTestArtifact(info['TestReport'])},
                     {value: Formatter.formatTestArtifact(info['ENM'])},
                     {value: Formatter.formatTestArtifact(info['EO-SO'])},
                     {value: Formatter.formatTestArtifact(info['EO-CM'])},
                     {value: Formatter.formatTestArtifact(info['VNF-LCM-Versions'])},
                     {value: Formatter.formatTestArtifact(info['Real-VNF Packages'])},
                     {value: Formatter.formatTestArtifact(info['Dummy-Package'])},
                     {value: Formatter.formatTestArtifact(info['Dummy-Image-Deployed'])},
                     {value: Formatter.formatTestArtifact(info['Dummy-Workflow-Version'])}
             ]}
      rows.push(row)
    rescue StandardError => error
      logger.warn("Error formatting data: " + info.to_s + "Cause: " + error.message)
      counter -= 1 #this is in place so the table will still show 6 entries even if some rows have errors
    end
    counter += 1
    testEntryIndex += 1
  end
  return rows
end
