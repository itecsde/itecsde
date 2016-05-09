# encoding: utf-8

require "nokogiri"
require "open-uri"
require 'capybara/rails'
require "capybara"
require "capybara/dsl"
require 'watir-webdriver'
require 'net/http'
require 'net/https'
require 'uri'
require 'mechanize'

class AcquisCorpusCreator
   include ActionView::Helpers::SanitizeHelper
   
   def create_eurovoc_thesaurus
      begin
         eurovoc_domains = Array.new
         eurovoc_domains_url = "http://eurovoc.europa.eu/drupal/?q=navigation&cl=en"
         eurovoc_domains_nokogiri_page = Nokogiri::HTML(open(eurovoc_domains_url))
         
         #helper_root_node = Eurovoc.new
         
         #helper_root_node.add_root_helper_node("helper_root_node","root_helper",nil,"RH_0")
         
         array_eurovocs_domains = [
         "16 ECONOMICS",
"20 TRADE",
"24 FINANCE",
"28 SOCIAL QUESTIONS",
"32 EDUCATION AND COMMUNICATIONS",
"36 SCIENCE",
"40 BUSINESS AND COMPETITION",
"44 EMPLOYMENT AND WORKING CONDITIONS",
"48 TRANSPORT",
"52 ENVIRONMENT",
"56 AGRICULTURE, FORESTRY AND FISHERIES",
"60 AGRI-FOODSTUFFS",
"64 PRODUCTION, TECHNOLOGY AND RESEARCH",
"66 ENERGY",
"68 INDUSTRY",
"72 GEOGRAPHY",
"76 INTERNATIONAL ORGANISATIONS",
         ]
         
         eurovoc_domains_nokogiri_page.css("ul#navigationPageUl li span").each do |eurovoc_domain|
            if array_eurovocs_domains.include? eurovoc_domain.text
               domain = eurovoc_domain.text
               eurovoc_domain_id = domain.scan(/\d+|\D+/)[0]
               domain_name = domain.scan(/\d+|\D+/)[1].strip
               new_eurovoc_node = Eurovoc.new
               
               new_eurovoc_node.add_node(domain_name,"domain","RH_0","DM_" + eurovoc_domain_id.to_s)
                     
               hash_domain_id_domain_name = {:id => eurovoc_domain_id, :name => domain_name}
               eurovoc_domains << hash_domain_id_domain_name
               
               eurovoc_domains_nokogiri_page.css("ul#navigationPageUl li ul li").each do |eurovoc_mt|
                  parent = eurovoc_mt.parent     
                  parent_previous = parent.previous
                  if parent_previous.text == eurovoc_domain_id + " " + domain_name
                     mt = eurovoc_mt.text
                     puts mt
                     mt_id = mt.scan(/\d+|\D+/)[0]
                     mt_name = mt.scan(/\d+|\D+/)[1].strip
                     new_eurovoc_node = Eurovoc.new
                     
                     new_eurovoc_node.add_node(mt_name,"MT","DM_" + eurovoc_domain_id.to_s,"MT_" + mt_id.to_s)
                     
                     mt_url = eurovoc_mt.css("a")[0]['href'].split("http")[1]
                     mt_url = "http" + mt_url       
                     obtain_eurovoc_nodes_from_micro_thesaurus mt_url, mt_id          
                  end
               end
            end
            #puts "Estoy esperando"
            #sleep 100000000000000                 
         end         
         puts eurovoc_domains
      rescue Exception => e
         puts "Exception create_eurovoc_thesaurus"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def obtain_eurovoc_nodes_from_micro_thesaurus(mt_url, mt_id)
      begin
         mt_nokogiri_page = Nokogiri::HTML(open(mt_url))
         mt_nokogiri_page.css("div.mtContainer div.tt").each do |tt|
            top_term = tt.css("a.tooltip")[0].text.strip
            puts
            puts
            puts top_term
            tt_aux = tt
            tt_name = top_term
            tt_url = tt.css("a.tooltip")[0]['href'].split("http")[1]
            tt_url = "http" + tt_url
            eurovoc_code = obtain_eurovoc_code tt_url, "TT"            
            tt_code = eurovoc_code
            tt_parent_id = mt_id
            new_eurovoc_node = Eurovoc.new
            new_eurovoc_node.add_node(tt_name, "TT","MT_" + mt_id.to_s,"TT_" + tt_code.to_s)
                     
            while tt_aux.next_element['class'] != "tt"
               if tt_aux.next_element['class'] == "nt1" or tt_aux.next_element['class'] == "nt2" or tt_aux.next_element['class'] == "nt3" or tt_aux.next_element['class'] == "nt4" or tt_aux.next_element['class'] == "nt5"
                  name = tt_aux.next_element.css("a")[0].text.strip
                  type_node = tt_aux.next_element.css("label.tooltip")[0].text    
                  nt_url = tt_aux.next_element.css("a")[0]['href'].split("http")[1]
                  nt_url = "http" + nt_url
                  eurovoc_code = obtain_eurovoc_code nt_url, type_node.downcase
                  puts type_node + " : " + name + " : " + eurovoc_code.to_s
                  if type_node.downcase == "nt1"
                     parent_id_aux = eurovoc_code
                  elsif type_node.downcase == "nt2"
                     parent_id_aux_2 = eurovoc_code
                  elsif type_node.downcase == "nt3"
                     parent_id_aux_3 = eurovoc_code
                  elsif type_node.downcase == "nt4"
                     parent_id_aux_4 = eurovoc_code
                  end
                  if type_node.downcase == "nt1"
                     parent_id = tt_code
                     new_eurovoc_node = Eurovoc.new
                     new_eurovoc_node.add_node(name,tt_aux.next_element['class'].upcase,"TT_" + parent_id.to_s,"NT_1_" + eurovoc_code.to_s)                        
                  elsif type_node.downcase == "nt2"
                     parent_id = parent_id_aux
                     new_eurovoc_node = Eurovoc.new
                     new_eurovoc_node.add_node(name,tt_aux.next_element['class'].upcase,"NT_1_" + parent_id.to_s,"NT_2_" + eurovoc_code.to_s)                        
                  elsif type_node.downcase == "nt3"
                     parent_id = parent_id_aux_2    
                     new_eurovoc_node = Eurovoc.new
                     new_eurovoc_node.add_node(name,tt_aux.next_element['class'].upcase,"NT_2_" + parent_id.to_s,"NT_3_" + eurovoc_code.to_s)                        
                  elsif type_node.downcase == "nt4"
                     parent_id = parent_id_aux_3
                     new_eurovoc_node = Eurovoc.new
                     new_eurovoc_node.add_node(name,tt_aux.next_element['class'].upcase,"NT_3_" + parent_id.to_s,"NT_4_" + eurovoc_code.to_s)                        
                  elsif type_node.downcase == "nt5"
                     parent_id = parent_id_aux_4
                     new_eurovoc_node = Eurovoc.new
                     new_eurovoc_node.add_node(name,tt_aux.next_element['class'].upcase,"NT_4_" + parent_id.to_s,"NT_5_" + eurovoc_code.to_s)                        
                  end                                                                
               end
               tt_aux = tt_aux.next_element
            end           
         end
                 
      rescue Exception => e
         puts "Exception obtain_eurovoc_nodes_from_micro_thesaurus"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   def obtain_eurovoc_code(nt_url, type_node)
      begin
         nt_nokogiri_page = Nokogiri::HTML(open(nt_url))         
         eurovoc_code = nt_nokogiri_page.css("div.termContainer div.termColumn.hierarchy div.concepturi label.tooltip a")[0].text
         eurovoc_code = eurovoc_code.gsub("http://eurovoc.europa.eu/","")
         return eurovoc_code
            
      rescue Exception => e
         puts "Exception obtain_eurovoc_code"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   def eurovoc_code_without_type
      begin
         Eurovoc.all.each do |eurovoc|
            puts eurovoc.eurovoc_id
            eurovoc.eurovoc_id_without_type = eurovoc.eurovoc_id.gsub("NT_1_","").gsub("NT_2_","").gsub("NT_3_","").gsub("NT_4_","").gsub("NT_5_","").gsub("TT_","").gsub("MT_","").gsub("DM_","").gsub("RH_","")
            eurovoc.save
         end
      rescue Exception => e
         puts "Exception eurovoc_code_without_type"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   
   
   def create_acquis_corpus(lang)
      begin        
         eurovoc_codes = Array.new 
         categories_array = Array.new
         description = ""
         topics = ""
         a=Eurovoc.new
         for year in 1995..2006 do 
            Dir.chdir("/home/marcos/Descargas/jrc-" + lang.to_s +  "/" + year.to_s)  
            files = Dir.glob "*"
            files.each do |file|
               eurovoc_codes = Array.new
               categories_array = Array.new
               topics = ""
               description = ""
               file_id = file
               xml_page = Nokogiri::XML(open(file))                           
               xml_page.xpath("//TEI.2/teiHeader/profileDesc/textClass/classCode").each do |eurovoc_code|
                  eurovoc_codes << eurovoc_code.text.strip                
               end               
               topics = eurovoc_codes.join(",")
               eurovoc_codes.each do |eurovoc_code|
                  categories_array << a.get_first_level(a.obtain_eurovoc_id_correspondence(eurovoc_code))
               end
               
               categories_array = categories_array.uniq
               
               body = xml_page.xpath("//TEI.2/text/body/div")[0]
               body.xpath("p").each do |p|
                  description = description + " " + p.text
               end
                         
               new_item = ReutersNewItem.new
               new_item.description = description
               new_item.file_id = file_id
               new_item.topics = categories_array.join(",")
               new_item.places = topics
               new_item.dateline = year
               new_item.persist                        
            end     
         end         
      rescue Exception => e
         puts "create_acquis_corpus_es"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
