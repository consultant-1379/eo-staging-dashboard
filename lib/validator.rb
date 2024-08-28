class Validator
  def validateInformation(info)

    validEntries = ['Date', 'EO-MT', 'TestReport', 'ENM', 'EO-SO', 'EO-CM',
                    'VNF-LCM-Versions', 'Real-VNF Packages',
                    'Dummy-Package', 'Dummy-Image-Deployed',
                    'Dummy-Workflow-Version', 'Status'
    ]

    validEntries.each do |entry|
      if info[entry] == nil
        raise "Missing attribute: " + entry
      end
    end
  end
end