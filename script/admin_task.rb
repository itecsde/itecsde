STDOUT.sync = true

require 'rubygems'

if ARGV[0] != nil && ARGV[0].start_with?("{") && ARGV[0].end_with?("}")
  puts  "Beginning admin_task"
  input_arguments = eval(ARGV[0])
  puts input_arguments

  task = input_arguments[:task]
  element_type = input_arguments[:element_type]
  provider = input_arguments[:url]
  place = input_arguments[:place]
  split = input_arguments[:split]

  rss_blog_feed = input_arguments[:rss_blog_feed]
  rss_report_feed = input_arguments[:rss_report_feed]
  rss_article_feed = input_arguments[:rss_article_feed]

  slice_size = input_arguments[:slice_size]
  if slice_size == nil
      slice_size = 10000
  end

  scraper_reports = ScraperReports.new
  scraper_applications = ScraperApplications.new
  scraper_people = ScraperPeople.new
  scraper_events = ScraperEvents.new
  scraper_lectures = ScraperLectures.new
  scraper_sites = ScraperSites.new
  scraper_documentaries = ScraperDocumentaries.new
  scraper_slideshows = ScraperSlideshows.new
  scraper_posts = ScraperBlogs.new
  scraper_biographies = ScraperBiographies.new
  scraper_lres = ScraperLres.new
  scraper_courses = ScraperCourses.new
  scraper_articles = ScraperArticles.new
  scraper = Scraper.new

  if rss_report_feed != nil && task == nil
    Thread.new do
      begin
        scraper.scrape_rss_feed(rss_report_feed,"Report")
      rescue
      end
    end
  elsif rss_blog_feed != nil && task == nil
    Thread.new do
      begin
        scraper.scrape_rss_feed(rss_blog_feed,"Post")
      rescue
      end
    end
  elsif rss_article_feed != nil && task == nil
    Thread.new do
      begin
        scraper.scrape_rss_feed(rss_article_feed,"Article")
      rescue
      end
    end
  end

  if task == "scrape"
    if provider != nil
      source = Source.find_by_source_type_and_url(element_type,provider)
      case element_type
      when "Event"
        Thread.new do
          begin
            scraper_events.send(source.name)
          rescue
          end
        end
      when "People"
        Thread.new do
          begin
            scraper_people.send(source.name)
          rescue
          end
        end
      when "Application"
        Thread.new do
          begin
            scraper_applications.send(source.name)
          rescue
          end
        end
      when "Lecture"
        Thread.new do
          begin
            scraper_lectures.send(source.name)
          rescue
          end
        end
      when "Documentary"
        Thread.new do
          begin
            scraper_documentaries.send(source.name)
          rescue
          end
        end
      when "Biography"
        Thread.new do
          begin
            scraper_biographies.send(source.name)
          rescue
          end
        end
      when "Course"
        Thread.new do
          begin
            scraper_course.send(source.name)
          rescue
          end
        end
      when "Article"
        Thread.new do
          begin
            if source.name.include? "scrape_"
            scraper_articles.send(source.name)
            else
              scraper.scrape_rss_feed(provider,"Article")
            end
          rescue
          end
        end
      when "Lre"
        Thread.new do
          begin
            scraper_lres.send(source.name)
          rescue
          end
        end
      when "Post"
        Thread.new do
          begin
            scraper.scrape_rss_feed(provider,"Post")
          rescue
          end
        end
      when "Slideshow"
        Thread.new do
          begin
            scraper_slideshows.send(source.name)
          rescue
          end
        end
      when "Site"
        Thread.new do
          begin
            if provider.include? "tripadvisor"
              scraper_sites.send("scrape_tripadvisor",place)
            else
            scraper_sites.send(source.name)
            end
          rescue
          end
        end
      when "Report"
        Thread.new do
          begin
            scraper.scrape_rss_feed(provider,"Report")
          rescue
          end
        end
      end
    elsif provider == nil
      #scrapeamos todas las sources de un mismo tipo
      sources_to_scrape_array = Source.where(:source_type => element_type)
      case element_type
      when "Report"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper.scrape_rss_feed(source_to_scrape.url,"Report")
            rescue
            end
          end
        end
      when "Site"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              if source_to_scrape.name.include? "tripadvisor"
                scraper_sites.send("scrape_tripadvisor",source_to_scrape.name.split("|")[1].strip)
              else
              scraper_sites.send(source_to_scrape.name)
              end
            rescue
            end
          end
        end
      when "Event"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_events.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Lecture"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_lectures.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Documentary"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_documentaries.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Course"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_courses.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Article"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              if source_to_scrape.name.include? "scrape_"
              scraper_articles.send(source_to_scrape.name)
              else
                scraper.scrape_rss_feed(source_to_scrape.url,"Article")
              end
            rescue
            end
          end
        end
      when "Lre"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_lres.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Application"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_applications.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Post"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper.scrape_rss_feed(source_to_scrape.url,"Post")
            rescue
            end
          end
        end
      when "Slideshow"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_slideshows.send(source_to_scrape.name)
            rescue
            end
          end
        end
      when "Biography"
        sources_to_scrape_array.each do |source_to_scrape|
          Thread.new do
            begin
              scraper_biographies.send(source_to_scrape.name)
            rescue
            end
          end
        end
      end
    end
  ##################################     TASK = FORCE_TAG     ###################################
  elsif task == "force_tag"
    if provider != nil
      puts "Proceding to "+ task +" "+ element_type + " of " + provider
      resources_array = element_type.constantize.where(:scraped_from => provider)
    else
      puts "Proceding to "+ task +" all "+ element_type
      resources_array = element_type.constantize.all
    end
    begin
      threads = []

      
      # For each resource
      resources_array.each_slice(slice_size) do |slice|
        puts "ANTES DEL THREAD"
        threads <<  Thread.new do
          puts "NEW THREAD"
          slice.each do |resource|
            task = Task.new "annotate", resource
            Broker.instance.queue << task
            puts "Task " + "annotate " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"