def prepare_categories_jrc_acquis_corpus_en
   begin
    
      ReutersNewItem.where("topics like '%agriculture, forestry and fisheries%'").each do |item|
         topics = item.topics
         topics = topics.gsub("AGRICULTURE, FORESTRY AND FISHERIES","AGRICULTURE AND FORESTRY AND FISHERIES")
         item.topics = topics
         item.save
      end
      ReutersNewItem.where("topics like '%production, technology and research%'").each do |item|
         topics = item.topics
         topics = topics.gsub("PRODUCTION, TECHNOLOGY AND RESEARCH","PRODUCTION AND TECHNOLOGY AND RESEARCH")
         item.topics = topics
         item.save
      end      
      ReutersNewItem.where("topics like '%,,%'").each do |item|
         topics = item.topics
         topics = topics = topics.gsub(",,",",")
         item.topics = topics
         item.save
      end
      
      ReutersNewItem.where("topics like '%,'").each do |item|
         topics = item.topics
         topics = topics[0..topics.length-2]
         item.topics = topics
         item.save
      end             
            
      
   rescue Exception => e
      puts "Exception prepare_categories_jrc_acquis_corpus_en"
      puts e.message
      puts e.backtrace.inspect
      
   end
end         
      
def prepare_categories_jrc_acquis_corpus_es_to_en
   begin
      ReutersNewItem.where(:cgisplit => "test").where("topics like '%agriculture, forestry and fisheries%'").each do |item|
         topics = item.topics
         topics = topics.gsub("AGRICULTURE, FORESTRY AND FISHERIES","AGRICULTURE AND FORESTRY AND FISHERIES")
         item.topics = topics
         item.save
      end
      ReutersNewItem.where(:cgisplit => "test").where("topics like '%production, technology and research%'").each do |item|
         topics = item.topics
         topics = topics.gsub("PRODUCTION, TECHNOLOGY AND RESEARCH","PRODUCTION AND TECHNOLOGY AND RESEARCH")
         item.topics = topics
         item.save
      end      
      ReutersNewItem.where(:cgisplit => "test").where("topics like '%,,%'").each do |item|
         topics = item.topics
         topics = topics.gsub(",,",",")
         item.topics = topics
         item.save
      end        
      ReutersNewItem.where(:cgisplit => "test").where("topics like '%,'").each do |item|
         topics = item.topics
         topics = topics[0..topics.length-2]
         item.topics = topics
         item.save
      end           
      
   rescue Exception => e
      puts "Exception prepare_categories_jrc_acquis_corpus_es_to_en"
      puts e.message
      puts e.backtrace.inspect
      
   end
