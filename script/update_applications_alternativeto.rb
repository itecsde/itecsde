

#First, change hash_resource to force applications to be updated

Application.where(:scraped_from => "http://alternativeto.net").each do |application|
  application.hash_resource = "xxxxxxxxxx"
  application.save
end

scrape_applications = ScraperApplications.new
scrape_applications.scrape_alternativeto_all