class Formatter
  class << Formatter
    def formatTestArtifact(testArtifact)
      artifactsList = "<ul>"
      testArtifact.each do |entry|
        artifactsList += "<li>"

        if entry['link'] != nil
          artifactsList += "<a class='link' href='" + entry['link'] + "'>" + formatIfNewEntry(entry['newEntry'], entry['artifact']) + "</a>"
        else
          artifactsList += formatIfNewEntry(entry['newEntry'], entry['artifact'])
        end

        artifactsList += "</li>"
      end
      artifactsList += "</ul>"
      return artifactsList
    end

    def formatIfNewEntry(newEntry, entry)
      if newEntry
        return "<b>" + entry + "</b>"
      else
        return entry
      end
    end

    def formatDataIntoMapEntry(dataList)
      mapEntryList = []
      dataList.each do |dataEntry|
        mapEntry = {'artifact' => dataEntry, 'link' => '', 'newEntry' => false}
        mapEntryList.push(mapEntry)
      end
      return mapEntryList
    end
  end
end