=begin
            puts "Proceding to annotate resource: "+ element_type + " " + resource.id.to_s
            # Gets its manual tags
            manual_tags = Array.new
            resource.taggable_tag_annotations.where(:type_tag => "human").each do |annotation|
              manual_tags << annotation.tag.name
            end
            # Deletes previous semantic annotations
            resource.taggable_tag_annotations.where(:type_tag => ["automatic", "automatic_from_human"]).each do |annotation|
              annotation.destroy
            end
            # Annotates the resource again
            if resource.info_to_wikify == nil
            resource.info_to_wikify = resource.description
            end
            resource.extract_wikitopics(resource.name, resource.info_to_wikify, manual_tags)
            puts "Resource annotated successfully"
=end

          end
          puts " COMPLETED THREAD!!"
        end
      end
      threads.each do |thread|
        thread.join
        if thread[:exception]
        end
      end
      sleep(120)

    rescue Exception => e
      puts "Error while annotating resource "+ element_type
      puts e.message
      puts e.backtrace.inspect
    end

  ##################################     TASK = TAG     ###################################
  elsif task == "tag"
     
    if provider != nil
       puts "Proceding to "+ task +" "+ element_type + " of " + provider
       resources_array = element_type.constantize.where(:scraped_from => provider)
    else
       puts "Proceding to "+ task +" all "+ element_type
       resources_array = element_type.constantize.all
    end
    
    begin
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|
             if resource.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human"]).size == 0             
                task = Task.new "annotate", resource
                Broker.instance.queue << task
                puts "Task " + "annotate " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"
             else
                puts resource.class.to_s + " " + resource.id.to_s + " already annotated!"
             end
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
       sleep(120)
    rescue Exception => e
       puts "Error while annotating resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end
    
  elsif task == "classify"
     
    if provider != nil
       puts "Proceding to "+ task +" "+ element_type + " of " + provider
       resources_array = element_type.constantize.where(:scraped_from => provider)
    else
       puts "Proceding to "+ task +" all "+ element_type
       resources_array = element_type.constantize.all
    end
    
    begin
       #$cities_and_countries = Classify.generate_countries_and_cities
       $countries = Classify.generate_countries
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|       
             task = Task.new "classify", resource
             Broker.instance.queue << task
             puts "Task " + "classify " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"            
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
    rescue Exception => e
       puts "Error while annotating resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end    

  elsif task == "obtain_centroid_based_weight"
     
    puts "Proceding to "+ task +" all "+ element_type
    resources_array = element_type.constantize.all
 
    begin
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|       
             task = Task.new "obtain_centroid_based_weight", resource
             Broker.instance.queue << task
             puts "Task " + "obtain_centroid_based_weight " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"            
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
    rescue Exception => e
       puts "Error while obtain_centroid_based_weight resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end

  elsif task == "concept_language_correspondence"
     
    puts "Proceding to "+ task +" all "+ element_type
    resources_array = element_type.constantize.all
 
    begin
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|       
             task = Task.new "concept_language_correspondence", resource
             Broker.instance.queue << task
             puts "Task " + "concept_language_correspondence " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"            
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
    rescue Exception => e
       puts "Error while concept_language_correspondence resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end    
    
    
  elsif task == "annotate_esa"
     
    puts "Proceding to "+ task +" all "+ element_type
    resources_array = element_type.constantize.all
 
    begin
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|       
             task = Task.new "annotate_esa", resource
             Broker.instance.queue << task
             puts "Task " + "annotate_esa " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"            
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
    rescue Exception => e
       puts "Error while annotate_esa resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end      
    
           
  elsif task == "expand_concepts"
    
     
    #Todos los elementos de un element_type 
    #puts "Proceding to "+ task +" all "+ element_type
    #resources_array = element_type.constantize.all
    
    #los 100 primeros y 500 ultimos elementos de cada cat para hacer un ohsumed lite
   
