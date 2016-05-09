classify = Classify.new

#reuters_sections = ["Business", "Technology", "Science", "Health", "Sport", "Art", "Fashion", "Politics", "Education", "Culture", "Economy"]        
      
sections = ["Business", "Technology", "Science", "Health", "Sport", "Art", "Fashion", "Politics", "Economy"]

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("basic",sections,true,0)
classify.classify_stored_reports("basic",sections,true,0)
classify.classify_stored_reports("basic",sections,true,0)
classify.reuters_statistics("basic")

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("basic",sections,true,"gravitational center")
classify.classify_stored_reports("basic",sections,true,"gravitational center")
classify.classify_stored_reports("basic",sections,true,"gravitational center")
classify.reuters_statistics("basic")

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("with_weight",sections,true,0)
classify.classify_stored_reports("with_weight",sections,true,0)
classify.classify_stored_reports("with_weight",sections,true,0)
classify.reuters_statistics("with_weight")

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("with_weight",sections,true,"gravitational center")
classify.classify_stored_reports("with_weight",sections,true,"gravitational center")
classify.classify_stored_reports("with_weight",sections,true,"gravitational center")
classify.reuters_statistics("with_weight")

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("without_countries",sections,true,0)
classify.classify_stored_reports("without_countries",sections,true,0)
classify.classify_stored_reports("without_countries",sections,true,0)
classify.reuters_statistics("without_countries")

Report.all.each do |report|
   report.section = nil
   report.save
end

classify.classify_stored_reports("without_countries",sections,true,"gravitational center")
classify.classify_stored_reports("without_countries",sections,true,"gravitational center")
classify.classify_stored_reports("without_countries",sections,true,"gravitational center")
classify.reuters_statistics("without_countries")

