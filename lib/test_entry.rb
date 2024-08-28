class TestEntry
  class << TestEntry
    def getEmptyTestEntry
      testEntry = {
          'Date'=> '',
          'EO-MT'=> [],
          'TestReport'=> [],
          'ENM'=> [],
          'EO-SO'=> [],
          'EO-CM'=> [],
          'VNF-LCM-Versions'=> [],
          'Scale-In-And-Out'=> [],
          'Real-VNF-Test'=> [],
          'Real-VNF Packages'=> [],
          'EO-Policy Framework'=> [],
          'Dummy-Package'=> [],
          'Dummy-Image-Deployed'=> [],
          'Dummy-Workflow-Version'=> [],
          'Status'=> ''
      }
    end
  end
end