end          
  
def export_jrc_document_to_json(id)
   begin
      array_tags = Array.new
      reuters_item = ReutersNewItem.where(:id => id)[0]
      
      item = {:id => reuters_item.id,
            :description => reuters_item.description}
      reuters_item.taggable_tag_annotations.each do |tag|
         tag_item = {:name => tag.tag.name,
            :weight => tag.weight,
            :wikipedia_article => "http://en.wikipedia.org/wiki/" + tag.tag.name.gsub(" ","_")}
         array_tags << tag_item
      end
      item[:topics] = reuters_item.topics      
      item[:annotations_size] = reuters_item.taggable_tag_annotations.size
      item[:annotations] = array_tags
      File.open('jrc_acquis/' + reuters_item.id.to_s + '.json', 'w') do |f2|    
         f2.puts JSON.generate(item)              
      end           
      
   rescue Exception => e
      puts "Exception export_jrc_document_to_json"
      puts e.message
      puts e.backtrace.inspect
   end
end

def export_jrc_document_to_json_es_to_en(id)
   begin
      array_tags = Array.new
      array_translated_tags = Array.new
      reuters_item = ReutersNewItem.where(:id => id)[0]
      
      item = {:id => reuters_item.id,
            :original_description => reuters_item.info_to_wikify,
            :translated_description => reuters_item.description}
      reuters_item.taggable_tag_annotations.where(:type_tag => "automatic").each do |tag|
         tag_item = {:name => tag.tag.name,
            :weight => tag.weight,
            :wikipedia_article => "http://es.wikipedia.org/wiki/" + tag.tag.name.gsub(" ","_")}
         array_tags << tag_item
      end
      
      reuters_item.taggable_tag_annotations.where(:type_tag => "translated").each do |tag|
         tag_item = {:name => tag.tag.name,
            :weight => tag.weight,
            :wikipedia_article => "http://en.wikipedia.org/wiki/" + tag.tag.name.gsub(" ","_")}
         array_translated_tags << tag_item
      end      
      
      item[:topics] = reuters_item.topics      
      item[:annotations_size] = reuters_item.taggable_tag_annotations.where(:type_tag => "automatic").size
      item[:annotations] = array_tags
      item[:converted_annotations_size] = reuters_item.taggable_tag_annotations.where(:type_tag => "translated").size      
      item[:converted_annotations] = array_translated_tags      
      File.open('jrc_acquis/' + reuters_item.id.to_s + '.json', 'w') do |f2|    
         f2.puts JSON.generate(item)              
      end           
      
   rescue Exception => e
      puts "Exception export_jrc_document_to_json"
      puts e.message
      puts e.backtrace.inspect
   end
end
  
def select_best_and_worst_features
   #it is necessary to swith the database to simplified_jrc_acquis_en in databas.yml
   begin
      cont = 0
      file = File.open("/home/marcos/Dropbox/workspace_python/wikitopics_classifier/source/features_200_training_RandonForestClassifier.txt","r")
      while cont < 1772
         line = file.gets
         line = line.split(")")[1].strip
         line = line.split("0.")[0].strip
         if line.include? "("
            line = line + ")"
         end
         ActiveRecord::Base.connection.execute('update annotations set expanded_from = 1 where name = "' + line + '";')
         cont += 1
         puts cont
      end
      print "Poner a 0 el campo expanded from las que el campo expanded_from sea null"
      
   rescue Exception => e
      puts "Exception select_best_and_worst_features"
      puts e.message
      puts e.backtrace.inspect
   end
end
   
end