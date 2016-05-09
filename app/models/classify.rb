# encoding: utf-8
require 'net/http'
require 'net/https'
require 'uri'
require 'stemmer'
require 'classifier'
require 'set'

#require "capybara/dsl"
class Classify
   include ActionView::Helpers::SanitizeHelper
   def classify_it(wikitopics, sections, wikipediator_ip = nil)
      begin
                  
         scraper = Scraper.new
         wikipediator = Wikipediator.new
                          
         newspaper_sections = sections
         
         categories = Array.new
         total_relatedness = 0
              
         newspaper_sections.each do |section|
            category = wikipediator.complex_search_it(section, wikipediator_ip)
            categories << {:name => category[0][:name], :wikipedia_article_id => category[0][:wikipedia_article_id]}
         end
                  
         #wikitopics = wikipediator.wikify_it(text)
         
         categories.each do |category|
            wikitopics.each do |wikitopic|
               relatedness = wikipediator.compare(wikitopic[:wikipedia_article_id],category[:wikipedia_article_id], wikipediator_ip)
               total_relatedness = total_relatedness + relatedness.to_f
            end
            relatedness_mean = total_relatedness / wikitopics.size
            category = category[:relatedness_mean] = relatedness_mean 
            relatedness_mean = 0
            total_relatedness = 0
         end 
             
         categories = categories.sort_by { |hsh| hsh[:relatedness_mean] }
         
         puts "WIKITOPICS"
         puts wikitopics
         
         puts "CATEGORIES"
         puts categories
         
         puts "CATEGORY SELECTED: "
         puts categories.last     
                  
         return categories.last    
      rescue Exception => e
         puts "Exception classify_it"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def classify_it_with_weight(wikitopics, sections, wikipediator_ip = nil)
      begin
                  
         scraper = Scraper.new
         wikipediator = Wikipediator.new
                          
         categories = Array.new
         total_relatedness = 0
              
         newspaper_sections = sections              
              
         newspaper_sections.each do |section|
            category = wikipediator.complex_search_it(section,wikipediator_ip)
            categories << {:name => category[0][:name], :wikipedia_article_id => category[0][:wikipedia_article_id]}
         end
                  
         #wikitopics = wikipediator.wikify_it(text)
         
         categories.each do |category|
            wikitopics.each do |wikitopic|
               relatedness = (wikipediator.compare(wikitopic[:wikipedia_article_id],category[:wikipedia_article_id],wikipediator_ip).to_f * wikitopic[:weight].to_f)
               total_relatedness = total_relatedness + relatedness.to_f
            end
            relatedness_mean = total_relatedness / wikitopics.size
            category = category[:relatedness_mean] = relatedness_mean 
            relatedness_mean = 0
            total_relatedness = 0
         end 
             
         categories = categories.sort_by { |hsh| hsh[:relatedness_mean] }
         
         puts "WIKITOPICS"
         puts wikitopics
         
         puts "CATEGORIES"
         puts categories
         
         puts "CATEGORY SELECTED: "
         puts categories.last     
                  
         return categories.last    
      rescue Exception => e
         puts "Exception classify_it_with_weight"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   
   def self.generate_countries_and_cities
      begin
         puts "Generating countries and cities array...."
         Cities.data_path = 'cities'
         countries = Array.new      
         countries_code = Array.new 
         cities = Array.new
         countries_and_cities = Array.new
         Carmen::Country.all.each do |carmen_country|
            countries << carmen_country.name.downcase
            countries_code << carmen_country.code
         end
         countries_code.each do |country_code|
            Cities.cities_in_country(country_code).each do |city|
               cities << city.first.downcase
            end
         end   
         countries_and_cities = countries + cities
         puts "Done!"
         return countries_and_cities
      rescue Exception => e
         puts "Exception generate_countries_and_cities"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def self.generate_countries
      begin
         countries = Array.new 
         Carmen::Country.all.each do |carmen_country|
            countries << carmen_country.name.downcase
         end
         return countries
      rescue Exception => e
         puts "Exception generate_countries"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
     
   def classify_it_without_countries(wikitopics,sections, wikipediator_ip = nil)
      begin
      
         scraper = Scraper.new
         wikipediator = Wikipediator.new

         newspaper_sections = sections
                
         categories = Array.new
         total_relatedness = 0
                            
         newspaper_sections.each do |section|
            category = wikipediator.complex_search_it(section,wikipediator_ip)
            categories << {:name => category[0][:name], :wikipedia_article_id => category[0][:wikipedia_article_id]}
         end
                         
         categories.each do |category|
            wikitopics.each do |wikitopic|
               if !$countries.include? wikitopic[:name].downcase
                  relatedness = (wikipediator.compare(wikitopic[:wikipedia_article_id],category[:wikipedia_article_id],wikipediator_ip).to_f * wikitopic[:weight].to_f)
                  total_relatedness = total_relatedness + relatedness.to_f
               end
            end
            relatedness_mean = total_relatedness / wikitopics.size
            category = category[:relatedness_mean] = relatedness_mean 
            relatedness_mean = 0
            total_relatedness = 0
         end 
             
         categories = categories.sort_by { |hsh| hsh[:relatedness_mean] }
         
         puts "WIKITOPICS"
         puts wikitopics
         
         puts "CATEGORIES"
         puts categories
         
         puts "CATEGORY SELECTED: "
         puts categories.last     
                  
         return categories.last    
      rescue Exception => e
         puts "Exception classify_it_without_countries"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   def classify_it_with_broader_sections(wikitopics, sections)
      begin
                  
         scraper = Scraper.new
         wikipediator = Wikipediator.new
                          
         newspaper_sections = sections
         
         categories = Array.new
         total_relatedness = 0
              
         newspaper_sections.each do |section|
            category = wikipediator.complex_search_it(section)
            categories << {:name => category[0][:name], :wikipedia_article_id => category[0][:wikipedia_article_id]}
         end
                         
         categories.each do |category|
            wikitopics.each do |wikitopic|
               relatedness = wikipediator.compare(wikitopic[:wikipedia_article_id],category[:wikipedia_article_id])
               total_relatedness = total_relatedness + relatedness.to_f
            end
            relatedness_mean = total_relatedness / wikitopics.size
            category = category[:relatedness_mean] = relatedness_mean 
            relatedness_mean = 0
            total_relatedness = 0
         end 
             
         categories = categories.sort_by { |hsh| hsh[:relatedness_mean] }
         
         puts "WIKITOPICS"
         puts wikitopics
         
         puts "CATEGORIES"
         puts categories
         
         puts "CATEGORY SELECTED: "
         puts categories.last     
                  
         return categories.last    
      rescue Exception => e
         puts "Exception classify_it_with_broader_sections"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
             
   def classify_stored_reports(method, sections, remove_outliers, threshold)
      begin
         method = method.downcase
         wikipediator = Wikipediator.new   
         report_feeds = Array.new
                  
         Report.where(:section => nil).each do |report|
            begin      
               wikitopics = Array.new
               if remove_outliers == true
                  annotations = remove_outliers(report,threshold)
               else
                  annotations = report.taggable_tag_annotations
               end
               annotations.each do |wikitopic|
                  wikitopics << {:name =>wikitopic.tag.name, :weight => wikitopic.weight, :wikipedia_article_id => wikitopic.wikipedia_article_id}
               end
               puts report.id
               begin
                  if method == "basic"
                     section = classify_it(wikitopics, sections)
                  elsif method == "with_weight"
                     section = classify_it_with_weight(wikitopics, sections)
                  elsif method == "without_countries"
                     section = classify_it_without_countries(wikitopics, sections)
                  end            
                  report.section = section[:name]
                  report.save
               rescue
                  section = nil
               end
            rescue
               section = nil
            end            
         end
      rescue Exception => e
         puts "Exception classify_stored_reports"
         puts e.message
         puts e.backtrace.inspect
      end              
   end  
     
   def classify_report(report, method, sections, remove_outliers, threshold, wikipediator_ip = nil)
      begin
         method = method.downcase
         wikipediator = Wikipediator.new   
         report_feeds = Array.new
                    
         wikitopics = Array.new
         if remove_outliers == true
            annotations = remove_outliers(report,threshold)
         else
            annotations = report.taggable_tag_annotations
         end
         annotations.each do |wikitopic|
            wikitopics << {:name =>wikitopic.tag.name, :weight => wikitopic.weight, :wikipedia_article_id => wikitopic.wikipedia_article_id}
         end
         puts report.id
         begin
            if method == "basic"
               section = classify_it(wikitopics, sections, wikipediator_ip)
            elsif method == "with_weight"
               section = classify_it_with_weight(wikitopics, sections, wikipediator_ip)
            elsif method == "without_countries"
               section = classify_it_without_countries(wikitopics, sections, wikipediator_ip)
            end            
            report.section = section[:name]
            report.save
         rescue Exception => e
            puts "Exception saving section"
            puts e.message
            puts e.backtrace.inspect
            section = nil
         end            
      rescue Exception => e
         puts "Exception classify_stored_report"
         puts e.message
         puts e.backtrace.inspect
      end              
   end   
   
   #receives a report an a threshold and returns an annotations filtered array
   def remove_outliers(report,threshold)
      begin
         wikipediator = Wikipediator.new
         filtered_annotations = Array.new
         totals = Array.new             

         if threshold.class == "String"
            threshold = threshold.downcase
         end

         terms = report.taggable_tag_annotations.map{|annotation| annotation.tag.name}
              
         annotations = report.taggable_tag_annotations.map{|annotation| annotation}
         
         annotations.each do |annotation|
            puts annotation.wikipedia_article_id
         end                 
            
         annotations.each do |annotation_x|
            total_relatedness = 0
            annotations.each do |annotation_y|            
               relatedness = wikipediator.compare(annotation_x.wikipedia_article_id.to_i, annotation_y.wikipedia_article_id.to_i)
               total_relatedness = total_relatedness + relatedness.to_f
            end
            puts "Annotations Size: " + annotations.size.to_s
            total_relatedness = total_relatedness / annotations.size.to_f
            if threshold != "gravitational center"
               if total_relatedness >= threshold
                  filtered_annotations << annotation_x
                  totals << {:annotation => annotation_x, :name => annotation_x.tag.name, :relatedness => total_relatedness}
               end
            elsif threshold == "gravitational center"
               filtered_annotations << annotation_x
               totals << {:annotation => annotation_x, :name => annotation_x.tag.name, :relatedness => total_relatedness}   
            end
         end
         totals = totals.sort_by { |hsh| hsh[:relatedness] }
         totals.each do |total|
            puts total[:name].to_s + " " + total[:relatedness].to_s
         end
         if threshold == "gravitational center"
            filtered_annotations = Array.new
            filtered_annotations << totals.last[:annotation]
            return filtered_annotations
         end
         return filtered_annotations
      rescue Exception => e
         puts "Exception remove outliers"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def reuters_statistics(method)
      begin      
      wikipediator = Wikipediator.new   
      
      sections = [{:url_section => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Health")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Art")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Politics")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Sport")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Science")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Technology")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=", :section => wikipediator.complex_search_it("Economy")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=" , :section => wikipediator.complex_search_it("Business")[0][:name]},
         {:url_section => "http://www.reuters.com/news/archive/Fashion?view=page&pageSize=10&page=" , :section => wikipediator.complex_search_it("Fashion")[0][:name]}]
      
      report_sections = Array.new
      
      Report.all.each do |report|
         if !report_sections.include? report.scraped_from
            report_sections << report.scraped_from
         end 
      end
           
      report_sections.each do |report_section|          
         selected_section = sections.find {|x| x[:url_section] == report_section }       
         puts selected_section        
         section = selected_section[:section]        
         puts section            
         well_classified = Report.where(:scraped_from => report_section, :section => section).size
         health_classified = Report.where(:scraped_from => report_section, :section => "Health").size
         art_classified = Report.where(:scraped_from => report_section, :section => "Art").size
         politics_classified = Report.where(:scraped_from => report_section, :section => "Politics").size
         sport_classified = Report.where(:scraped_from => report_section, :section => "Sport").size
         science_classified = Report.where(:scraped_from => report_section, :section => "Science").size
         technology_classified = Report.where(:scraped_from => report_section, :section => "Technology").size
         economy_classified = Report.where(:scraped_from => report_section, :section => "Economy").size
         business_classified = Report.where(:scraped_from => report_section, :section => "Business").size
         fashion_classified = Report.where(:scraped_from => report_section, :section => "Fashion").size        
         not_classified = Report.where(:scraped_from => report_section, :section => nil).size
         bad_classified = Report.where(:scraped_from => report_section).size - not_classified - well_classified      
         well_classified_percentage = well_classified.to_f / (well_classified.to_f + bad_classified.to_f)        
         puts well_classified_percentage
         date = Time.now
         filename = "reuters_" + date.to_s + "_statistics_" + method + ".txt"                
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "Section: "  + section.to_s
            f2.puts "---------------------------------------------"
            f2.puts "Health classified: " + health_classified.to_s 
            f2.puts "Art classified: " + art_classified.to_s 
            f2.puts "Politics classified: " + politics_classified.to_s 
            f2.puts "Sport classified: " + sport_classified.to_s 
            f2.puts "Science classified: " + science_classified.to_s 
            f2.puts "Technology classified: " + technology_classified.to_s 
            f2.puts "Economy classified: " + economy_classified.to_s 
            f2.puts "Business classified: " + business_classified.to_s     
            f2.puts "Fashion classified: " + fashion_classified.to_s                                       
            f2.puts
            f2.puts "Total: " + Report.where(:scraped_from => report_section).size.to_s 
            f2.puts "Classified: " + (Report.where(:scraped_from => report_section).size - not_classified).to_s
            f2.puts "Not classified: " + not_classified.to_s               
            f2.puts "Well classified: " + well_classified.to_s        
            f2.puts "Bad classified: " + bad_classified.to_s
            f2.puts "Well classified Percentage: " + well_classified_percentage.to_s
            f2.puts    
         end
      end
      rescue Exception => e
         puts "Exception reuters statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end 
    
    
   def rss_reuters_statistics(date,method)
      begin      
      wikipediator = Wikipediator.new   
      
      rss_feeds = [{:url_feed => "http://feeds.reuters.com/reuters/healthNews", :section => wikipediator.complex_search_it("Health")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/news/artsculture", :section => wikipediator.complex_search_it("Art")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/Reuters/PoliticsNews", :section => wikipediator.complex_search_it("Politics")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/reuters/sportsNews", :section => wikipediator.complex_search_it("Sport")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/reuters/scienceNews", :section => wikipediator.complex_search_it("Science")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/reuters/technologyNews", :section => wikipediator.complex_search_it("Technology")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/news/economy", :section => wikipediator.complex_search_it("Economy")[0][:name]},
         {:url_feed => "http://feeds.reuters.com/reuters/businessNews" , :section => wikipediator.complex_search_it("Business")[0][:name]}]
      
      report_feeds = Array.new
      
      Report.all.each do |report|
         if !report_feeds.include? report.scraped_from
            report_feeds << report.scraped_from
         end 
      end
           
      report_feeds.each do |report_feed|          
         selected_rss_feed = rss_feeds.find {|x| x[:url_feed] == report_feed }       
         puts selected_rss_feed        
         section = selected_rss_feed[:section]        
         puts section            
         well_classified = Report.where(:scraped_from => report_feed, :section => section).size
         health_classified = Report.where(:scraped_from => report_feed, :section => "Health").size
         art_classified = Report.where(:scraped_from => report_feed, :section => "Art").size
         politics_classified = Report.where(:scraped_from => report_feed, :section => "Politics").size
         sport_classified = Report.where(:scraped_from => report_feed, :section => "Sport").size
         science_classified = Report.where(:scraped_from => report_feed, :section => "Science").size
         technology_classified = Report.where(:scraped_from => report_feed, :section => "Technology").size
         economy_classified = Report.where(:scraped_from => report_feed, :section => "Economy").size
         business_classified = Report.where(:scraped_from => report_feed, :section => "Business").size
         education_classified = Report.where(:scraped_from => report_feed, :section => "Education").size
         fashion_classified = Report.where(:scraped_from => report_feed, :section => "Fashion").size
         culture_classified = Report.where(:scraped_from => report_feed, :section => "Culture").size         
         not_classified = Report.where(:scraped_from => report_feed, :section => nil).size
         bad_classified = Report.where(:scraped_from => report_feed).size - not_classified - well_classified      
         well_classified_percentage = well_classified.to_f / (well_classified.to_f + bad_classified.to_f)        
         puts well_classified_percentage
         if method == "basic"
            filename = "reuters_" + date + "_statistics_basic_method.txt"
         elsif method == "with_weight"
            filename = "reuters_" + date + "_statistics_with_weight_method.txt"
         elsif method == "without_countries"
            filename = "reuters_" + date + "_statistics_without_countries_method.txt"
         end                 
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "Section: "  + section.to_s
            f2.puts "---------------------------------------------"
            f2.puts "Health classified: " + health_classified.to_s 
            f2.puts "Art classified: " + art_classified.to_s 
            f2.puts "Politics classified: " + politics_classified.to_s 
            f2.puts "Sport classified: " + sport_classified.to_s 
            f2.puts "Science classified: " + science_classified.to_s 
            f2.puts "Technology classified: " + technology_classified.to_s 
            f2.puts "Economy classified: " + economy_classified.to_s 
            f2.puts "Business classified: " + business_classified.to_s     
            f2.puts "Education classified: " + education_classified.to_s
            f2.puts "Fashion classified: " + fashion_classified.to_s  
            f2.puts "Culture classified: " + culture_classified.to_s                                        
            f2.puts
            f2.puts "Total: " + Report.where(:scraped_from => report_feed).size.to_s 
            f2.puts "Classified: " + (Report.where(:scraped_from => report_feed).size - not_classified).to_s
            f2.puts "Not classified: " + not_classified.to_s               
            f2.puts "Well classified: " + well_classified.to_s        
            f2.puts "Bad classified: " + bad_classified.to_s
            f2.puts "Well classified Percentage: " + well_classified_percentage.to_s
            f2.puts    
         end
      end
      rescue Exception => e
         puts "Exception reuters statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end 
         
   def rss_dailymail_statistics(date,method)
      begin      
      wikipediator = Wikipediator.new   
      
      rss_feeds = [{:url_feed => "http://www.dailymail.co.uk/sport/index.rss", :section => wikipediator.complex_search_it("Sport")[0][:name]},
         {:url_feed => "http://www.dailymail.co.uk/health/index.rss", :section => wikipediator.complex_search_it("Health")[0][:name]},
         {:url_feed => "http://www.dailymail.co.uk/sciencetech/index.rss", :section => wikipediator.complex_search_it("Science")[0][:name]},
         {:url_feed => "http://www.dailymail.co.uk/money/index.rss", :section => wikipediator.complex_search_it("Economy")[0][:name]},
         {:url_feed => "http://www.dailymail.co.uk/femail/fashionfinder/index.rss", :section => wikipediator.complex_search_it("Fashion")[0][:name]},
         {:url_feed => "http://www.dailymail.co.uk/tvshowbiz/index.rss", :section => wikipediator.complex_search_it("ShowBusiness")[0][:name]}]
      
      report_feeds = Array.new
      
      Report.all.each do |report|
         if !report_feeds.include? report.scraped_from
            report_feeds << report.scraped_from
         end 
      end
           
      report_feeds.each do |report_feed|          
         selected_rss_feed = rss_feeds.find {|x| x[:url_feed] == report_feed }       
         puts selected_rss_feed        
         section = selected_rss_feed[:section]        
         puts section            
         well_classified = Report.where(:scraped_from => report_feed, :section => section).size
         health_classified = Report.where(:scraped_from => report_feed, :section => "Health").size
         sport_classified = Report.where(:scraped_from => report_feed, :section => "Sport").size
         science_classified = Report.where(:scraped_from => report_feed, :section => "Science").size
         economy_classified = Report.where(:scraped_from => report_feed, :section => "Economy").size
         fashion_classified = Report.where(:scraped_from => report_feed, :section => "Fashion").size   
         show_business_classified = Report.where(:scraped_from => report_feed, :section => "ShowBusiness").size               
         not_classified = Report.where(:scraped_from => report_feed, :section => nil).size
         bad_classified = Report.where(:scraped_from => report_feed).size - not_classified - well_classified      
         well_classified_percentage = well_classified.to_f / (well_classified.to_f + bad_classified.to_f)        
         puts well_classified_percentage
         if method == "basic"
            filename = "dailymail_" + date + "_statistics_basic_method.txt"
         elsif method == "with_weight"
            filename = "dailymail_" + date + "_statistics_with_weight_method.txt"
         elsif method == "without_countries"
            filename = "dailymail_" + date + "_statistics_without_countries_method.txt"
         end                 
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "Section: "  + section.to_s
            f2.puts "---------------------------------------------"
            f2.puts "Health classified: " + health_classified.to_s 
            f2.puts "Sport classified: " + sport_classified.to_s 
            f2.puts "Science classified: " + science_classified.to_s 
            f2.puts "Economy classified: " + economy_classified.to_s 
            f2.puts "Fashion classified: " + fashion_classified.to_s                                       
            f2.puts "Show Business classified: " + show_business_classified.to_s             
            f2.puts
            f2.puts "Total: " + Report.where(:scraped_from => report_feed).size.to_s 
            f2.puts "Classified: " + (Report.where(:scraped_from => report_feed).size - not_classified).to_s
            f2.puts "Not classified: " + not_classified.to_s               
            f2.puts "Well classified: " + well_classified.to_s        
            f2.puts "Bad classified: " + bad_classified.to_s
            f2.puts "Well classified Percentage: " + well_classified_percentage.to_s
            f2.puts    
         end
      end
      rescue Exception => e
         puts "Exception dailymail statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end    
   
     
   def reuters_categories_dispersion
      begin
         wikipediator = Wikipediator.new
         wikisections = Array.new
         relatedness = 0.0
         newspaper_sections = ["Business", "Technology", "Science", "Health", "Sport", "Art", "Fashion", "Politics", "Education", "Culture", "Economy"]
         newspaper_sections.each do |section|
            wikisections << wikipediator.complex_search_it(section)  
         end 
         
         File.open('categories_dispersion.txt', 'w') do |f2| 
            f2.puts "            | Business |Technology| Science  |  Health  |  Sport   |   Art    | Fashion  | Politics |Education | Culture  | Economy |"                                    
            wikisections.each_with_index do |wikisection_x, index_x|
               f2.puts "--------------------------------------------------------------------------------------------------------------------------------------"
               f2.print wikisection_x[0][:name]
               case wikisection_x[0][:name]
               when "Business"
               f2.print "    |   "
               when "Technology"
               f2.print "  |   "   
               when "Science"
               f2.print "     |   "   
               when "Health"
               f2.print "      |   "   
               when "Sport"
               f2.print "       |   "   
               when "Art"
               f2.print "         |   "   
               when "Fashion"
               f2.print "     |   "  
               when "Politics"
               f2.print "    |   "   
               when "Education"
               f2.print "   |   "   
               when "Culture"
               f2.print "     |   "   
               when "Economy"
               f2.print "     |   "   
               end                      
               wikisections.each_with_index do |wikisection_y, index_y|
                  relatedness = wikipediator.compare(wikisection_x[0][:wikipedia_article_id],wikisection_y[0][:wikipedia_article_id])
                  f2.print "%.2f" % relatedness + "   |   "
               end
               f2.puts 
            end
            f2.puts "--------------------------------------------------------------------------------------------------------------------------------------"       
         end #file
      rescue Exception => e
         puts "Exception reuters_categories_dispersion"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def classify_it_naive_bayes(training_elements_number)
      begin
         $stdout = File.new('console_naive_bayes.out', 'w')
         $stdout.sync = true
         cls = StuffClassifier::Bayes.new("Cats or Dogs", :stemming => true)
                 
         test_elements_number = 2900 - training_elements_number
         
         date = Time.now
         
         #sections = ["Business", "Technology", "Science", "Health", "Sport", "Art", "Politics", "Economy"]
         #naive_bayes = NaiveBayes.new(sections)
           
         test_elements_number = 40
         training_elements_number = 40
                  
         puts "Training Health..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Health",report.name + ". " + report.description)
            cls.train("Health".to_sym, report.name + ". " + report.description)  
         end
         puts "Training Art..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Art",report.name + ". " + report.description)
            cls.train("Art".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Politics..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Politics",report.name + ". " + report.description)
            cls.train("Politics".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Sport..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Sport",report.name + ". " + report.description)
            cls.train("Sport".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Science..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Science",report.name + ". " + report.description)
            cls.train("Science".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Technology..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Technology",report.name + ". " + report.description)
            cls.train("Technology".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Economy..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Economy",report.name + ". " + report.description)
            cls.train("Economy".to_sym, report.name + ". " + report.description)            
         end
         puts "Training Business..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #naive_bayes.train("Business",report.name + ". " + report.description)
            cls.train("Business".to_sym, report.name + ". " + report.description)            
         end
         #puts "Training Fashion..."
         #Report.where(:scraped_from => "http://www.reuters.com/news/archive/Fashion?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
          #  naive_bayes.train("Fashion",report.info_to_wikify)
         #end
       
         array_hashes_classified = Array.new
         
         
         puts "Classifying Health..."
         health_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end
            #health_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            health_classified_array << cls.classify(report.name + ". " + report.description).to_s            
         end
         hash_classified = {:classified => health_classified_array, :section => "Health"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Art..."
         art_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #art_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            art_classified_array << cls.classify(report.name + ". " + report.description).to_s  
         end
         hash_classified = {:classified => art_classified_array, :section => "Art"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Politics..."
         politics_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #politics_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            politics_classified_array << cls.classify(report.name + ". " + report.description).to_s            
         end
         hash_classified = {:classified => politics_classified_array, :section => "Politics"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Sport..."
         sport_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #sport_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            sport_classified_array << cls.classify(report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => sport_classified_array, :section => "Sport"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Science..."
         science_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #science_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            science_classified_array << cls.classify(report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => science_classified_array, :section => "Science"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Technology..."
         technology_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #technology_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            technology_classified_array << cls.classify(report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => technology_classified_array, :section => "Technology"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Economy..."
         economy_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #economy_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            economy_classified_array << cls.classify(report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => economy_classified_array, :section => "Economy"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Business..."
         business_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            #business_classified_array << naive_bayes.classify(report.name + ". " + report.description)
            business_classified_array << cls.classify(report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => business_classified_array, :section => "Business"}
         array_hashes_classified << hash_classified
         
         #puts "Classifying Fashion..."
         #fashion_classified_array = Array.new
         #Report.where(:scraped_from => "http://www.reuters.com/news/archive/Fashion?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
          #  fashion_classified_array << naive_bayes.classify(report.info_to_wikify)
         #end
         #hash_classified = {:classified => fashion_classified_array, :section => "Fashion"}
         #array_hashes_classified << hash_classified
         
         semantic_naive_bayes_statistics(array_hashes_classified ,date)  
                 
      rescue Exception => e
         puts "Exception classify_it_naive_bayes"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def classify_it_semantic_naive_bayes(training_elements_number,remove_outliers, threshold)
      begin
         $stdout = File.new('console.out', 'w')
         $stdout.sync = true
         
         cls = StuffClassifier::Bayes.new("Classifier", :stemming => false)

         test_elements_number = 2900 - training_elements_number
         
         training_elements_number = 20 
         test_elements_number = 20
         
                  
         date = Time.now
                  
         sections = ["Business", "Technology", "Science", "Health", "Sport", "Art", "Politics", "Economy"]
         naive_bayes = NaiveBayes.new(sections)
                  
         puts "Training Health..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Health",report, remove_outliers, threshold)
            cls.train("Health".to_sym, document_to_text(report))
         end
         puts "Training Art..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Art",report, remove_outliers, threshold)
            cls.train("Art".to_sym, document_to_text(report))
         end
         puts "Training Politics..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Politics",report, remove_outliers, threshold)
            cls.train("Politics".to_sym, document_to_text(report))
         end
         puts "Training Sport..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Sport",report, remove_outliers, threshold)
            cls.train("Sport".to_sym, document_to_text(report))
         end
         puts "Training Science..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Science",report, remove_outliers, threshold)
            cls.train("Science".to_sym, document_to_text(report))
         end
         puts "Training Technology..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Technology",report, remove_outliers, threshold)
            cls.train("Technology".to_sym, document_to_text(report))
         end
         puts "Training Economy..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Economy",report, remove_outliers, threshold)
            cls.train("Economy".to_sym, document_to_text(report))
         end
         puts "Training Business..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            #naive_bayes.semantic_train("Business",report, remove_outliers, threshold)
            cls.train("Business".to_sym, document_to_text(report))
         end
         #puts "Training Fashion..."
         #Report.where(:scraped_from => "http://www.reuters.com/news/archive/Fashion?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
          #  naive_bayes.semantic_train("Fashion",report, remove_outliers, threshold)
         #end
         
         array_hashes_classified = Array.new
                                            
         puts "Classifying Health..."
         health_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #health_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            health_classified_array << cls.classify(document_to_text(report)).to_s          
         end
         hash_classified = {:classified => health_classified_array, :section => "Health"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Art..."
         art_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #art_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            art_classified_array << cls.classify(document_to_text(report)).to_s           
         end
         hash_classified = {:classified => art_classified_array, :section => "Art"}
         array_hashes_classified << hash_classified          
         
         puts "Classifying Politics..."
         politics_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #politics_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            politics_classified_array << cls.classify(document_to_text(report)).to_s
         end
         hash_classified = {:classified => politics_classified_array, :section => "Politics"}
         array_hashes_classified << hash_classified            
         
         puts "Classifying Sport..."
         sport_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #sport_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            sport_classified_array << cls.classify(document_to_text(report)).to_s
         end
         hash_classified = {:classified => sport_classified_array, :section => "Sport"}
         array_hashes_classified << hash_classified        
          
         puts "Classifying Science..."
         science_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #science_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            science_classified_array << cls.classify(document_to_text(report)).to_s                   
         end
         hash_classified = {:classified => science_classified_array, :section => "Science"}
         array_hashes_classified << hash_classified 
         
         puts "Classifying Technology..."
         technology_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #technology_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            technology_classified_array << cls.classify(document_to_text(report)).to_s                       
         end
         hash_classified = {:classified => technology_classified_array, :section => "Technology"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Economy..."
         economy_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #economy_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)                        
            economy_classified_array << cls.classify(document_to_text(report)).to_s
         end
         hash_classified = {:classified => economy_classified_array, :section => "Economy"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Business..."
         business_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            #business_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)
            business_classified_array << cls.classify(document_to_text(report)).to_s                    
         end
         hash_classified = {:classified => business_classified_array, :section => "Business"}
         array_hashes_classified << hash_classified    
         
         #puts "Classifying Fashion..."
         #fashion_classified_array = Array.new 
         #Report.where(:scraped_from => "http://www.reuters.com/news/archive/Fashion?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
          #  fashion_classified_array << naive_bayes.semantic_classify(report, remove_outliers, threshold)           
         #end
         #hash_classified = {:classified => fashion_classified_array, :section => "Fashion"}
         #array_hashes_classified << hash_classified
                
         semantic_naive_bayes_statistics(array_hashes_classified ,date)            
         
      rescue Exception => e
         puts "Exception classify_it_naive_bayes"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   def semantic_naive_bayes_statistics(array_hashes_classified,date)
      begin         
         total_health_classified = 0
         total_art_classified = 0
         total_politics_classified = 0
         total_sport_classified = 0
         total_science_classified = 0    
         total_technology_classified = 0
         total_economy_classified = 0
         total_business_classified = 0
         total_fashion_classified = 0
         total_classified = 0
         total_f1_score = 0
         filename = ""
                  
         array_hashes_classified.each do |hash|
            hash[:classified].each do |section|
               case section
                  when "Health"
                     total_health_classified += 1
                  when "Art"
                     total_art_classified += 1
                  when "Politics"
                     total_politics_classified += 1                     
                  when "Sport"
                     total_sport_classified += 1
                  when "Science"
                     total_science_classified += 1
                  when "Technology"
                     total_technology_classified += 1
                  when "Economy"
                     total_economy_classified += 1
                  when "Business"
                     total_business_classified += 1
                  when "Fashion"
                     total_fashion_classified += 1                 
               end
            end         
         end
         array_hashes_classified.each do |hash|
            health_classified = 0
            art_classified = 0
            politics_classified = 0
            sport_classified = 0
            science_classified = 0    
            technology_classified = 0
            economy_classified = 0
            business_classified = 0
            fashion_classified = 0
            not_classified = 0
            hash[:classified].each do |section|
               case section
                  when "Health"
                     health_classified += 1
                  when "Art"
                     art_classified += 1
                  when "Politics"
                     politics_classified += 1                  
                  when "Sport"
                     sport_classified += 1
                  when "Science"
                     science_classified += 1
                  when "Technology"
                     technology_classified += 1
                  when "Economy"
                     economy_classified += 1
                  when "Business"
                     business_classified += 1
                  when "Fashion"
                     fashion_classified += 1
                  when "unknown"
                     not_classified += 1
                  when ""           
                     not_classified += 1
                  when " "
                     not_classified += 1     
               end
            end   
            case hash[:section]
               when "Health"
                  well_classified = health_classified
                  total_classified = total_health_classified
               when "Art"
                  well_classified = art_classified
                  total_classified = total_art_classified
               when "Politics"
                  well_classified = politics_classified
                  total_classified = total_politics_classified
               when "Sport"
                  well_classified = sport_classified
                  total_classified = total_sport_classified
               when "Science"
                  well_classified = science_classified
                  total_classified = total_science_classified
               when "Technology"
                  well_classified = technology_classified
                  total_classified = total_technology_classified
               when "Economy"
                  well_classified = economy_classified
                  total_classified = total_economy_classified
               when "Business"
                  well_classified = business_classified
                  total_classified = total_business_classified
               when "Fashion"
                  well_classified = fashion_classified
                  total_classified = total_fashion_classified
            end              
            total = hash[:classified].size 
            not_classified = not_classified
            classified = total - not_classified    
            well_classified = well_classified  
            bad_classified = classified - well_classified
            false_positives = total_classified - well_classified
            precision = well_classified.to_f / (well_classified.to_f + false_positives)
            recall = well_classified.to_f / (well_classified.to_f + bad_classified.to_f + not_classified)
            f1_score = (2 * precision.to_f * recall.to_f) / (precision.to_f + recall.to_f)    
            
            total_f1_score = total_f1_score + f1_score
                    
            method = "100_training_corpus_27000"
           
            filename = "semantic_" + date.to_s  + "_statistics_classifier_gem_wikify_0,01_threshold_weight*10_with_#and()_" + method + ".txt"                
            File.open(filename, 'a') do |f2|   
               f2.puts
               f2.puts "Section: "  + hash[:section].to_s
               f2.puts "---------------------------------------------"
               f2.puts "Health classified: " + health_classified.to_s 
               f2.puts "Art classified: " + art_classified.to_s 
               f2.puts "Politics classified: " + politics_classified.to_s 
               f2.puts "Sport classified: " + sport_classified.to_s 
               f2.puts "Science classified: " + science_classified.to_s 
               f2.puts "Technology classified: " + technology_classified.to_s 
               f2.puts "Economy classified: " + economy_classified.to_s 
               f2.puts "Business classified: " + business_classified.to_s     
               f2.puts "Fashion classified: " + fashion_classified.to_s                                       
               f2.puts
               f2.puts "Total: " + total.to_s
               f2.puts "Classified: " + classified.to_s
               f2.puts "Not classified: " + not_classified.to_s               
               f2.puts "Well classified: " + well_classified.to_s        
               f2.puts "Bad classified: " + bad_classified.to_s
               f2.puts "False positives: " + false_positives.to_s
               f2.puts "Precision: " + precision.to_s
               f2.puts "Recall: " + recall.to_s
               f2.puts "F1-Score: " + f1_score.to_s
               f2.puts         
            end    
         end
         
         f1_score_average = total_f1_score / 8
         
         File.open(filename, 'a') do |f2|
            f2.puts "***********************"
            f2.puts "F1 average = " + f1_score_average.to_s         
         end
         
      rescue Exception => e
         puts "Exception semantic_naive_bayes_statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def create_sde_split
      begin
         contador = 0
         ReutersNewItem.all.each do |item|
            if item.topics != nil and item.topics != ""
               if !item.topics.include? ","
                  item.sde_split = "YES"
                  item.save
               end
            end
         end
         puts contador
      rescue Exception => e
         puts "Exception create_sde_split"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   
   def classify_corpus_reuters_27000_sde_split_naive_bayes(training_elements_number)
      begin
         $stdout = File.new('console_27000.out', 'w')
         $stdout.sync = true
         
         date = Time.now        
         sections = Array.new
                 
         sde_split_size = ReutersNewItem.where(:sde_split => "YES").size
                               
         test_elements_number = sde_split_size - training_elements_number
         
         sde_split = ReutersNewItem.where(:sde_split => "YES")
                             
                                                  
        sde_split.first(training_elements_number).each do |item|
            if !sections.include? item.topics
               sections << item.topics
            end
         end      
         
         puts sections
         puts sections.size
                                                     
         naive_bayes = NaiveBayes.new(sections)               
               
         puts "Training Naive Bayes Classifier..."      
         
         counter = 0
         
         remove_outliers = false
         threshold = 0
                             
         sde_split.first(training_elements_number).each do |item|
            naive_bayes.train(item.topics,item.name + ". " + item.description)
            #naive_bayes.semantic_train(item.topics, item, remove_outliers, threshold)
         end
            
         naive_bayes.display_data
               
         puts "Trained!"           
         
         puts "Classifiying..."    
         i=0
         count = 0
         #test_elements_number
         sde_split.last(test_elements_number).each do |item|
            #puts "Document:"
            #puts item.name
            #puts item.description
            puts i+=1
            puts "Expected:" + item.topics
            cat = naive_bayes.classify(item.name + ". " + item.description)
            if cat == item.topics
               count+=1
            end
            puts "matches:" + count.to_s
         end             
                              
         #semantic_naive_bayes_statistics(array_hashes_classified ,date)  
                 
      rescue Exception => e
         puts "Exception classify_it_naive_bayes"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   
   def stuff_classifier
      # for the naive bayes implementation
      cls = StuffClassifier::Bayes.new("Classifier", :stemming => true)
      sde_split = ReutersNewItem.where(:sde_split => "YES")
                             
                                               
      sde_split.first(8000).each do |item|
         cls.train(item.topics.to_sym, item.name + ". " + item.description)
      end    
     
     counter = 0
     sde_split.last(1000).each do |item|
         puts "***"
         puts "Expected category: " + item.topics
         returned_category = cls.classify(item.name + ". " + item.description)
         puts "Returned category: " + returned_category.to_s
         puts "***"
         if returned_category.to_s == item.topics
            counter+=1
         end
         puts "Matches = " + counter.to_s
     end  
     
     puts "Sleeping..."
     sleep 2000  
   end
   
   def weight_expanded_concepts
      begin
         ReutersNewItem.all.each do |item|
            item.taggable_tag_annotations.where(:type_tag => "expanded").each do |expanded_annotation|
               weight_expanded_from_annotation = TaggableTagAnnotation.find(expanded_annotation.expanded_from).weight
               expanded_annotation_weight = expanded_annotation.relatedness * weight_expanded_from_annotation
               expanded_annotation.weight = expanded_annotation_weight            
               expanded_annotation.save 
            end
         end
      rescue Exception => e
         puts "Exception weight_expanded_concepts"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   
 def document_to_text_select_expansion(document,automatic_threshold, wikify_threshold, relatedness_threshold)
      text = "a a "
      document.taggable_tag_annotations.each do |annotation|
         if (annotation.type_tag == "automatic")
            if (annotation.weight >= automatic_threshold)
               (annotation.weight*10).ceil.times do
                  text += " " + Util.to_hashtag(annotation.tag.name)
               end
            end       
         elsif (annotation.type_tag == "expanded")
            if ((annotation.relatedness > relatedness_threshold) and (TaggableTagAnnotation.find(annotation.expanded_from).weight > wikify_threshold))               
               (annotation.weight*10).ceil.times do
                  text += " " + Util.to_hashtag(annotation.tag.name)
               end
            end
         end
      end
      return text
   end   
   
 def document_to_text(document,threshold, expanded_concepts_weight)
      text = "a a "
      document.taggable_tag_annotations.each do |annotation|
         if (annotation.type_tag == "automatic")
            if (annotation.weight >= threshold)
               (annotation.weight*10).ceil.times do
                  text += " " + Util.to_hashtag(annotation.tag.name)
               end
            end       
         elsif (annotation.type_tag == "expanded")
            #(annotation.weight*10).ceil.times do
            (expanded_concepts_weight*10).ceil.times do 
               text += " " + Util.to_hashtag(annotation.tag.name)
            end
         end
      end
      return text
   end
   
 def document_to_text_without_expanded_concepts(document,threshold)
      text = "a a "
      document.taggable_tag_annotations.each do |annotation|
         if (annotation.type_tag == "automatic")
            if (annotation.weight >= threshold)
               (annotation.weight*10).ceil.times do
                  text += " " + Util.to_hashtag(annotation.tag.name)
               end
            end       
         end
      end
      return text
   end   
   
   def semantic_stuff_classifier
      # for the naive bayes implementation
      cls = StuffClassifier::Bayes.new("Cats or Dogs", :stemming => false)
      sde_split = ReutersNewItem.where(:sde_split => "YES")
                                                                           
      sde_split.first(8000).each do |item|
         cls.train(item.topics.to_sym, document_to_text(item))
      end    
     
     counter = 0
     sde_split.last(1000).each do |item|
         puts "***"
         puts "Expected category: " + item.topics
         returned_category = cls.classify(document_to_text(item))
         puts "Returned category: " + returned_category.to_s
         puts "***"
         if returned_category.to_s == item.topics
            counter+=1
         end
         puts "Matches = " + counter.to_s
     end    
   end
   
   
   def classify_corpus_ohsumed
      begin
         # for the naive bayes implementation
         cls = StuffClassifier::Bayes.new("Cats or Dogs", :stemming => false)
         training_split = ReutersNewItem.where(:cgi_split => "training")
         test_split = ReutersNewItem.where(:cgi_split => "test")
                                                                           
         training_split.each do |item|
            cls.train(item.topics.to_sym, document_to_text(item))
         end    
     
        counter = 0
        test_split.each do |item|
            puts "***"
            puts "Expected category: " + item.topics
            returned_category = cls.classify(document_to_text(item))
            puts "Returned category: " + returned_category.to_s
            puts "***"
            if returned_category.to_s == item.topics
               counter+=1
            end
            puts "Matches = " + counter.to_s
        end    
         
      rescue Exception => e
         puts "Exception classify_corpus_ohsumed"
         puts e.message
         puts e.backtrace.inspect 
      end
   end
   
   def classifier(training_elements_number)
      begin 
         b = Classifier::Bayes.new 'Health', 'Art', 'Politics','Sport', 'Science', 'Technology', 'Economy', 'Business'
                
         test_elements_number = 500
         
         puts "Training:"
         puts training_elements_number
         
         puts "Test:"
         puts test_elements_number
                     
         $stdout = File.new('console_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
                            
         puts "Training Health..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_health report.name + ". " + report.description
         end
         puts "Training Art..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_art report.name + ". " + report.description            
         end
         puts "Training Politics..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_politics report.name + ". " + report.description       
         end
         puts "Training Sport..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_sport report.name + ". " + report.description
         end
         puts "Training Science..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_science report.name + ". " + report.description           
         end
         puts "Training Technology..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_technology report.name + ". " + report.description           
         end
         puts "Training Economy..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_economy report.name + ". " + report.description           
         end
         puts "Training Business..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            b.train_business report.name + ". " + report.description           
         end
         
         array_hashes_classified = Array.new
                       
         puts "Classifying Health..."
         health_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end
            health_classified_array << (b.classify report.name + ". " + report.description).to_s            
         end
         hash_classified = {:classified => health_classified_array, :section => "Health"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Art..."
         art_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            art_classified_array << (b.classify report.name + ". " + report.description).to_s  
         end
         hash_classified = {:classified => art_classified_array, :section => "Art"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Politics..."
         politics_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end                       
            politics_classified_array << (b.classify report.name + ". " + report.description).to_s            
         end
         hash_classified = {:classified => politics_classified_array, :section => "Politics"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Sport..."
         sport_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            sport_classified_array << (b.classify report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => sport_classified_array, :section => "Sport"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Science..."
         science_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end                        
            science_classified_array << (b.classify report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => science_classified_array, :section => "Science"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Technology..."
         technology_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end                        
            technology_classified_array << (b.classify report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => technology_classified_array, :section => "Technology"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Economy..."
         economy_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end                        
            economy_classified_array << (b.classify report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => economy_classified_array, :section => "Economy"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Business..."
         business_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            if report.name == nil
               report.name = ""
            end
            if report.description == nil
               report.description = ""
            end            
            business_classified_array << (b.classify report.name + ". " + report.description).to_s              
         end
         hash_classified = {:classified => business_classified_array, :section => "Business"}
         array_hashes_classified << hash_classified
         
         semantic_naive_bayes_statistics(array_hashes_classified ,date)
               
      rescue Exception => e
         puts "Exception classifier"
         puts e.message
         puts e.backtrace.inspect
      end   
     
   end
   
   
   def obtain_statistics_classified_stored_reports_wihout_training
         array_hashes_classified = Array.new
                                            
         puts "Classifying Health..."
         health_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
             health_classified_array << report.section
         end
         hash_classified = {:classified => health_classified_array, :section => "Health"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Art..."
         art_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            art_classified_array << report.section
         end
         hash_classified = {:classified => art_classified_array, :section => "Art"}
         array_hashes_classified << hash_classified          
         
         puts "Classifying Politics..."
         politics_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            politics_classified_array << report.section
         end
         hash_classified = {:classified => politics_classified_array, :section => "Politics"}
         array_hashes_classified << hash_classified            
         
         puts "Classifying Sport..."
         sport_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            sport_classified_array << report.section
         end
         hash_classified = {:classified => sport_classified_array, :section => "Sport"}
         array_hashes_classified << hash_classified        
          
         puts "Classifying Science..."
         science_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            science_classified_array << report.section    
         end
         hash_classified = {:classified => science_classified_array, :section => "Science"}
         array_hashes_classified << hash_classified 
         
         puts "Classifying Technology..."
         technology_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            technology_classified_array << report.section
         end
         hash_classified = {:classified => technology_classified_array, :section => "Technology"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Economy..."
         economy_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            economy_classified_array << report.section
         end
         hash_classified = {:classified => economy_classified_array, :section => "Economy"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Business..."
         business_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            business_classified_array << report.section
         end
         hash_classified = {:classified => business_classified_array, :section => "Business"}
         array_hashes_classified << hash_classified    
                       
         semantic_naive_bayes_statistics(array_hashes_classified ,date)
   end
   
   
   ################################################################
   ######  train_reports_bayesian_semantic_classifier      ########
   ################################################################
   def train_reports_bayesian_semantic_classifier(threshold, training_elements_number)
      begin 
                      
         $classifier_naive_bayes_semantic = Classifier::Bayes.new 'Health', 'Art', 'Politics','Sport', 'Science', 'Technology', 'Economy', 'Business'
                
         categories = ['Health', 'Art', 'Politics','Sport', 'Science', 'Technology', 'Economy', 'Business']
                                                                                                          
         puts "Training Health..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_health document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Art..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_art document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Politics..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_politics document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Sport..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_sport document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Science..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_science document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Technology..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_technology document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Economy..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_economy document_to_text_without_expanded_concepts(report,threshold)
         end
         puts "Training Business..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            $classifier_naive_bayes_semantic.train_business document_to_text_without_expanded_concepts(report,threshold)
         end

         # Serializamos el clasificador y lo guardamos en la tabla "naive_bayes_classifiers" para poder deserializarlo posteriormente
         # y poder utilizarlo para clasificar

         new_classifier = NaiveBayesClassifier.new
         new_classifier.name = "Reuters27000"
         serialized_classifier = $classifier_naive_bayes_semantic.to_yaml
         new_classifier.description = serialized_classifier
         new_classifier.save

                                                                                                               
      rescue Exception => e
         puts "Exception train_reports_bayesian_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end       
   end
   
   ################################################################
   ######  classify_reports_bayeseian_semantic_classifier  ########
   ################################################################
   def classify_reports_bayesian_semantic_classifier(threshold)
      begin 
                                                                                                                           
         Report.all.each do |item|
            puts "Classifying " + item.name + "..."
            category = ($classifier_naive_bayes_semantic.classify document_to_text_without_expanded_concepts(item,threshold)).to_s
            puts "Classified in " + category
            item.section = category
            item.save
            item.reload
            Sunspot.index item
            Sunspot.commit
         end
                                                                                                         
      rescue Exception => e
         puts "Exception classify_reports_bayesian_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end       
   end
    
   ################################################################
   ######  classify_reports_bayeseian_semantic_classifier  ########
   ################################################################
   def classify_reports_bayesian_semantic_classifier(threshold)
      begin 
                                                                                                                           
         Report.last(1000).each do |item|
            puts "Classifying " + item.name + "..."
            classifier_naive_bayes_semantic = YAML.load(NaiveBayesClassifier.where(:name => "Reuters27000").first.description)
            category = (classifier_naive_bayes_semantic.classify document_to_text_without_expanded_concepts(item,threshold)).to_s
            puts "Classified in " + category
            item.section = category
            item.save
            item.reload
            Sunspot.index item
            Sunspot.commit
         end
                                                                                                         
      rescue Exception => e
         puts "Exception classify_reports_bayesian_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end       
   end    
    
    
   
   def semantic_classifier(training_elements_number)
      begin 
         b = Classifier::Bayes.new 'Health', 'Art', 'Politics','Sport', 'Science', 'Technology', 'Economy', 'Business'
                 
         test_elements_number = 500
                         
         puts "Training:"
         puts training_elements_number
         
         puts "Test:"
         puts test_elements_number
                     
         $stdout = File.new('console_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
            
         puts "Training Health..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_health document_to_text(report,threshold)
         end
         puts "Training Art..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_art document_to_text(report,threshold)
         end
         puts "Training Politics..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_politics document_to_text(report,threshold)
         end
         puts "Training Sport..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_sport document_to_text(report,threshold)
         end
         puts "Training Science..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
           b.train_science document_to_text(report,threshold)
         end
         puts "Training Technology..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_technology document_to_text(report,threshold)
         end
         puts "Training Economy..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_economy document_to_text(report,threshold)
         end
         puts "Training Business..."
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").first(training_elements_number).each do |report|
            b.train_business document_to_text(report,threshold)
         end
         
         array_hashes_classified = Array.new
                                            
         puts "Classifying Health..."
         health_classified_array = Array.new
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/healthNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
             health_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => health_classified_array, :section => "Health"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Art..."
         art_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/artsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            art_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => art_classified_array, :section => "Art"}
         array_hashes_classified << hash_classified          
         
         puts "Classifying Politics..."
         politics_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/politicsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            politics_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => politics_classified_array, :section => "Politics"}
         array_hashes_classified << hash_classified            
         
         puts "Classifying Sport..."
         sport_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/sportsNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            sport_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => sport_classified_array, :section => "Sport"}
         array_hashes_classified << hash_classified        
          
         puts "Classifying Science..."
         science_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/scienceNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            science_classified_array << (b.classify document_to_text(report,threshold)).to_s    
         end
         hash_classified = {:classified => science_classified_array, :section => "Science"}
         array_hashes_classified << hash_classified 
         
         puts "Classifying Technology..."
         technology_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/technologyNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            technology_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => technology_classified_array, :section => "Technology"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Economy..."
         economy_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/GCA-Economy2010?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            economy_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => economy_classified_array, :section => "Economy"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Business..."
         business_classified_array = Array.new 
         Report.where(:scraped_from => "http://www.reuters.com/news/archive/businessNews?view=page&pageSize=10&page=").last(test_elements_number).each do |report|
            business_classified_array << (b.classify document_to_text(report,threshold)).to_s
         end
         hash_classified = {:classified => business_classified_array, :section => "Business"}
         array_hashes_classified << hash_classified    
                       
         semantic_naive_bayes_statistics(array_hashes_classified ,date)                        
                                          
      rescue Exception => e
         puts "Exception semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end   
     
   end
   
     
   #######################################################
   ### ohsumed_non_semantic_classifier ###################
   #######################################################
   
   def ohsumed_non_semantic_classifier
      begin 
                 
         b = Classifier::Bayes.new "Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"
         
         categories = ["Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"]
                 
         $stdout = File.new('console_ohsumed_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         training_elements = 5
         test_elements = 500
         
         date = Time.now
         
         date = date.to_s + "_non_semantic_" +  training_elements.to_s + "_training_"
                           
         categories.each do |category|
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category, :cgisplit => "training").first(training_elements).each do |item|
               train_method = "train_" + item.topics
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end    
               b.send(train_method, item.name + ". " + item.description)
            end
         end
                                                             
         array_hashes_classified = Array.new
                                                                                     
         puts "Classifying Bacterial Infections and Mycoses..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Bacterial Infections and Mycoses").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Bacterial Infections and Mycoses"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Virus Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Virus Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Virus Diseases"}
         array_hashes_classified << hash_classified
         
         puts "Classifying Parasitic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Parasitic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Parasitic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Neoplasms..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Neoplasms").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Neoplasms"}
         array_hashes_classified << hash_classified         

         puts "Classifying Musculoskeletal Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Musculoskeletal Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Musculoskeletal Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Digestive System Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Digestive System Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Digestive System Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Stomatognathic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Stomatognathic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Stomatognathic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Respiratory Tract Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Respiratory Tract Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Respiratory Tract Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Otorhinolaryngologic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Otorhinolaryngologic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Otorhinolaryngologic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Nervous System Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Nervous System Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Nervous System Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Eye Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Eye Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Eye Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Urologic and Male Genital Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Urologic and Male Genital Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Urologic and Male Genital Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Female Genital Diseases and Pregnancy Complications..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Female Genital Diseases and Pregnancy Complications").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Female Genital Diseases and Pregnancy Complications"}
         array_hashes_classified << hash_classified         

         puts "Classifying Cardiovascular Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Cardiovascular Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Cardiovascular Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Hemic and Lymphatic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Hemic and Lymphatic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Hemic and Lymphatic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Neonatal Diseases and Abnormalities..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Neonatal Diseases and Abnormalities").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Neonatal Diseases and Abnormalities"}
         array_hashes_classified << hash_classified         

         puts "Classifying Skin and Connective Tissue Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Skin and Connective Tissue Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Skin and Connective Tissue Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Nutritional and Metabolic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Nutritional and Metabolic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Nutritional and Metabolic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Endocrine Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Endocrine Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Endocrine Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Immunologic Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Immunologic Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Immunologic Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Disorders of Environmental Origin..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Disorders of Environmental Origin").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Disorders of Environmental Origin"}
         array_hashes_classified << hash_classified         

         puts "Classifying Animal Diseases..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Animal Diseases").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Animal Diseases"}
         array_hashes_classified << hash_classified         

         puts "Classifying Pathological Conditions, Signs and Symptoms..."
         classified_array = Array.new
         ReutersNewItem.where(:cgisplit => "test", :topics => "Pathological Conditions, Signs and Symptoms").first(test_elements).each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end            
            classified_array << (b.classify item.name + ". " + item.description).to_s
         end
         hash_classified = {:classified => classified_array, :section => "Pathological Conditions, Signs and Symptoms"}
         array_hashes_classified << hash_classified         
            
         ohsumed_classifier_statistics(array_hashes_classified ,date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception ohsumed_non_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end   
     
   end
   
   
   #######################################################
   ### ohsumed_semantic_classifier     ###################
   #######################################################
   def ohsumed_semantic_classifier(threshold, training_elements, expanded_concepts_weight)
      begin 
                 
         b = Classifier::Bayes.new "Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"
         
         
         categories = ["Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"]
                 
                                             
         $stdout = File.new('console_ohsumed_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
         
         date = date.to_s + "_" + threshold.to_s + "_semantic_expanded_only_training_" + expanded_concepts_weight.to_s + "_expanded_weight_" +  training_elements.to_s + "_training_"
         
         test_elements = 500
                         
         categories.each do |category|
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category, :cgisplit => "training").first(training_elements).each do |item|
               train_method = "train_" + item.topics
               b.send(train_method, document_to_text(item,threshold,expanded_concepts_weight))
            end
         end
                                             
         array_hashes_classified = Array.new
         
         categories.each do |category|
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:cgisplit => "test", :topics => category).first(test_elements).each do |item|
               classified_array << (b.classify document_to_text_without_expanded_concepts(item,threshold)).to_s
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified            
         end
                             
         ohsumed_classifier_statistics(array_hashes_classified ,date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception ohsumed_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end   
     
   end
   
  
   #######################################################
   ####### ohsumed_classifier_statistics   ###############
   #######################################################
   
   def ohsumed_classifier_statistics(array_hashes_classified,date,training_elements)
      begin   
         total_bacterial_infections_and_mycoses = 0
         total_virus_diseases = 0
         total_parasitic_diseases = 0
         total_neoplasms = 0
         total_musculoskeletal_diseases = 0
         total_digestive_system_diseases = 0
         total_stomatognathic_diseases = 0
         total_respiratory_tract_diseases = 0
         total_otorhinolaryngologic_diseases = 0
         total_nervous_system_diseases = 0
         total_eye_diseases = 0
         total_urologic_and_male_genital_diseases = 0
         total_female_genital_diseases = 0
         total_cardiovascular_diseases = 0
         total_hemic_lymphatic_diseases = 0
         total_neonatal_diseases_abnormalities = 0
         total_skin_connective_tissue_diseases = 0
         total_nutritional_metabolic_diseases = 0
         total_endocrine_diseases = 0
         total_inmunologic_diseases = 0
         total_disorders_environmental_origin = 0
         total_animal_diseases = 0
         total_pathological_conditions_signs_and_symptoms = 0

         total_classified = 0
         total_f1_score = 0.0
         total_precision = 0.0
         total_recall = 0.0         
         filename = "OHSUMED_" + date.to_s  + "statistics.txt"                           
             
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts filename.to_s
            f2.puts "Training elements: " + training_elements.to_s     
            f2.puts "***********************"
         end                                   
                                                         
         array_hashes_classified.each do |hash|
            hash[:classified].each do |section|
               case section.downcase
                  when "Bacterial Infections and Mycoses".downcase
                     total_bacterial_infections_and_mycoses += 1
                  when "Virus Diseases".downcase
                     total_virus_diseases += 1
                  when "Parasitic Diseases".downcase
                     total_parasitic_diseases += 1                     
                  when "Neoplasms".downcase
                     total_neoplasms += 1
                  when "Musculoskeletal Diseases".downcase
                     total_musculoskeletal_diseases += 1
                  when "Digestive System Diseases".downcase
                     total_digestive_system_diseases += 1
                  when "Stomatognathic Diseases".downcase
                     total_stomatognathic_diseases += 1
                  when "Respiratory Tract Diseases".downcase
                     total_respiratory_tract_diseases += 1
                  when "Otorhinolaryngologic Diseases".downcase
                     total_otorhinolaryngologic_diseases += 1     
                  when "Nervous System Diseases".downcase
                     total_nervous_system_diseases += 1
                  when "Eye Diseases".downcase
                     total_eye_diseases += 1                     
                  when "Urologic and Male Genital Diseases".downcase
                     total_urologic_and_male_genital_diseases += 1
                  when "Female Genital Diseases and Pregnancy Complications".downcase
                     total_female_genital_diseases += 1
                  when "Cardiovascular Diseases".downcase
                     total_cardiovascular_diseases += 1
                  when "Hemic and Lymphatic Diseases".downcase
                     total_hemic_lymphatic_diseases += 1
                  when "Neonatal Diseases and Abnormalities".downcase
                     total_neonatal_diseases_abnormalities += 1
                  when "Skin and Connective Tissue Diseases".downcase
                     total_skin_connective_tissue_diseases += 1
                  when "Nutritional and Metabolic Diseases".downcase
                     total_nutritional_metabolic_diseases += 1                     
                  when "Endocrine Diseases".downcase
                     total_endocrine_diseases += 1
                  when "Immunologic Diseases".downcase
                     total_inmunologic_diseases += 1
                  when "Disorders of Environmental Origin".downcase
                     total_disorders_environmental_origin += 1
                  when "Animal Diseases".downcase
                     total_animal_diseases += 1
                  when "Pathological Conditions, Signs and Symptoms".downcase
                     total_pathological_conditions_signs_and_symptoms += 1                                                             
               end  
            end      
         end       
         array_hashes_classified.each do |hash|
            bacterial_infections_and_mycoses = 0
            virus_diseases = 0
            parasitic_diseases = 0
            neoplasms = 0
            musculoskeletal_diseases = 0
            digestive_system_diseases = 0
            stomatognathic_diseases = 0
            respiratory_tract_diseases = 0
            otorhinolaryngologic_diseases = 0
            nervous_system_diseases = 0
            eye_diseases = 0
            urologic_and_male_genital_diseases = 0
            female_genital_diseases = 0
            cardiovascular_diseases = 0
            hemic_lymphatic_diseases = 0
            neonatal_diseases_abnormalities = 0
            skin_connective_tissue_diseases = 0
            nutritional_metabolic_diseases = 0
            endocrine_diseases = 0
            inmunologic_diseases = 0
            disorders_environmental_origin = 0
            animal_diseases = 0
            pathological_conditions_signs_and_symptoms = 0
            not_classified = 0
         
            hash[:classified].each do |section|
               case section.downcase
                  when "Bacterial Infections and Mycoses".downcase
                     bacterial_infections_and_mycoses += 1
                  when "Virus Diseases".downcase
                     virus_diseases += 1
                  when "Parasitic Diseases".downcase
                     parasitic_diseases += 1                     
                  when "Neoplasms".downcase
                     neoplasms += 1
                  when "Musculoskeletal Diseases".downcase
                     musculoskeletal_diseases += 1
                  when "Digestive System Diseases".downcase
                     digestive_system_diseases += 1
                  when "Stomatognathic Diseases".downcase
                     stomatognathic_diseases += 1
                  when "Respiratory Tract Diseases".downcase
                     respiratory_tract_diseases += 1
                  when "Otorhinolaryngologic Diseases".downcase
                     otorhinolaryngologic_diseases += 1     
                  when "Nervous System Diseases".downcase
                     nervous_system_diseases += 1
                  when "Eye Diseases".downcase
                     eye_diseases += 1                     
                  when "Urologic and Male Genital Diseases".downcase
                     urologic_and_male_genital_diseases += 1
                  when "Female Genital Diseases and Pregnancy Complications".downcase
                     female_genital_diseases += 1
                  when "Cardiovascular Diseases".downcase
                     cardiovascular_diseases += 1
                  when "Hemic and Lymphatic Diseases".downcase
                     hemic_lymphatic_diseases += 1
                  when "Neonatal Diseases and Abnormalities".downcase
                     neonatal_diseases_abnormalities += 1
                  when "Skin and Connective Tissue Diseases".downcase
                     skin_connective_tissue_diseases += 1
                  when "Nutritional and Metabolic Diseases".downcase
                     nutritional_metabolic_diseases += 1                     
                  when "Endocrine Diseases".downcase
                     endocrine_diseases += 1
                  when "Immunologic Diseases".downcase
                     inmunologic_diseases += 1
                  when "Disorders of Environmental Origin".downcase
                     disorders_environmental_origin += 1
                  when "Animal Diseases".downcase
                     animal_diseases += 1
                  when "Pathological Conditions, Signs and Symptoms".downcase
                     pathological_conditions_signs_and_symptoms += 1       
                  when "unknown"
                     not_classified += 1
                  when ""           
                     not_classified += 1
                  when " "
                     not_classified += 1                         
               end
            end                      
            case hash[:section].downcase
               when "Bacterial Infections and Mycoses".downcase
                  well_classified = bacterial_infections_and_mycoses
                  total_classified = total_bacterial_infections_and_mycoses
               when "Virus Diseases".downcase
                  well_classified = virus_diseases
                  total_classified = total_virus_diseases
               when "Parasitic Diseases".downcase
                  well_classified = parasitic_diseases
                  total_classified = total_parasitic_diseases               
               when "Neoplasms".downcase
                  well_classified = neoplasms
                  total_classified = total_neoplasms
               when "Musculoskeletal Diseases".downcase
                  well_classified = musculoskeletal_diseases
                  total_classified = total_musculoskeletal_diseases
               when "Digestive System Diseases".downcase
                  well_classified = digestive_system_diseases
                  total_classified = total_digestive_system_diseases
               when "Stomatognathic Diseases".downcase
                  well_classified = stomatognathic_diseases
                  total_classified = total_stomatognathic_diseases
               when "Respiratory Tract Diseases".downcase
                  well_classified = respiratory_tract_diseases
                  total_classified = total_respiratory_tract_diseases
               when "Otorhinolaryngologic Diseases".downcase
                  well_classified = otorhinolaryngologic_diseases
                  total_classified = total_otorhinolaryngologic_diseases  
               when "Nervous System Diseases".downcase
                  well_classified = nervous_system_diseases
                  total_classified = total_nervous_system_diseases
               when "Eye Diseases".downcase
                  well_classified = eye_diseases
                  total_classified = total_eye_diseases            
               when "Urologic and Male Genital Diseases".downcase
                  well_classified = urologic_and_male_genital_diseases
                  total_classified = total_urologic_and_male_genital_diseases
               when "Female Genital Diseases and Pregnancy Complications".downcase
                  well_classified = female_genital_diseases
                  total_classified = total_female_genital_diseases
               when "Cardiovascular Diseases".downcase
                  well_classified = cardiovascular_diseases
                  total_classified = total_cardiovascular_diseases
               when "Hemic and Lymphatic Diseases".downcase
                  well_classified = hemic_lymphatic_diseases
                  total_classified = total_hemic_lymphatic_diseases
               when "Neonatal Diseases and Abnormalities".downcase
                  well_classified = neonatal_diseases_abnormalities
                  total_classified = total_neonatal_diseases_abnormalities
               when "Skin and Connective Tissue Diseases".downcase
                  well_classified = skin_connective_tissue_diseases
                  total_classified = total_skin_connective_tissue_diseases
               when "Nutritional and Metabolic Diseases".downcase
                  well_classified = nutritional_metabolic_diseases
                  total_classified = total_nutritional_metabolic_diseases                   
               when "Endocrine Diseases".downcase
                  well_classified = endocrine_diseases
                  total_classified = total_endocrine_diseases
               when "Immunologic Diseases".downcase
                  well_classified = inmunologic_diseases
                  total_classified = total_inmunologic_diseases
               when "Disorders of Environmental Origin".downcase
                  well_classified = disorders_environmental_origin
                  total_classified = total_disorders_environmental_origin
               when "Animal Diseases".downcase
                  well_classified = animal_diseases
                  total_classified = total_animal_diseases
               when "Pathological Conditions, Signs and Symptoms".downcase
                  well_classified = pathological_conditions_signs_and_symptoms
                  total_classified = total_pathological_conditions_signs_and_symptoms
            end              
            total = hash[:classified].size 
            not_classified = not_classified
            classified = total - not_classified    
            well_classified = well_classified  
            bad_classified = classified - well_classified
            false_positives = total_classified - well_classified
            
            if (well_classified == 0) and (false_positives == 0)
               precision = 0.0
            else
               precision = well_classified.to_f / (well_classified.to_f + false_positives)
            end
            recall = well_classified.to_f / (well_classified.to_f + bad_classified.to_f + not_classified)
            if (precision == 0.0) and (recall == 0.0)
               f1_score = 0
            else
               f1_score = (2 * precision.to_f * recall.to_f) / (precision.to_f + recall.to_f)
            end               
                       
            total_f1_score = total_f1_score + f1_score
            total_precision = total_precision + precision
            total_recall = total_recall + recall                
                                   
            File.open(filename, 'a') do |f2|   
               f2.puts
               f2.puts "Section: "  + hash[:section].to_s
               f2.puts "---------------------------------------------"
               f2.puts "Bacterial Infections and Mycoses: " + bacterial_infections_and_mycoses.to_s
               f2.puts "Virus Diseases: " + virus_diseases.to_s
               f2.puts "Parasitic Diseases: " + parasitic_diseases.to_s
               f2.puts "Neoplasms: " + neoplasms.to_s
               f2.puts "Musculoskeletal Diseases: " + musculoskeletal_diseases.to_s
               f2.puts "Digestive System Diseases: " + digestive_system_diseases.to_s
               f2.puts "Stomatognathic Diseases: " + stomatognathic_diseases.to_s
               f2.puts "Respiratory Tract Diseases: " + respiratory_tract_diseases.to_s
               f2.puts "Otorhinolaryngologic Diseases: " + otorhinolaryngologic_diseases.to_s
               f2.puts "Nervous System Diseases: " + nervous_system_diseases.to_s
               f2.puts "Eye Diseases: " + eye_diseases.to_s
               f2.puts "Urologic and Male Genital Diseases: " + urologic_and_male_genital_diseases.to_s
               f2.puts "Female Genital Diseases and Pregnancy Complications: " + female_genital_diseases.to_s
               f2.puts "Cardiovascular Diseases: " + cardiovascular_diseases.to_s
               f2.puts "Hemic and Lymphatic Diseases: " + hemic_lymphatic_diseases.to_s
               f2.puts "Neonatal Diseases and Abnormalities: " + neonatal_diseases_abnormalities.to_s
               f2.puts "Skin and Connective Tissue Diseases: " + skin_connective_tissue_diseases.to_s
               f2.puts "Nutritional and Metabolic Diseases: " + nutritional_metabolic_diseases.to_s
               f2.puts "Endocrine Diseases: " + endocrine_diseases.to_s
               f2.puts "Immunologic Diseases: " + inmunologic_diseases.to_s
               f2.puts "Disorders of Environmental Origin: " + disorders_environmental_origin.to_s
               f2.puts "Animal Diseases: " + animal_diseases.to_s
               f2.puts "Pathological Conditions, Signs and Symptoms: " + pathological_conditions_signs_and_symptoms.to_s                                                  
               f2.puts
               f2.puts "Total: " + total.to_s
               f2.puts "Classified: " + classified.to_s
               f2.puts "Not classified: " + not_classified.to_s               
               f2.puts "Well classified: " + well_classified.to_s        
               f2.puts "Bad classified: " + bad_classified.to_s
               f2.puts "False positives: " + false_positives.to_s
               f2.puts "Precision: " + precision.to_s
               f2.puts "Recall: " + recall.to_s
               f2.puts "F1-Score: " + f1_score.to_s
               f2.puts         
            end    
         end
         
         f1_score_average = total_f1_score / 23
         precision_average = total_precision / 23
         recall_average = total_recall / 23         
         
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts "Precision average = " + precision_average.to_s
            f2.puts "Recall average = " + recall_average.to_s            
            f2.puts "F1 average = " + f1_score_average.to_s         
            f2.puts "***********************"
         end

      rescue Exception => e
         puts "Exception ohsumed_classifier_statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def oshumed_elements_number_per_category
      begin
         categories_array = ["Bacterial Infections and Mycoses", "Virus Diseases","Parasitic Diseases","Neoplasms","Musculoskeletal Diseases","Digestive System Diseases","Stomatognathic Diseases","Respiratory Tract Diseases",
         "Otorhinolaryngologic Diseases","Nervous System Diseases","Eye Diseases","Urologic and Male Genital Diseases","Female Genital Diseases and Pregnancy Complications","Cardiovascular Diseases",
         "Hemic and Lymphatic Diseases","Neonatal Diseases and Abnormalities","Skin and Connective Tissue Diseases","Nutritional and Metabolic Diseases","Endocrine Diseases","Immunologic Diseases",
         "Disorders of Environmental Origin","Animal Diseases","Pathological Conditions, Signs and Symptoms"]
        
         File.open("ohsumed_number_elements_per_category.txt", 'w') do |f2|
            f2.puts "Training"
            categories_array.each do |category|
               f2.puts category + ": " + ReutersNewItem.where(:cgisplit => "training", :topics=> category).size.to_s
            end
            
            f2.puts
            f2.puts
            
            f2.puts "Test"
            categories_array.each do |category|
               f2.puts category + ": " + ReutersNewItem.where(:cgisplit => "test", :topics=> category).size.to_s
            end
         end         
      rescue Exception => e
         puts "Exception oshumed_elements_number_per_category"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
    
   #######################################################
   ####### twenty_newsgropus_semantic_classifier #########
   #######################################################
   def twenty_newsgroups_semantic_classifier(threshold, training_elements, expanded_concepts_weight)
      begin 
                 
         b = Classifier::Bayes.new "comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"
          
         categories = ["comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"]     
                      
         $stdout = File.new('console_20_newsgropus_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
         
         date = date.to_s + "_" + threshold.to_s + "_semantic_expanded_only_training_" + expanded_concepts_weight.to_s + "_expanded_weight_" +  training_elements.to_s + "_training_"
         
                        
         categories.each do |category|
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category, :cgisplit => "train").first(training_elements).each do |item|
               train_method = "train_" + item.topics
               b.send(train_method, document_to_text(item,threshold, expanded_concepts_weight))               
            end
         end
                                             
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:cgisplit => "test", :topics => category).each do |item|
                classified_array << (b.classify document_to_text_without_expanded_concepts(item,threshold)).to_s
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
         end
                        
         twenty_newsgropus_classifier_statistics(array_hashes_classified ,date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception twenty_newsgroups_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end   
     
   end     
   
   
   ###########################################################
   ####### twenty_newsgropus_non_semantic_classifier #########
   ###########################################################
   def twenty_newsgroups_non_semantic_classifier(training_elements)
      begin 
                 
         b = Classifier::Bayes.new "comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"
          
         categories = ["comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"]     
                      
         $stdout = File.new('console_20_newsgropus_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
         
         date = date.to_s + "_non_semantic_" +  training_elements.to_s + "_training_"
         
         i = 0       
         categories.each do |category|   
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category, :cgisplit => "train").first(training_elements).each do |item|
               train_method = "train_" + item.topics
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end    
               b.send(train_method, item.name + ". " + item.description)            
            end
         end
                                             
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:cgisplit => "test", :topics => category).each do |item|
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end            
               classified_array << (b.classify item.name + ". " + item.description).to_s               
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
         end
                        
         twenty_newsgropus_classifier_statistics(array_hashes_classified ,date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception twenty_newsgroups_non_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end        
   end  
   
   #################################################################
   ####### twenty_newsgroups_classifier_statistics   ###############
   #################################################################
   
   def twenty_newsgropus_classifier_statistics(array_hashes_classified,date, training_elements)
      begin   

         total_ibm_pc_hardware = 0
         total_politics_guns = 0
         total_politics_misc = 0
         total_atheism = 0
         total_autos = 0
         total_sport_hockey = 0
         total_motorcycles = 0
         total_space = 0
         total_mac_hardware = 0
         total_forsale = 0
         total_politics_mideast = 0
         total_religion_misc = 0
         total_med = 0
         total_crypt = 0
         total_windows_misc = 0
         total_graphics = 0
         total_electronics = 0
         total_sport_baseball = 0
         total_windows_x = 0
         total_religion_christian = 0

         total_classified = 0
         total_f1_score = 0.0
         total_precision = 0.0
         total_recall = 0.0         
         filename = "20NG_" + date.to_s  + "statistics.txt"                           
             
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts "Date: " + filename.to_s
            f2.puts "Training elements: " + training_elements.to_s     
            f2.puts "***********************"
         end        

                                                         
         array_hashes_classified.each do |hash|
            hash[:classified].each do |section|
               case section.downcase
                  when "comp.sys.ibm.pc.hardware".downcase
                     total_ibm_pc_hardware += 1
                  when "talk.politics.guns".downcase
                     total_politics_guns += 1
                  when "talk.politics.misc".downcase
                     total_politics_misc += 1                     
                  when "alt.atheism".downcase
                     total_atheism += 1
                  when "rec.autos".downcase
                     total_autos += 1
                  when "rec.sport.hockey".downcase
                     total_sport_hockey += 1
                  when "rec.motorcycles".downcase
                     total_motorcycles += 1
                  when "sci.space".downcase
                     total_space += 1
                  when "comp.sys.mac.hardware".downcase
                     total_mac_hardware += 1     
                  when "misc.forsale".downcase
                     total_forsale += 1
                  when "talk.politics.mideast".downcase
                     total_politics_mideast += 1                     
                  when "talk.religion.misc".downcase
                     total_religion_misc += 1
                  when "sci.med".downcase
                     total_med += 1
                  when "sci.crypt".downcase
                     total_crypt += 1
                  when "comp.os.ms-windows.misc".downcase
                     total_windows_misc += 1
                  when "comp.graphics".downcase
                     total_graphics += 1
                  when "sci.electronics".downcase
                     total_electronics += 1
                  when "rec.sport.baseball".downcase
                     total_sport_baseball += 1                     
                  when "comp.windows.x".downcase
                     total_windows_x += 1
                  when "soc.religion.christian".downcase
                     total_religion_christian += 1                                                        
               end  
            end     
         end       
         array_hashes_classified.each do |hash|
            ibm_pc_hardware = 0
            politics_guns = 0
            politics_misc = 0
            atheism = 0
            autos = 0
            sport_hockey = 0
            motorcycles = 0
            space = 0
            mac_hardware = 0
            forsale = 0
            politics_mideast = 0
            religion_misc = 0
            med = 0
            crypt = 0
            windows_misc = 0
            graphics = 0
            electronics = 0
            sport_baseball = 0
            windows_x = 0
            religion_christian = 0
            not_classified = 0
         
            hash[:classified].each do |section|
               case section.downcase
                  when "comp.sys.ibm.pc.hardware".downcase
                     ibm_pc_hardware += 1
                  when "talk.politics.guns".downcase
                     politics_guns += 1
                  when "talk.politics.misc".downcase
                     politics_misc += 1                     
                  when "alt.atheism".downcase
                     atheism += 1
                  when "rec.autos".downcase
                     autos += 1
                  when "rec.sport.hockey".downcase
                     sport_hockey += 1
                  when "rec.motorcycles".downcase
                     motorcycles += 1
                  when "sci.space".downcase
                     space += 1
                  when "comp.sys.mac.hardware".downcase
                     mac_hardware += 1     
                  when "misc.forsale".downcase
                     forsale += 1
                  when "talk.politics.mideast".downcase
                     politics_mideast += 1                     
                  when "talk.religion.misc".downcase
                     religion_misc += 1
                  when "sci.med".downcase
                     med += 1
                  when "sci.crypt".downcase
                     crypt += 1
                  when "comp.os.ms-windows.misc".downcase
                     windows_misc += 1
                  when "comp.graphics".downcase
                     graphics += 1
                  when "sci.electronics".downcase
                     electronics += 1
                  when "rec.sport.baseball".downcase
                     sport_baseball += 1                     
                  when "comp.windows.x".downcase
                     windows_x += 1
                  when "soc.religion.christian".downcase
                     religion_christian += 1                
                  when "unknown"
                     not_classified += 1
                  when ""           
                     not_classified += 1
                  when " "
                     not_classified += 1                         
               end
            end                      
            case hash[:section].downcase
               when "comp.sys.ibm.pc.hardware".downcase
                  well_classified = ibm_pc_hardware
                  total_classified = total_ibm_pc_hardware
               when "talk.politics.guns".downcase
                  well_classified = politics_guns
                  total_classified = total_politics_guns
               when "talk.politics.misc".downcase
                  well_classified = politics_misc
                  total_classified = total_politics_misc
               when "alt.atheism".downcase
                   well_classified = atheism
                  total_classified = total_atheism
               when "rec.autos".downcase
                  well_classified = autos
                  total_classified = total_autos
               when "rec.sport.hockey".downcase
                  well_classified = sport_hockey
                  total_classified = total_sport_hockey
               when "rec.motorcycles".downcase
                  well_classified = motorcycles
                  total_classified = total_motorcycles
               when "sci.space".downcase
                  well_classified = space
                  total_classified = total_space
               when "comp.sys.mac.hardware".downcase
                  well_classified = mac_hardware
                  total_classified = total_mac_hardware
               when "misc.forsale".downcase
                  well_classified = forsale
                  total_classified = total_forsale
               when "talk.politics.mideast".downcase
                  well_classified = politics_mideast
                  total_classified = total_politics_mideast   
               when "talk.religion.misc".downcase
                  well_classified = religion_misc
                  total_classified = total_religion_misc
               when "sci.med".downcase
                  well_classified = med
                  total_classified = total_med
               when "sci.crypt".downcase
                  well_classified = crypt
                  total_classified = total_crypt
               when "comp.os.ms-windows.misc".downcase
                  well_classified = windows_misc
                  total_classified = total_windows_misc
               when "comp.graphics".downcase
                  well_classified = graphics
                  total_classified = total_graphics
               when "sci.electronics".downcase
                  well_classified = electronics
                  total_classified = total_electronics
               when "rec.sport.baseball".downcase
                  well_classified = sport_baseball
                  total_classified = total_sport_baseball   
               when "comp.windows.x".downcase
                  well_classified = windows_x
                  total_classified = total_windows_x
               when "soc.religion.christian".downcase
                  well_classified = religion_christian
                  total_classified = total_religion_christian
            end              
            total = hash[:classified].size 
            not_classified = not_classified
            classified = total - not_classified    
            well_classified = well_classified  
            bad_classified = classified - well_classified
            false_positives = total_classified - well_classified
            if (well_classified == 0) and (false_positives == 0)
               precision = 0.0
            else
               precision = well_classified.to_f / (well_classified.to_f + false_positives)
            end
            recall = well_classified.to_f / (well_classified.to_f + bad_classified.to_f + not_classified)
            if (precision == 0.0) and (recall == 0.0)
               f1_score = 0
            else
               f1_score = (2 * precision.to_f * recall.to_f) / (precision.to_f + recall.to_f)
            end    
                       
            total_f1_score = total_f1_score + f1_score
            total_precision = total_precision + precision
            total_recall = total_recall + recall            
                           
            File.open(filename, 'a') do |f2|   
               f2.puts
               f2.puts "Section: "  + hash[:section].to_s
               f2.puts "---------------------------------------------"
               f2.puts "comp.sys.ibm.pc.hardware: " + ibm_pc_hardware.to_s
               f2.puts "talk.politics.guns: " + politics_guns.to_s
               f2.puts "talk.politics.misc: " + politics_misc.to_s
               f2.puts "alt.atheism: " + atheism.to_s
               f2.puts "rec.autos: " + autos.to_s
               f2.puts "rec.sport.hockey: " + sport_hockey.to_s
               f2.puts "rec.motorcycles: " + motorcycles.to_s
               f2.puts "sci.space: " + space.to_s
               f2.puts "comp.sys.mac.hardware: " + mac_hardware.to_s
               f2.puts "misc.forsale: " + forsale.to_s
               f2.puts "talk.politics.mideast: " + politics_mideast.to_s
               f2.puts "talk.religion.misc: " + religion_misc.to_s
               f2.puts "sci.med: " + med.to_s
               f2.puts "sci.crypt: " + crypt.to_s
               f2.puts "comp.os.ms-windows.misc: " + windows_misc.to_s
               f2.puts "comp.graphics: " + graphics.to_s
               f2.puts "sci.electronics: " + electronics.to_s
               f2.puts "rec.sport.baseball: " + sport_baseball.to_s
               f2.puts "comp.windows.x: " + windows_x.to_s
               f2.puts "soc.religion.christian: " + religion_christian.to_s                                       
               f2.puts            
               f2.puts "Total: " + total.to_s
               f2.puts "Classified: " + classified.to_s
               f2.puts "Not classified: " + not_classified.to_s               
               f2.puts "Well classified: " + well_classified.to_s        
               f2.puts "Bad classified: " + bad_classified.to_s
               f2.puts "False positives: " + false_positives.to_s
               f2.puts "Precision: " + precision.to_s
               f2.puts "Recall: " + recall.to_s
               f2.puts "F1-Score: " + f1_score.to_s
               f2.puts         
            end    
         end
                          
         f1_score_average = total_f1_score / 20
         precision_average = total_precision / 20
         recall_average = total_recall / 20         
         
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts "Precision average = " + precision_average.to_s
            f2.puts "Recall average = " + recall_average.to_s            
            f2.puts "F1 average = " + f1_score_average.to_s         
            f2.puts "***********************"
         end
         
      rescue Exception => e
         puts "Exception twenty_newsgropus_classifier_statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
     
   
   def twenty_newsgroups_elements_number_per_category
      begin
         
         categories_array = ["comp.sys.ibm.pc.hardware", "talk.politics.guns", "talk.politics.misc", "alt.atheism", "rec.autos", "rec.sport.hockey", "rec.motorcycles", "sci.space", 
         "comp.sys.mac.hardware", "misc.forsale", "talk.politics.mideast", "talk.religion.misc", "sci.med", "sci.crypt", "comp.os.ms-windows.misc", "comp.graphics", 
         "sci.electronics", "rec.sport.baseball", "comp.windows.x", "soc.religion.christian"]     
        
         File.open("20newsgroups_number_elements_per_category.txt", 'w') do |f2|
            f2.puts "Training: " + ReutersNewItem.where(:cgisplit => "train").size.to_s + " elements."
            categories_array.each do |category|
               f2.puts category + ": " + ReutersNewItem.where(:cgisplit => "train", :topics => category).size.to_s
            end
            
            f2.puts
            f2.puts
            
            f2.puts "Test: " + ReutersNewItem.where(:cgisplit => "test").size.to_s + " elements."
            categories_array.each do |category|
               f2.puts category + ": " + ReutersNewItem.where(:cgisplit => "test", :topics => category).size.to_s
            end
         end         
      rescue Exception => e
         puts "Exception twenty_newsgroups_elements_number_per_category"
         puts e.message
         puts e.backtrace.inspect
      end
   end    
   
   
   #######################################################
   ####### ieee_semantic_classifier #########
   #######################################################
   def ieee_semantic_classifier(threshold,training_elements, expanded_concepts_weight)
      begin 
                 
         b = Classifier::Bayes.new "Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience", "Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"
          
         categories = ["Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience", "Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"]     
                      
         $stdout = File.new('console_ieee_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
         
         date = date.to_s + "_" + threshold.to_s + "_semantic_expanded_only_training_" + expanded_concepts_weight.to_s + "_expanded_weight_" +  training_elements.to_s + "_training_"
                
                
         categories.each do |category|
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category).first(training_elements).each do |item|
               train_method = "train_" + item.topics
               b.send(train_method, document_to_text(item,threshold, expanded_concepts_weight))
            end
         end
                                             
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:topics => category).last(138).each do |item|
                classified_array << (b.classify document_to_text_without_expanded_concepts(item,threshold)).to_s
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
         end
                        
         ieee_classifier_statistics(array_hashes_classified, date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception ieee_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end        
   end        
   
   
   ###########################################################
   ####### ieee_non_semantic_classifier #########
   ###########################################################
   def ieee_non_semantic_classifier(training_elements)
      begin 
                 
         b = Classifier::Bayes.new "Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience", "Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"
          
         categories = ["Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience", "Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"]       
                      
         $stdout = File.new('console_ieee_non_semantic_classifier.out', 'w')
         $stdout.sync = true                 
         
         date = Time.now
         
         date = date.to_s + "_non_semantic_" +  training_elements.to_s + "_training_"
         
         categories.each do |category|
            puts "Training " + category + "..."
            ReutersNewItem.where(:topics => category).first(training_elements).each do |item|
               train_method = "train_" + item.topics
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end    
               b.send(train_method, item.name + ". " + item.description) 
            end
         end
                                             
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:topics => category).last(138).each do |item|
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end            
               classified_array << (b.classify item.name + ". " + item.description).to_s               
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
         end
                        
         ieee_classifier_statistics(array_hashes_classified ,date, training_elements)                        
                                          
      rescue Exception => e
         puts "Exception ieee_non_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end        
   end     
   
   #################################################################
   ####### ieee_classifier_statistics                ###############
   #################################################################
   
   def ieee_classifier_statistics(array_hashes_classified,date,training_elements)
      begin   

         total_aerospace = 0
         total_bioengineering = 0
         total_com_networking = 0
         total_comp_circuits = 0
         total_comp_processing = 0
         total_eng_materials = 0
         total_eng_profession = 0
         total_field_waves = 0
         total_geoscience = 0
         total_photonics = 0
         total_power_energy = 0
         total_robotics = 0
         total_sigal_processing = 0
         total_transportation = 0   

         total_classified = 0
         total_f1_score = 0
         total_precision = 0
         total_recall = 0
         filename = ""
           
         filename = "ieee_" + date.to_s  + "statistics.txt"                           
             
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts filename.to_s
            f2.puts "Training elements: " + training_elements.to_s     
            f2.puts "***********************"
         end             
                                                         
         array_hashes_classified.each do |hash|
            hash[:classified].each do |section|
               case section.downcase
                  when "Aerospace".downcase           
                     total_aerospace += 1
                  when "Bioengineering".downcase
                     total_bioengineering += 1
                  when "Communication  Networking .AND. Broadcasting".downcase
                     total_com_networking += 1
                  when "Components  Circuits  Devices .AND. Systems".downcase
                     total_comp_circuits += 1
                  when "Computing .AND. Processing .LB.Hardware/Software.RB.".downcase 
                     total_comp_processing += 1
                  when "Engineered Materials  Dielectrics .AND. Plasmas".downcase
                     total_eng_materials += 1
                  when "Engineering Profession".downcase
                     total_eng_profession += 1
                  when "Fields  Waves .AND. Electromagnetics".downcase
                     total_field_waves += 1
                  when "Geoscience".downcase
                     total_geoscience += 1
                  when "Photonics .AND. Electro-Optics".downcase
                     total_photonics += 1
                  when "Power  Energy  .AND. Industry Applications".downcase
                     total_power_energy += 1
                  when "Robotics .AND. Control Systems".downcase
                     total_robotics += 1
                  when "Signal Processing .AND. Analysis".downcase
                     total_sigal_processing += 1
                  when "Transportation".downcase            
                     total_transportation += 1                                    
               end  
            end     
         end       
         array_hashes_classified.each do |hash|
            aerospace = 0
            bioengineering = 0
            com_networking = 0
            comp_circuits = 0
            comp_processing = 0
            eng_materials = 0
            eng_profession = 0
            field_waves = 0
            geoscience = 0
            photonics = 0
            power_energy = 0
            robotics = 0
            sigal_processing = 0
            transportation = 0   
            not_classified = 0
         
            hash[:classified].each do |section|
               case section.downcase
                  when "Aerospace".downcase           
                     aerospace += 1
                  when "Bioengineering".downcase
                     bioengineering += 1
                  when "Communication  Networking .AND. Broadcasting".downcase
                     com_networking += 1
                  when "Components  Circuits  Devices .AND. Systems".downcase
                     comp_circuits += 1
                  when "Computing .AND. Processing .LB.Hardware/Software.RB.".downcase 
                     comp_processing += 1
                  when "Engineered Materials  Dielectrics .AND. Plasmas".downcase
                     eng_materials += 1
                  when "Engineering Profession".downcase
                     eng_profession += 1
                  when "Fields  Waves .AND. Electromagnetics".downcase
                     field_waves += 1
                  when "Geoscience".downcase
                     geoscience += 1
                  when "Photonics .AND. Electro-Optics".downcase
                     photonics += 1
                  when "Power  Energy  .AND. Industry Applications".downcase
                     power_energy += 1
                  when "Robotics .AND. Control Systems".downcase
                     robotics += 1
                  when "Signal Processing .AND. Analysis".downcase
                     sigal_processing += 1
                  when "Transportation".downcase            
                     transportation += 1     
                  when "unknown"
                     not_classified += 1
                  when ""           
                     not_classified += 1
                  when " "
                     not_classified += 1                         
               end
            end                      
            case hash[:section].downcase
               when "Aerospace".downcase           
                  total_classified = total_aerospace
                  well_classified = aerospace
               when "Bioengineering".downcase
                  total_classified = total_bioengineering
                  well_classified = bioengineering
               when "Communication  Networking .AND. Broadcasting".downcase
                  total_classified = total_com_networking
                  well_classified = com_networking
               when "Components  Circuits  Devices .AND. Systems".downcase
                  total_classified = total_comp_circuits
                  well_classified = comp_circuits
               when "Computing .AND. Processing .LB.Hardware/Software.RB.".downcase 
                  total_classified = total_comp_processing
                  well_classified = comp_processing
               when "Engineered Materials  Dielectrics .AND. Plasmas".downcase
                  total_classified = total_eng_materials
                  well_classified = eng_materials
               when "Engineering Profession".downcase
                  total_classified = total_eng_profession
                  well_classified = eng_profession
               when "Fields  Waves .AND. Electromagnetics".downcase
                  total_classified = total_field_waves
                  well_classified = field_waves
               when "Geoscience".downcase
                  total_classified = total_geoscience
                  well_classified = geoscience
               when "Photonics .AND. Electro-Optics".downcase
                  total_classified = total_photonics
                  well_classified = photonics
               when "Power  Energy  .AND. Industry Applications".downcase
                  total_classified = total_power_energy
                  well_classified = power_energy
               when "Robotics .AND. Control Systems".downcase
                  total_classified = total_robotics
                  well_classified = robotics
               when "Signal Processing .AND. Analysis".downcase
                  total_classified = total_sigal_processing
                  well_classified = sigal_processing
               when "Transportation".downcase            
                  total_classified = total_transportation
                  well_classified = transportation
            end              
            total = hash[:classified].size 
            not_classified = not_classified
            classified = total - not_classified    
            well_classified = well_classified  
            bad_classified = classified - well_classified
            false_positives = total_classified - well_classified
            if (well_classified == 0) and (false_positives == 0)
               precision = 0.0
            else
               precision = well_classified.to_f / (well_classified.to_f + false_positives)
            end
            recall = well_classified.to_f / (well_classified.to_f + bad_classified.to_f + not_classified)
            if (precision == 0.0) and (recall == 0.0)
               f1_score = 0
            else
               f1_score = (2 * precision.to_f * recall.to_f) / (precision.to_f + recall.to_f)
            end    
                       
            total_f1_score = total_f1_score + f1_score
            total_precision = total_precision + precision
            total_recall = total_recall + recall
                                  
            File.open(filename, 'a') do |f2|   
               f2.puts
               f2.puts "Section: "  + hash[:section].to_s
               f2.puts "---------------------------------------------"
               f2.puts "Aerospace: " + aerospace.to_s
               f2.puts "Bioengineering: " + bioengineering.to_s
               f2.puts "Communication  Networking .AND. Broadcasting: " + com_networking.to_s
               f2.puts "Components  Circuits  Devices .AND. Systems: " + comp_circuits.to_s
               f2.puts "Computing .AND. Processing .LB.Hardware/Software.RB.: " + comp_processing.to_s
               f2.puts "Engineered Materials  Dielectrics .AND. Plasmas: " + eng_materials.to_s
               f2.puts "Engineering Profession: " + eng_profession.to_s
               f2.puts "Fields  Waves .AND. Electromagnetics: " + field_waves.to_s
               f2.puts "Geoscience: " + geoscience.to_s
               f2.puts "Photonics .AND. Electro-Optics: " + photonics.to_s
               f2.puts "Power  Energy  .AND. Industry Applications: " + power_energy.to_s 
               f2.puts "Robotics .AND. Control Systems: " + robotics.to_s
               f2.puts "Signal Processing .AND. Analysis: " + sigal_processing.to_s
               f2.puts "Transportation: " + transportation.to_s  
               f2.puts            
               f2.puts "Total: " + total.to_s
               f2.puts "Classified: " + classified.to_s
               f2.puts "Not classified: " + not_classified.to_s               
               f2.puts "Well classified: " + well_classified.to_s        
               f2.puts "Bad classified: " + bad_classified.to_s
               f2.puts "False positives: " + false_positives.to_s
               f2.puts "Precision: " + precision.to_s
               f2.puts "Recall: " + recall.to_s
               f2.puts "F1-Score: " + f1_score.to_s
               f2.puts         
            end    
         end
         
         f1_score_average = total_f1_score / 14
         precision_average = total_precision / 14
         recall_average = total_recall / 14
         
         File.open(filename, 'a') do |f2|
            f2.puts
            f2.puts "***********************"
            f2.puts "Date: " + date.to_s
            f2.puts "Training elements: " + training_elements.to_s
            f2.puts "Precision average = " + precision_average.to_s      
            f2.puts "Recall average = " + recall_average.to_s      
            f2.puts "F1 average = " + f1_score_average.to_s         
            f2.puts "***********************"
         end
         
      rescue Exception => e
         puts "Exception ieee_classifier_statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end      
   
   def ieee_elements_number_per_category
      begin
         
         categories_array = ["Aerospace","Bioengineering","Communication  Networking .AND. Broadcasting", "Components  Circuits  Devices .AND. Systems", "Computing .AND. Processing .LB.Hardware/Software.RB.", 
               "Engineered Materials  Dielectrics .AND. Plasmas", "Engineering Profession" ,"Fields  Waves .AND. Electromagnetics",
               "Geoscience" ,"Photonics .AND. Electro-Optics","Power  Energy  .AND. Industry Applications", 
               "Robotics .AND. Control Systems", "Signal Processing .AND. Analysis","Transportation"]       
        
         File.open("ieee_number_elements_per_category.txt", 'w') do |f2|
            categories_array.each do |category|
               f2.puts category + ": " + ReutersNewItem.where(:topics => category).size.to_s
            end
         end         
      rescue Exception => e
         puts "Exception ieee_elements_number_per_category"
         puts e.message
         puts e.backtrace.inspect
      end
   end       
   
   
   #receives a resource and stores its centroid based weight
   def obtain_centroid_based_weight(resource,wikipediator_ip = nil)
      begin
         wikipediator = Wikipediator.new                     
          
         annotations = resource.taggable_tag_annotations.map{|annotation| annotation}
                     
         annotations.each do |annotation_x|   
            centroid_based_weight = 0
            annotations.each do |annotation_y|            
               relatedness = wikipediator.compare(annotation_x.wikipedia_article_id.to_i, annotation_y.wikipedia_article_id.to_i)
               centroid_based_weight = centroid_based_weight + relatedness.to_f
            end
            centroid_based_weight = centroid_based_weight / annotations.size.to_f
            annotation_x.centroid_based_weight = centroid_based_weight 
            annotation_x.save      
         end
      rescue Exception => e
         puts "Exception obtain_centroid_based_weight"
         puts e.message
         puts e.backtrace.inspect
      end
   end 
   
   def count_corpus_concepts(corpus, threshold=0.01)
      begin
         corpus_number_of_concepts = 0
         document_number_of_concepts = 0
         
         if (corpus.downcase == "ohsumed" || corpus.downcase == "20newsgropus" || corpus.downcase == "ieee" || corpus.downcase == "reuters21578")
            element_type = "ReutersNewItem"
         elsif (corpus.downcase == "reuters27000")
            element_type = "Report"
         end
       
         if threshold == 0.01
            element_type.constantize.all.each do |item|
               document_number_of_concepts = item.taggable_tag_annotations.size
               corpus_number_of_concepts = corpus_number_of_concepts + document_number_of_concepts 
            end
         else
            element_type.constantize.all.each do |item|
               document_number_of_concepts = item.taggable_tag_annotations.where("weight >= ?", threshold).size
               corpus_number_of_concepts = corpus_number_of_concepts + document_number_of_concepts 
            end
         end
         
         return corpus_number_of_concepts
      rescue Exception => e
         puts "Exception count_corpus_concepts"     
         puts e.message
         puts e.backtrace.inspect    
      end
   end
   
   def count_corpus_words(corpus)
      begin
         corpus_number_of_words = 0
         document_number_of_words = 0
         
         if (corpus.downcase == "ohsumed" || corpus.downcase == "20newsgropus" || corpus.downcase == "ieee" || corpus.downcase == "reuters21578")
            element_type = "ReutersNewItem"
         elsif (corpus.downcase == "reuters27000")
            element_type = "Report"
         end
       
         element_type.constantize.all.each do |item|
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end
            
            document_number_of_words = (item.name + ". " + item.description).split.size
            corpus_number_of_words = corpus_number_of_words + document_number_of_words 
         end
                 
         return corpus_number_of_words
      rescue Exception => e
         puts "Exception count_corpus_concepts"     
         puts e.message
         puts e.backtrace.inspect    
      end
   end

   def calculate_conceptual_density(corpus)
      begin
         wikify_thresholds = [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
         
         File.open(corpus + "_conceptual_density.txt", 'w') do |f2|
            corpus_number_of_words = count_corpus_words(corpus)
            f2.puts corpus + " number of words: " + corpus_number_of_words.to_s 
            f2.puts "------------------------------"            
            wikify_thresholds.each do |threshold|
               corpus_number_of_concepts = count_corpus_concepts(corpus,threshold)
               f2.puts "Wikify threshold: " + threshold.to_s
               f2.puts corpus + " number of concepts: " + corpus_number_of_concepts.to_s
               conceptual_density = corpus_number_of_concepts.to_f / corpus_number_of_words.to_f
               f2.puts "Conceptual Density = " + conceptual_density.to_s
               f2.puts "------------------------------"
            end
         end

      rescue Exception => e
         puts "Exception calculate_conceptual_density"
         puts e.message
         puts e.backtrace.inspect           
      end
   end
  

   ###########################################################
   #######    reuters21578_non_semantic_classifier    ########
   ###########################################################
   def reuters_21578_non_semantic_classifier
      begin
         
         b = Classifier::Bayes.new "cocoa", "earn", "acq", "copper", "housing", "money-supply", "coffee", "sugar", "trade", "reserves", "ship", "cotton", "grain", "crude", 
            "nat-gas", "cpi", "interest","money-fx", "alum", "tin", "gold", "strategic-metal","retail", "ipi", "oilseed", "iron-steel", "rubber", "heat", "jobs", 
            "lei", "bop", "gnp", "zinc", "veg-oil", "orange", "carcass", "pet-chem", "gas", "wpi", "livestock", "lumber", "instal-debt", "meal-feed", "lead",
            "potato", "nickel","inventories", "cpu", "l-cattle", "silver", "fuel", "jet", "income", "rand", "platinum", "dlr", "stg", "wool", "tea", "groundnut", 
            "rice", "yen", "hog", "naphtha", "propane", "coconut"
         
         categories = ["cocoa", "earn", "acq", "copper", "housing", "money-supply", "coffee", "sugar", "trade", "reserves", "ship", "cotton", "grain", "crude", 
            "nat-gas", "cpi", "interest","money-fx", "alum", "tin", "gold", "strategic-metal","retail", "ipi", "oilseed", "iron-steel", "rubber", "heat", "jobs", 
            "lei", "bop", "gnp", "zinc", "veg-oil", "orange", "carcass", "pet-chem", "gas", "wpi", "livestock", "lumber", "instal-debt", "meal-feed", "lead",
            "potato", "nickel","inventories", "cpu", "l-cattle", "silver", "fuel", "jet", "income", "rand", "platinum", "dlr", "stg", "wool", "tea", "groundnut", 
            "rice", "yen", "hog", "naphtha", "propane", "coconut"]
                                                                                                
         date = Time.now
         i = 0          
         puts "Training..."
         ReutersNewItem.where(:sde_split => "TRAIN").each do |item|
            train_method = "train_" + item.topics
            if item.name == nil
               item.name = ""
            end
            if item.description == nil
               item.description = ""
            end    
            b.send(train_method, item.name + ". " + item.description)            
            i+=1
            if i.modulo(500) == 0
               puts "Training " + item.topics.to_s
            end
         end
         
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            ReutersNewItem.where(:sde_split => "TEST",:topics => category).each do |item|
               if item.name == nil
                  item.name = ""
               end
               if item.description == nil
                  item.description = ""
               end          
               classified_array << (b.classify item.name + ". " + item.description).to_s               
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
            puts array_hashes_classified
         end
                        
         reuters21578_classifier_statistics(array_hashes_classified ,date)                               

      rescue Exception => e
         puts "Exception reuters21578_non_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end        
   end 
   
   ###########################################################
   #######      reuters21578__semantic_classifier     ########
   ###########################################################
   def reuters_21578_semantic_classifier(threshold)
      begin
         
         b = Classifier::Bayes.new "cocoa", "earn", "acq", "copper", "housing", "money-supply", "coffee", "sugar", "trade", "reserves", "ship", "cotton", "grain", "crude", 
            "nat-gas", "cpi", "interest","money-fx", "alum", "tin", "gold", "strategic-metal","retail", "ipi", "oilseed", "iron-steel", "rubber", "heat", "jobs", 
            "lei", "bop", "gnp", "zinc", "veg-oil", "orange", "carcass", "pet-chem", "gas", "wpi", "livestock", "lumber", "instal-debt", "meal-feed", "lead",
            "potato", "nickel","inventories", "cpu", "l-cattle", "silver", "fuel", "jet", "income", "rand", "platinum", "dlr", "stg", "wool", "tea", "groundnut", 
            "rice", "yen", "hog", "naphtha", "propane", "coconut"
         
         categories = ["cocoa", "earn", "acq", "copper", "housing", "money-supply", "coffee", "sugar", "trade", "reserves", "ship", "cotton", "grain", "crude", 
            "nat-gas", "cpi", "interest","money-fx", "alum", "tin", "gold", "strategic-metal","retail", "ipi", "oilseed", "iron-steel", "rubber", "heat", "jobs", 
            "lei", "bop", "gnp", "zinc", "veg-oil", "orange", "carcass", "pet-chem", "gas", "wpi", "livestock", "lumber", "instal-debt", "meal-feed", "lead",
            "potato", "nickel","inventories", "cpu", "l-cattle", "silver", "fuel", "jet", "income", "rand", "platinum", "dlr", "stg", "wool", "tea", "groundnut", 
            "rice", "yen", "hog", "naphtha", "propane", "coconut"]
          
         sde_split = ReutersNewItem.where(:sde_split => "YES")
                                                                                      
         date = Time.now
         i = 0          
         puts "Training..."
         sde_split.first(7595).each do |item|
            train_method = "train_" + item.topics
            b.send(train_method, document_to_text(item,threshold))        
            i+=1
            if i.modulo(500) == 0
               puts "Training " + item.topics.to_s
            end
         end
         
         array_hashes_classified = Array.new
         
         categories.each do |category|                                                                            
            puts "Classifying " + category + "..."
            classified_array = Array.new
            sde_split.last(1899).where(:topics => category).each do |item|
               classified_array << (b.classify document_to_text(item,threshold)).to_s        
            end
            hash_classified = {:classified => classified_array, :section => category}
            array_hashes_classified << hash_classified
         end
                        
         reuters21578_classifier_statistics(array_hashes_classified ,date)                               

      rescue Exception => e
         puts "Exception reuters21578_semantic_classifier"
         puts e.message
         puts e.backtrace.inspect
      end        
   end    

   #################################################################
   ####### reuters_21578_classifier_statistics       ###############
   #################################################################
   
   def reuters21578_classifier_statistics(array_hashes_classified,date)
      begin 
        
        total_f1_score = 0.0
        total_precision = 0.0
        total_recall = 0.0
        
        categories = ["cocoa", "earn", "acq", "copper", "housing", "money-supply", "coffee", "sugar", "trade", "reserves", "ship", "cotton", "grain", "crude", 
   "nat-gas", "cpi", "interest","money-fx", "alum", "tin", "gold", "strategic-metal","retail", "ipi", "oilseed", "iron-steel", "rubber", "heat", "jobs", 
   "lei", "bop", "gnp", "zinc", "veg-oil", "orange", "carcass", "pet-chem", "gas", "wpi", "livestock", "lumber", "instal-debt", "meal-feed", "lead",
   "potato", "nickel","inventories", "cpu", "l-cattle", "silver", "fuel", "jet", "income", "rand", "platinum", "dlr", "stg", "wool", "tea", "groundnut", 
   "rice", "yen", "hog", "naphtha", "propane", "coconut"]   
                    
         array_hashes_statistics = Array.new
         
         categories.each do |category|
            hash_statistics = {:category => category, :well_classified => 0, :false_positives => 0, :total => 0}
            array_hashes_statistics << hash_statistics
         end
         
    
         filename = "semantic_" + date.to_s  + "_statistics_Reuters21578.txt"                
         File.open(filename, 'a') do |f2|            
            array_hashes_statistics.each do |hash_statistics|
               f2.puts
               f2.puts "Section: "  + hash_statistics[:category].to_s
               f2.puts "---------------------------------------------"
               f2.puts "Well classified = " + hash_statistics[:well_classified].to_s
               f2.puts "False Positives  = " + hash_statistics[:false_positives].to_s
               f2.puts "Total = " + hash_statistics[:total].to_s
               total = hash_statistics[:total]
               well_classified = hash_statistics[:well_classified]             
               false_positives = hash_statistics[:false_positives]
               if (well_classified == 0) and (false_positives == 0)
                  precision = 0.0
               else
                  precision = well_classified.to_f / (well_classified.to_f + false_positives)
               end
               recall = well_classified.to_f / (total)
               if (precision == 0.0) and (recall == 0.0)
                  f1_score = 0
               else
                  f1_score = (2 * precision.to_f * recall.to_f) / (precision.to_f + recall.to_f)
               end    
               
               total_f1_score = total_f1_score + f1_score
               total_precision = total_precision + precision
               total_recall = total_recall + recall
                  
               f2.puts            
               f2.puts "Precision = " + precision.to_s
               f2.puts "Recall = " + recall.to_s
               f2.puts "F1-Score = " + f1_score.to_s
               f2.puts                                        
            end
               f1_score_average = total_f1_score / 66
               precision_average = total_precision / 66
               recall_average = total_recall / 66
               f2.puts
               f2.puts "***********************"
               f2.puts "Precision average = " + precision_average.to_s
               f2.puts "Recall average = " + recall_average.to_s
               f2.puts "F1 average = " + f1_score_average.to_s         
               f2.puts "***********************"            
         end
      rescue Exception => e
         puts "Exception reuters21578_classifier_statistics"
         puts e.message
         puts e.backtrace.inspect
      end
   end    


   def multilabel_classifier
      begin
         maths_classifier = Classifier::Bayes.new "maths", "non_maths"
         science_classifier = Classifier::Bayes.new "science", "non_science"
         
         maths_classifier.send("train_maths","maths maths maths maths maths maths maths maths maths maths maths maths maths maths ")
         maths_classifier.send("train_non_maths", "science science science science science science science science science science ")
         
         puts "Clasificado en:" 
         puts maths_classifier.classify "maths"                                                                                                 
         
      rescue Exception => e
         puts "Exception multilabel_classifier"
         puts e.message
         puts e.backtrace.inspect
      end
   end



def clean
   begin
      ReutersNewItem.first(15).each do |item|
         elements_to_delete = item.taggable_tag_annotations.where(:type_tag => "expanded").size - 100
         item.taggable_tag_annotations.where(:type_tag => "expanded").last(elements_to_delete).each(&:destroy)
      end
   rescue
      puts "exception"
   end
end

def rand_n(n, max)
    randoms = Set.new
    loop do
        randoms << rand(max)+86
        return randoms.to_a if randoms.size >= n
    end
end

def split_oercommons_train_test(n,max)
   begin
      puts "Obteniendo ids aleatorios"
      ids = rand_n(n,max)
      i = 0
      ids.each do |id|
         i+=1
         puts "Marcando como train el elemento con id " + id.to_s
         puts "elemento numero " + i.to_s + " marcado"
         item = ReutersNewItem.find_by_id(id)
         item.cgisplit = "train"
         item.save
      end
   rescue Exception => e
      puts "Exception_split_oercommons_train_test"
      puts e.message
      puts e.backtrace.inspect
   end
end

def split_oer_commons_test
   begin 
      i=0
      ReutersNewItem.where(:cgisplit => nil).each do |item|
         i += 1
         item.cgisplit = "test"
         puts "Marcando como train el elemento con id " + item.id.to_s
         puts "elemento numero " + i.to_s + " marcado"
         item.save
      end
   rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
   end
end

def count
   array = Array.new
   max = 0
   id = 0
   ReutersNewItem.all.each do |item|
      cats = item.topics.split(",")
      if cats.size > max
         max = cats.size
         id = item.id
      end
      cats.each do |cat|
         array << cat.strip
      end
      array = array.uniq
   end
   puts "Categories: "
   puts array
   puts "Categories size: "
   puts array.size
   puts "Max categories per item: "
   puts max
   puts "Item ID: "
   puts id
end


def oercommons_label_cardinality_and_label_density
   begin
      number_of_labels = 21
      corpus_size = 98156
      corpus_labels = 0
      corpus_density_labels = 0
      ReutersNewItem.all.each do |item|
        item_labels = item.topics.split(",").size
        corpus_labels = corpus_labels + item_labels
        density_labels = item_labels.to_f / number_of_labels.to_f
        corpus_density_labels = corpus_density_labels.to_f + density_labels.to_f        
      end
      label_cardinality = corpus_labels.to_f / corpus_size.to_f
      label_density = corpus_density_labels.to_f / corpus_size.to_f
      puts "Label Cardinality = " + label_cardinality.to_s
      puts "Label Density = " + label_density.to_s
   rescue Exception => e
      puts "Exception oercommons_label_cardinality_and_label_density"
      puts e.message
      puts e.backtrace.inspect
   end
end

def merlot_label_cardinality_and_label_density
   begin
      number_of_labels = 9
      corpus_size = 23166
      corpus_labels = 0
      corpus_density_labels = 0
      ReutersNewItem.all.each do |item|
        item_labels = item.topics.split(",").size
        corpus_labels = corpus_labels + item_labels
        density_labels = item_labels.to_f / number_of_labels.to_f
        corpus_density_labels = corpus_density_labels.to_f + density_labels.to_f        
      end
      label_cardinality = corpus_labels.to_f / corpus_size.to_f
      label_density = corpus_density_labels.to_f / corpus_size.to_f
      puts "Label Cardinality = " + label_cardinality.to_s
      puts "Label Density = " + label_density.to_s
   rescue Exception => e
      puts "Exception oercommons_label_cardinality_and_label_density"
      puts e.message
      puts e.backtrace.inspect
   end
end

def cnx_label_cardinality_and_label_density
   begin
      number_of_labels = 6
      corpus_size = 11795
      corpus_labels = 0
      corpus_density_labels = 0
      ReutersNewItem.all.each do |item|
        item_labels = item.topics.split(",").size
        corpus_labels = corpus_labels + item_labels
        density_labels = item_labels.to_f / number_of_labels.to_f
        corpus_density_labels = corpus_density_labels.to_f + density_labels.to_f        
      end
      label_cardinality = corpus_labels.to_f / corpus_size.to_f
      label_density = corpus_density_labels.to_f / corpus_size.to_f
      puts "Label Cardinality = " + label_cardinality.to_s
      puts "Label Density = " + label_density.to_s
   rescue Exception => e
      puts "Exception oercommons_label_cardinality_and_label_density"
      puts e.message
      puts e.backtrace.inspect
   end
end



def ohsumed_label_cardinality_and_label_density
   begin
      number_of_labels = 28
      corpus_size = 84969
      corpus_labels = 0
      corpus_density_labels = 0
      ReutersNewItem.all.each do |item|
        item_labels = item.topics.split(",").size
        corpus_labels = corpus_labels + item_labels
        density_labels = item_labels.to_f / number_of_labels.to_f
        corpus_density_labels = corpus_density_labels.to_f + density_labels.to_f        
      end
      label_cardinality = corpus_labels.to_f / corpus_size.to_f
      label_density = corpus_density_labels.to_f / corpus_size.to_f
      puts "Label Cardinality = " + label_cardinality.to_s
      puts "Label Density = " + label_density.to_s
   rescue Exception => e
      puts "Exception ohsumed_label_cardinality_and_label_density"
      puts e.message
      puts e.backtrace.inspect
   end
end


def split_merlot_test
   begin
      i = 0
      while i < 7894
         id = (84 + rand(47787))
         if (ReutersNewItem.where(:id => id).size != 0) and (ReutersNewItem.where(:id => id)[0].cgisplit == nil)
            puts "Marcando como test el elemento con id " + id.to_s
            item = ReutersNewItem.find_by_id(id)
            i+=1
            item.cgisplit = "test"
            puts "Guardando el elemento en la base de datos"
            item.save
         end
      end
   rescue Exception => e
      puts "Exception_split_oercommons_train_test"
      puts e.message
      puts e.backtrace.inspect
   end
end

def split_merlot_train
   begin 
      i=0
      ReutersNewItem.where(:cgisplit => nil).each do |item|
         i += 1
         item.cgisplit = "train"
         puts "Marcando como train el elemento con id " + item.id.to_s
         puts "elemento numero " + i.to_s + " marcado"
         item.save
      end
   rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
   end
end

def obtain_resource_concept_graph(resource)
   begin
      start_time = Time.now
      annotations = Array.new
      relatedness_weight = 0
      concept_weight = 0
      wikipediator = Wikipediator.new
      n = resource.taggable_tag_annotations.size
      resource.taggable_tag_annotations.each do |annotation_x|         
         concept_weight = 0         
         relatedness_weight = 0
         resource.taggable_tag_annotations.each do |annotation_y|
            relatedness = wikipediator.compare(annotation_x.wikipedia_article_id,annotation_y.wikipedia_article_id)
            if relatedness == nil
               relatedness = 0
            end
            relatedness_weight = relatedness_weight + relatedness.to_f * annotation_y.weight * annotation_x.weight
         end
         relatedness_weight = relatedness_weight/n
         concept_weight = annotation_x.weight + relatedness_weight
         annotations << {:name => annotation_x.tag.name.to_s, :weight => concept_weight, :relatedness_weight => relatedness_weight}
         annotations = annotations.sort_by{|hsh| hsh[:weight]}
         annotations = annotations.reverse        
      end
      puts annotations
      final_time = Time.now
      execution_time = final_time - start_time
      puts "Execution time: " + execution_time.to_s
   rescue Exception => e
      puts "Exception obtain_resource_concept_graph"
      puts e.message
      puts e.backtrace.inspect
   end
end

def print_resource_annotations(resource)
   begin
      annotations = Array.new
      resource.taggable_tag_annotations.each do |annotation|
         annotations << annotation.tag.name.to_s + " " + annotation.weight.to_s
      end
      puts annotations
   rescue Exception => e
      puts "Exception print_resource_annotations (classify.rb)"
      puts e.message
      puts e.backtrace.inspect
   end
end





   
end