=begin   
    puts "Proceding to "+ task +" ohsumed_lite(100,500) "+ element_type
    
    resources_array = Array.new
    
    categories_ohsumed = ["Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"]
    
    categories_ohsumed.each do |category|
       ReutersNewItem.where(:topics => category, :cgisplit => "training").first(100).each do |resource|
          resources_array << resource
       end       
    end
       
    categories_ohsumed.each do |category|
       ReutersNewItem.where(:topics => category, :cgisplit => "test").first(500).each do |resource|
          resources_array << resource
       end       
    end
      
=end     
=begin      
    puts "Proceding to "+ task +" ieee_0.6_0.6_ "+ element_type
    
    resources_array = Array.new
    
    categories_ieee = ["Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience", "Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"]     
    
    categories_ieee.each do |category|
       ReutersNewItem.where(:topics => category).first(553).each do |resource|
          resources_array << resource
       end       
    end    
=end
=begin
   
    puts "Proceding to "+ task +" ohsumed_0.7_0.7 "+ element_type
    
    resources_array = Array.new
    
    categories_ohsumed = ["Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"]
    
    categories_ohsumed.each do |category|
       ReutersNewItem.where(:topics => category, :cgisplit => "training").all.each do |resource|
          resources_array << resource
       end       
    end
    
=end       


   
=begin
    puts "Proceding to "+ task +" 20NG_0.6_0.6 "+ element_type
    
    resources_array = Array.new
    
    categories_20NG = ["comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"]    
    
    categories_20NG.each do |category|
       ReutersNewItem.where(:topics => category, :cgisplit => "train").all.each do |resource|
         resources_array << resource
       end
    end
=end      

   puts "Proceding to "+ task +" Reuters_21578_sde_split_0.7_0.7 "+ element_type

   resources_array = Array.new
   
   ReutersNewItem.where(:sde_split => "TRAIN").all.each do |resource|
      resources_array << resource
   end
  
  
    begin
       threads = []
       threads <<  Thread.new do
          resources_array.each do |resource|       
             task = Task.new "expand_concepts", resource
             Broker.instance.queue << task
             puts "Task " + "expand_concepts " + resource.class.to_s + " " + resource.id.to_s + " enqueued!"            
          end
       end
       threads.each do |thread|
         thread.join
         if thread[:exception]
         end
       end
    rescue Exception => e
       puts "Error while expand_concepts resource "+ element_type
       puts e.message
       puts e.backtrace.inspect
    end       
    
        
     
=begin
    if provider != nil
      begin
        puts "Proceding to "+ task +" "+ element_type + " of " + provider
        resources_array = element_type.constantize.where(:scraped_from => provider)
        resources_array.each do |resource|
          if resource.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human"]).size == 0
            puts "Proceding to annotate resource: "+ element_type + " " + resource.id.to_s
            # Gets its manual tags
            manual_tags = Array.new
            resource.taggable_tag_annotations.where(:type_tag => "human").each do |annotation|
              manual_tags << annotation.tag.name
            end
            resource.extract_wikitopics(resource.name, resource.info_to_wikify, manual_tags)
            puts "Resource annotated successfully"
          else
            puts "Resource "+ element_type+ "  " + resource.id.to_s + " already annotated"
          end
        end
        puts "Task "+task +" "+ element_type + " of " + provider+" COMPLETED!!"
      rescue Exception => e
        puts "Error while annotating resource "+ element_type+ "  " + resource.id.to_s
        puts e.message
        puts e.backtrace.inspect
      end
    elsif provider == nil
      begin
        puts "Proceding to "+ task +" all "+ element_type
        resources_array = element_type.constantize.all
        resources_array.each do |resource|
          if resource.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human"]).size == 0
            puts "Proceding to annotate resource: "+ element_type + " " + resource.id.to_s
            # Gets its manual tags
            manual_tags = Array.new
            resource.taggable_tag_annotations.where(:type_tag => "human").each do |annotation|
              manual_tags << annotation.tag.name
            end
            resource.extract_wikitopics(resource.name, resource.info_to_wikify, manual_tags)
            puts "Resource annotated successfully"
          else
            puts "Resource "+ element_type+ "  " + resource.id.to_s + " already annotated"
          end
        end
      rescue Exception => e
        puts "Error while annotating resource "+ element_type+ "  " + resource.id.to_s
        puts e.message
        puts e.backtrace.inspect
      end
=end          
  elsif task == "categorize"
  #categorize
  elsif task == "geolocalize"
  #geolocalize
  #enzalarlo con el metodo que vuelve a geolocalizar en caso de que no este geolocalizado
  elsif task == "delete"
  #element_type.constantize.destroy_all(:scraped_from => provider)
  Source.destroy_all(:url => provider, :source_type => element_type)
  end

else
  puts "Incorrect parameters"
end
