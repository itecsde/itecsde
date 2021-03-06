# encoding: utf-8
module Taggable
  
  def self.included(base)
    base.class_eval do
      has_many :annotations
      has_many :taggable_tag_annotations, :as => :taggable, :dependent => :destroy
      has_many :tags, :through => :taggable_tag_annotations
    end
  end
  
  def create_automatic_semantic_annotations(prosa)
    begin
      TaggableTagAnnotation.destroy_all(:taggable_id =>self.id, :type_tag =>"automatic")
      automatic_tags_ids = Array.new
      wikipediator = Wikipediator.new
      entries = wikipediator.search(self.name)
      if entries.length > 0
        entries[0]['title']
        if Tag.find_by_name(entries[0]['title'])!=nil
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = Tag.find_by_name(entries[0]['title'])
          new_annotation.type_tag = "automatic"
          new_annotation.wikipedia_article_id = entries[0]['id']
          new_annotation.weight = 1.0
          new_annotation.save
          #Sunspot.index new_annotation                    
          #Sunspot.commit          
        else
          new_tag=Tag.new
          new_tag.name=entries[0]['title']
          new_tag.save
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = new_tag
          new_annotation.type_tag = "automatic"
          new_annotation.wikipedia_article_id = entries[0]['id']            
          new_annotation.weight = 1.0
          new_annotation.save
          Sunspot.index new_tag
          #Sunspot.index new_annotation                    
          Sunspot.commit          
        end         
      end
      prosa = prosa #.force_encoding("binary")
      puts "Proceeding to wikify. Text to wikify:"
      puts prosa
      tags_automatic = wikipediator.wikify(prosa)
      puts tags_automatic
      if tags_automatic != nil
        puts "WIKIPEDIADO!!!!!!!!!!!!!!"
        self.scraping_status.automatically_tagged = true
        tags_automatic.each do |tag|
          automatic_tags_ids << tag['id']                    
          if Tag.find_by_name(tag['title'])!=nil
            new_annotation = TaggableTagAnnotation.new
            new_annotation.taggable = self
            new_annotation.tag = Tag.find_by_name(tag['title'])
            new_annotation.type_tag = "automatic"
            new_annotation.wikipedia_article_id = tag['id']
            new_annotation.weight=tag['weight']
            new_annotation.save
            #Sunspot.index new_annotation                    
            #Sunspot.commit          
          else
            new_tag=Tag.new
            new_tag.name=tag['title']
            new_tag.save
            new_annotation = TaggableTagAnnotation.new
            new_annotation.taggable = self
            new_annotation.tag = new_tag
            new_annotation.type_tag = "automatic"
            new_annotation.wikipedia_article_id = tag['id']            
            new_annotation.weight=tag['weight']
            new_annotation.save
            Sunspot.index new_tag
            #Sunspot.index new_annotation                    
            Sunspot.commit         
          end         
        end #do |tag|
        if self.respond_to?('scraped_from') && Source.find_by_url(self.scraped_from) != nil
          source = Source.find_by_url(self.scraped_from)  
          source.last_tagged = Time.now
          source.tagged_correct = true
          source.save
        end
      else
          puts "NO WIKIPEDIADO!!!!!!!!!!!!!!"
          self.scraping_status.automatically_tagged = false
      end
      self.scraping_status.save
      return automatic_tags_ids    
    rescue Exception => e
      puts "Failed automatic tags (wikify) --> Taggable"
      puts e.message
      puts e.backtrace.inspect
      if self.respond_to?('scraped_from') && Source.find_by_url(self.scraped_from) != nil
        source = Source.find_by_url(self.scraped_from)
        source.tagged_correct = false
        source.save
      end
    end  
  end #create_automatic_semantic_annotations
  
  def create_semantic_annotations(tags)
    begin
      TaggableTagAnnotation.destroy_all(:taggable_id =>self.id, :type_tag =>"human")
      tags.each do |tag|           
        tag = tag.strip
        if Tag.find_by_name(tag)!=nil
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = Tag.find_by_name(tag)
          new_annotation.type_tag = "human"
          new_annotation.save          
        else
          new_tag=Tag.new
          new_tag.name=tag
          new_tag.save
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = new_tag
          new_annotation.type_tag = "human"
          new_annotation.save
          Sunspot.index new_tag                    
          Sunspot.commit
         end          
       end #do |tag|
    rescue Exception => e
      puts "Failed Human Tags --> Taggable"
      puts e.message
      puts e.backtrace.inspect
    end      
  end #create_semantic_annotations
  
  def create_translated_to_english_semantic_annotations(tags)
    begin
      tags.each do |tag|           
        tag = tag.strip
        if Tag.find_by_name(tag)!=nil
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = Tag.find_by_name(tag)
          new_annotation.type_tag = "human"
          new_annotation.save          
        else
          new_tag=Tag.new
          new_tag.name=tag
          new_tag.save
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = new_tag
          new_annotation.type_tag = "human"
          new_annotation.save
          Sunspot.index new_tag                    
          Sunspot.commit
         end          
       end #do |tag|
    rescue Exception => e
      puts "Failed Translated Human Tags --> Taggable"
      puts e.message
      puts e.backtrace.inspect
    end      
  end #create_translated_to_english_semantic_annotations
    
  
  def tag_list_with_links
    list_tags = ""
    self.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human","expanded"]).order('weight DESC').map {|annotation| annotation.tag}.each do |tag|        
      if list_tags.size > 0 && tag.name != nil
        list_tags += ", " + ActionController::Base.helpers.link_to(Util.to_hashtag(tag.name) , "/"+I18n.locale.to_s+Rails.application.routes.url_helpers.search_results_path(:search => Util.to_hashtag(tag.name))) 
      elsif tag.name != nil
        list_tags += ActionController::Base.helpers.link_to(Util.to_hashtag(tag.name) , "/"+I18n.locale.to_s+Rails.application.routes.url_helpers.search_results_path(:search => Util.to_hashtag(tag.name)))
      end        
    end
    return list_tags    
  end
  
    def translated_tag_list_with_links
    list_tags = ""
    self.taggable_tag_annotations.where(:type_tag => ["translated"]).order('weight DESC').map {|annotation| annotation.tag}.each do |tag|        
      if list_tags.size > 0 && tag.name != nil
        list_tags += ", " + ActionController::Base.helpers.link_to(Util.to_hashtag(tag.name) , "/"+I18n.locale.to_s+Rails.application.routes.url_helpers.search_results_path(:search => Util.to_hashtag(tag.name))) 
      elsif tag.name != nil
        list_tags += ActionController::Base.helpers.link_to(Util.to_hashtag(tag.name) , "/"+I18n.locale.to_s+Rails.application.routes.url_helpers.search_results_path(:search => Util.to_hashtag(tag.name)))
      end        
    end
    return list_tags    
  end
  
  
  
  def tag_list
    self.taggable_tag_annotations.order('weight DESC').map {|annotation| annotation.tag.name}.join(", ")
  end  
  
  def document_tag_list
    self.annotations.order('weight DESC').map {|annotation| annotation.tag.name}.join(", ")
  end  
  
  def document_tag_list_with_links
    list_tags = ""
    self.annotations.map {|annotation| annotation}.each do |tag|        
      if list_tags.size > 0 && tag != nil
        list_tags += ", " + Util.to_hashtag(tag.name) 
      elsif tag != nil
        list_tags += Util.to_hashtag(tag.name)
      end        
    end
    return list_tags    
  end
  
  def document_keywords
    list_tags = ""
    self.annotations.map {|annotation| annotation}.each do |tag|        
      if list_tags.size > 0 && tag != nil
        list_tags += ", " + tag.name 
      elsif tag != nil
        list_tags += tag.name
      end        
    end
    return list_tags    
  end
    
  
  def refresh_automatic_semantic_annotations    
    if self.taggable_tag_annotations.where(:type_tag => "automatic").size == 0
      begin
        automatic_tags_ids = Array.new
        wikipediator = Wikipediator.new
        ##Miramos de wikipediar el nombre con un peso mayor
        if self.name != nil && self.name != ""
          entries = wikipediator.search(self.name)
          if entries.length > 0
            entries[0]['title']
            if Tag.find_by_name(entries[0]['title']) != nil
              new_annotation = TaggableTagAnnotation.new
              new_annotation.taggable = self
              new_annotation.tag = Tag.find_by_name(entries[0]['title'])
              new_annotation.type_tag = "automatic"
              new_annotation.wikipedia_article_id = entries[0]['id']
              new_annotation.weight = 1.0
              new_annotation.save
              #Sunspot.index new_annotation                    
              #Sunspot.commit           
            else
              new_tag=Tag.new
              new_tag.name=entries[0]['title']
              new_tag.save
              new_annotation = TaggableTagAnnotation.new
              new_annotation.taggable = self
              new_annotation.tag = new_tag
              new_annotation.type_tag = "automatic"
              new_annotation.wikipedia_article_id = entries[0]['id']            
              new_annotation.weight = 1.0
              new_annotation.save
              Sunspot.index new_tag
              #Sunspot.index new_annotation                    
              Sunspot.commit          
            end         
          end
        end
        if self.info_to_wikify != nil && self.info_to_wikify != ""
          prosa = self.info_to_wikify
        else
          if self.name != nil && self.description != nil
            prosa = self.name + ". " + self.description
          elsif self.name != nil
            prosa = self.name
          elsif self.description != nil
            prosa = self.description
          else
            prosa = ""
          end
        end 
        puts "Proceeding to wikify. Text to wikify:"
        puts prosa
        tags_automatic = wikipediator.wikify(prosa)
        puts tags_automatic
        if tags_automatic != nil
          puts "WIKIPEDIADO!!!!!!!!!!!!!!"
          self.scraping_status.automatically_tagged = true
          tags_automatic.each do |tag|
            automatic_tags_ids << tag['id']                    
            if Tag.find_by_name(tag['title'])!=nil
              new_annotation = TaggableTagAnnotation.new
              new_annotation.taggable = self
              new_annotation.tag = Tag.find_by_name(tag['title'])
              new_annotation.type_tag = "automatic"
              new_annotation.wikipedia_article_id = tag['id']
              new_annotation.weight=tag['weight']
              new_annotation.save
              #Sunspot.index new_annotation                    
              #Sunspot.commit          
            else
              new_tag=Tag.new
              new_tag.name=tag['title']
              new_tag.save
              new_annotation = TaggableTagAnnotation.new
              new_annotation.taggable = self
              new_annotation.tag = new_tag
              new_annotation.type_tag = "automatic"
              new_annotation.wikipedia_article_id = tag['id']            
              new_annotation.weight=tag['weight']
              new_annotation.save
              Sunspot.index new_tag
              #Sunspot.index new_annotation                    
              Sunspot.commit    
            end         
          end #do |tag|
          if self.respond_to?('scraped_from') && Source.find_by_url(self.scraped_from) != nil
            source = Source.find_by_url(self.scraped_from)  
            source.last_tagged = Time.now
            source.tagged_correct = true
            source.save
          end
        else
          puts "NO WIKIPEDIADO!!!!!!!!!!!!!!"
          self.scraping_status.automatically_tagged = false  
        end
        self.scraping_status.save
        return automatic_tags_ids
      rescue Exception => e
        puts "Failed refresh automatic tags (wikify) --> Taggable"
        puts e.message
        puts e.backtrace.inspect
        if self.respond_to?('scraped_from') && Source.find_by_url(self.scraped_from) != nil
          source = Source.find_by_url(self.scraped_from)
          source.tagged_correct = false
          source.save
        end
      end
    elsif self.respond_to?('scraped_from')
      source = Source.find_by_url(self.scraped_from)
      source.tagged_correct = true
      source.last_tagged = Time.now
      source.save
    end
  end
     
   
  def convert_human_to_automatic_tags
    human_annotations=self.taggable_tag_annotations.where(:type_tag => [nil,"","human"])
    automatic_to_human_annotations = self.taggable_tag_annotations.where(:type_tag => "automatic_from_human")
    
    automatic_tags_ids = Array.new
    #Miramos si hay tags humanos y no hay tags automatic_from_human
    if human_annotations.size > 0 && automatic_to_human_annotations.size == 0
      wikipediator = Wikipediator.new
      tags_automatic=wikipediator.complex_search(human_annotations.map{|p| p.tag.name}.join(","))
      
      puts "TAGS HUMANOS:"
      puts human_annotations.map{|p| p.tag.name}.join(",")
      if tags_automatic != nil && tags_automatic.size > 0
        puts "TAGS AUTOMATICOS:"
        puts tags_automatic.map{|p| p['title']}.join(",")
      end
      tags_automatic.each do |tag|
        automatic_tags_ids << tag['id']                    
        if Tag.find_by_name(tag['title'])!=nil
          existent_annotations=self.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human"],:wikipedia_article_id => tag['id'])
          #Si existe ya tiene un tag automatico igual se le mente como se le cambia a automatic_from_human 
          if existent_annotations.size > 0
            puts "HAY TAGS automaticos coincidentes a los automatic_from_human nuevos los actualizo"
            existent_annotation=existent_annotations.first
            existent_annotation.type_tag = "automatic_from_human"
            if existent_annotation.weight < 0.90
              existent_annotation.weight = 0.90
            end
            existent_annotation.save
          #Si no existe ya tiene un tag automatico igual se crea una annotation nueva de tipo automatic_from_human 
          else          
            new_annotation = TaggableTagAnnotation.new
            new_annotation.taggable = self
            new_annotation.tag = Tag.find_by_name(tag['title'])
            new_annotation.type_tag = "automatic_from_human"
            new_annotation.wikipedia_article_id = tag['id']
            new_annotation.weight = 0.90
            new_annotation.save
          end
          
        else
          new_tag=Tag.new
          new_tag.name=tag['title']
          new_tag.save
          new_annotation = TaggableTagAnnotation.new
          new_annotation.taggable = self
          new_annotation.tag = new_tag
          new_annotation.type_tag = "automatic_from_human"
          new_annotation.wikipedia_article_id = tag['id']            
          new_annotation.weight = 0.90
          new_annotation.save
          Sunspot.index new_tag
          Sunspot.commit          
        end         
      end
    else
      puts "No hay Tags humanos o ya se hizo la conversion a automaticos" 
    end
    return automatic_tags_ids
  end
     
  def convert_human_tags_to_wikitopics(human_tags)
    begin
      wikitopics = Array.new
      query = human_tags.map{|p| p.gsub("-"," ").gsub("_"," ").gsub("&"," ")}.join(" and ")
      wikipediator = Wikipediator.new
      wikitopics = wikipediator.complex_search(query)
      wikitopics.each do |wikitopic|   
        puts self.class
        puts self.id        
        if TaggableTagAnnotation.find_by_taggable_id_and_taggable_type_and_weight_and_type_tag_and_wikipedia_article_id(self.id,self.class,0.90,"automatic_from_human",wikitopic['id']) == nil
          if Tag.find_by_name(wikitopic['title'])!=nil
            existent_annotations=self.taggable_tag_annotations.where(:type_tag => ["automatic","automatic_from_human"],:wikipedia_article_id => wikitopic['id'])
            #Si existe ya tiene un tag automatico igual se le mente como se le cambia a automatic_from_human 
            if existent_annotations.size > 0
              puts "HAY TAGS automaticos coincidentes a los automatic_from_human nuevos los actualizo"
              existent_annotation=existent_annotations.first
              existent_annotation.type_tag = "automatic_from_human"
              if existent_annotation.weight < 0.90
                existent_annotation.weight = 0.90
              end
              existent_annotation.save
            #Si no existe ya tiene un tag automatico igual se crea una annotation nueva de tipo automatic_from_human 
            else          
              new_annotation = TaggableTagAnnotation.new
              new_annotation.taggable = self
              new_annotation.tag = Tag.find_by_name(wikitopic['title'])
              new_annotation.type_tag = "automatic_from_human"
              new_annotation.wikipedia_article_id = wikitopic['id']
              new_annotation.weight = 0.90
              new_annotation.save
            end
          else
            new_tag = Tag.new
            new_tag.name = wikitopic['title']
            new_tag.save
            new_annotation = TaggableTagAnnotation.new
            new_annotation.taggable = self
            new_annotation.tag = new_tag
            new_annotation.type_tag = "automatic_from_human"
            new_annotation.wikipedia_article_id = wikitopic['id']            
            new_annotation.weight = 0.90
            new_annotation.save
            Sunspot.index new_tag
            #Sunspot.index new_annotation                    
            Sunspot.commit    
          end     
        end    
      end
    rescue Exception => e
      puts "Exception convert_human_tags_to_wikitopics"
      puts e.message
      puts e.backtrace.inspect
    end
  end
  
  def add_annotation (name, weight, type, wikitopic_id)
    begin
      #if Tag.where("name = '#{name}' collate utf8_bin")[0] != nil
      if false
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self 
        new_annotation.tag = Tag.find_by_name(name)
        new_annotation.type_tag = type
        new_annotation.wikipedia_article_id = wikitopic_id            
        new_annotation.weight = weight
        new_annotation.save
        Sunspot.commit  
      else
        new_tag = Tag.new
        new_tag.name = name
        new_tag.save
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self
        new_annotation.tag = new_tag
        new_annotation.type_tag = type
        new_annotation.wikipedia_article_id = wikitopic_id            
        new_annotation.weight = weight
        new_annotation.save
        Sunspot.index new_tag
        Sunspot.commit
      end
    rescue Exception => e
      puts "EXCEPCION IN ADD_ANNOTATION"
      puts e.message
      #puts e.backtrace.inspect
    end        
  end
  
  def add_simplified_annotation (name, weight, type, wikitopic_id)
    begin
        new_annotation = Annotation.new
        new_annotation.document_id = self.id
        new_annotation.name = name
        new_annotation.old_id = wikitopic_id            
        new_annotation.weight = weight
        #new_annotation.expanded_from = "6969" #automatic_spanish_esa
        new_annotation.expanded_from = "9999"
        new_annotation.save
    rescue Exception => e
      puts "EXCEPCION IN add_simplified_annotation"
      puts e.message
      puts e.backtrace.inspect
    end        
  end 
  
   
  def add_simplified_metamap_annotation (name, cui)
    begin
        new_annotation = Annotation.new
        new_annotation.document_id = self.id
        new_annotation.name = name
        new_annotation.old_id = cui.gsub("C","")
        new_annotation.weight = 1
        new_annotation.expanded_from = "8888"
        new_annotation.save
    rescue Exception => e
      puts "EXCEPCION IN add_simplified_annotation"
      puts e.message
      puts e.backtrace.inspect
    end        
  end    
   
  
  def add_metamap_annotation(name, cui)
    begin
      #if Tag.where("name = '#{name}' collate utf8_bin")[0] != nil
      if false
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self 
        new_annotation.tag = Tag.find_by_name(name)
        new_annotation.type_tag = cui            
        new_annotation.save
        Sunspot.commit  
      else
        new_tag = Tag.new
        new_tag.name = name
        new_tag.save
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self
        new_annotation.tag = new_tag
        new_annotation.type_tag = cui            
        new_annotation.save
        Sunspot.index new_tag
        Sunspot.commit
      end
    rescue Exception => e
      puts "EXCEPCION IN ADD_ANNOTATION"
      puts e.message
      #puts e.backtrace.inspect
    end        
  end   
  
  def add_expanded_annotation (expanded_from, name, relatedness, type, wikitopic_id)
    begin
      if Tag.find_by_name(name) != nil
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self 
        new_annotation.tag = Tag.find_by_name(name)
        new_annotation.type_tag = type
        new_annotation.wikipedia_article_id = wikitopic_id            
        new_annotation.relatedness = relatedness
        new_annotation.expanded = true
        new_annotation.expanded_from = expanded_from
        new_annotation.weight = relatedness.to_f  * TaggableTagAnnotation.find(expanded_from).weight.to_f
        new_annotation.save
        Sunspot.commit  
      else
        new_tag = Tag.new
        new_tag.name = name
        new_tag.save
        new_annotation = TaggableTagAnnotation.new
        new_annotation.taggable = self
        new_annotation.tag = new_tag
        new_annotation.type_tag = type
        new_annotation.wikipedia_article_id = wikitopic_id            
        new_annotation.relatedness = relatedness
        new_annotation.expanded = true   
        new_annotation.expanded_from = expanded_from
        new_annotation.weight = relatedness.to_f  * TaggableTagAnnotation.find(expanded_from).weight.to_f           
        new_annotation.save
        Sunspot.index new_tag
        Sunspot.commit
      end
    rescue Exception => e
      puts e
      puts "EXCEPCION IN ADD_ANNOTATION"
      puts e.message
    end        
  end   
  
  def extract_metamap_topics (prose)
     begin
        
        wikipediator = Wikipediator.new
        array = Array.new
        
        metamap_topics =  wikipediator.metamap_it(prose)
        
        metamap_topics.each do |metamap_topic|
           #add_metamap_annotation(metamap_topic[:candidate_matched], metamap_topic[:cui])
           add_simplified_metamap_annotation(metamap_topic[:candidate_preferred], metamap_topic[:cui])
           puts metamap_topic[:candidate_matched]
           puts metamap_topic[:candidate_preferred]
           puts metamap_topic[:cui]
           array << metamap_topic[:candidate_preferred]
        end
          
        puts metamap_topics.size.to_s + " topics"
        
        unique = array.uniq
        
        puts unique.size.to_s  + " unique topics"
        
        #return metamap_topics            
     rescue Exception => e
        puts "Exception extract_metamap_topics"
        puts e.message
        puts e.backtrace.inspect
     end
  end
  
  def extract_esa_topics (title, description)
    puts "Proceding to extract_wikitopics only from description"
    begin
      if description == nil
        description = ""
      end
      if title == nil
        title = ""
      end 
      description = title + ". " + description
      wikipediator = Wikipediator.new
      esatopics = wikipediator.esa_it(description)
      if esatopics == nil
        esatopics = Array.new
      end     
      esatopics.each do |esatopic|
        add_simplified_annotation(esatopic[:name], esatopic[:weight], "esa", esatopic[:wikipedia_article_id])
      end
      #return esatopics                 
    rescue Exception => e
       puts "Exception extract_esa_topics"
       puts e.message
       puts e.backtrace.inspect       
    end
  end      
  
  def extract_wikitopics (name, description, manual_tags, wikipediator_ip = nil)
    puts "Proceding to extract_wikitopics"
    puts wikipediator_ip
    begin
      if description == nil
        description = ""
      end
      if name == nil
        name = ""
      end
      wikitopics_from_description = extract_wikitopics_from_description(description, wikipediator_ip)
      if wikitopics_from_description == nil
        wikitopics_from_description = Array.new
      end
      wikitopics_from_manual_tags = extract_wikitopics_from_manual_tags(manual_tags, wikitopics_from_description.first(5), wikipediator_ip)
      if wikitopics_from_manual_tags == nil
        wikitopics_from_manual_tags = Array.new
      end
      wikitopics_from_name_and_manual_tags = extract_wikitopics_from_name(name, wikitopics_from_manual_tags.first(5), wikipediator_ip)
      wikitopics_from_name_and_manual_tags = (wikitopics_from_manual_tags + wikitopics_from_name_and_manual_tags).uniq{|x| x[:name]}
      filtered_wikitopics_from_description = Array.new

      wikitopics_from_description.each do |wikitopic_from_description|
        if !wikitopic_from_description[:name].in? wikitopics_from_name_and_manual_tags.map{|wikitopic| wikitopic[:name]}
          filtered_wikitopics_from_description << wikitopic_from_description
        end
      end      
      filtered_wikitopics_from_description.each do |wikitopic|       
        add_annotation(wikitopic[:name], wikitopic[:weight], "automatic", wikitopic[:wikipedia_article_id])
      end
      wikitopics_from_name_and_manual_tags.each do |wikitopic|
        add_annotation(wikitopic[:name], 1.0, "automatic_from_human", wikitopic[:wikipedia_article_id])
      end
          
      wikitopics = filtered_wikitopics_from_description + wikitopics_from_name_and_manual_tags
      return wikitopics    
                
    rescue Exception => e
      puts e.backtrace.inspect       
    end
  end   
     
     
  def extract_wikitopics_only_from_title_and_description (title, description, wikipediator_ip = nil)
    puts "Proceding to extract_wikitopics only from description"
    begin
      if description == nil
        description = ""
      end
      if title == nil
        title = ""
      end
      
      description = title + ". " + description
      
      wikitopics_from_description = extract_wikitopics_from_description(description, wikipediator_ip)
      if wikitopics_from_description == nil
        wikitopics_from_description = Array.new
      end
            
      wikitopics_from_description.each do |wikitopic|       
        add_annotation(wikitopic[:name], wikitopic[:weight], "automatic", wikitopic[:wikipedia_article_id])
      end
         
      wikitopics = wikitopics_from_description
      
      #puts "wikitopics"
      #puts wikitopics
      #puts "wikitopics end"
      
      return wikitopics    
                
    rescue Exception => e
      puts e.backtrace.inspect       
    end
  end      
  
  def store_expanded_wikitopics(resource, threshold_concept_weight, threshold_expanded_concept_relatedness, wikipediator_ip = nil)
  #def store_expanded_wikitopics(resource, concepts_to_expand, expanded_concepts, wikipediator_ip = nil)
    puts "Proceding to expand concepts of resource"
    begin
      #expanded_wikitopics = expand_resource(resource,concepts_to_expand, expanded_concepts, wikipediator_ip)
      expanded_wikitopics = expand_resource_incrementally(resource,threshold_concept_weight, threshold_expanded_concept_relatedness, wikipediator_ip)
      if expanded_wikitopics == nil
        expanded_wikitopics = Array.new
      end

      expanded_wikitopics.each do |wikitopic|
        add_expanded_annotation(wikitopic[:expanded_from], wikitopic[:name], wikitopic[:relatedness], "expanded", wikitopic[:wikipedia_article_id])
      end
         
      wikitopics = expanded_wikitopics
      return wikitopics    
                
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect       
    end
  end 
      
  def expand_resource(resource, concepts_to_expand, expanded_concepts, wikipediator_ip = nil)   
      puts "Proceeding to expand resource"  
      expanded_wikitopics = Array.new
      wikipediator = Wikipediator.new
      resource.taggable_tag_annotations.first(concepts_to_expand).each do |annotation|
         wikipediator.expand_it(annotation.id, annotation.wikipedia_article_id, expanded_concepts, wikipediator_ip = nil).each do |expansion|
            expanded_wikitopics << expansion
         end  
      end  
      return expanded_wikitopics
  end
     
def initialize_thresholds
   begin
      ReutersNewItem.all.each do |item|
         item.wikify_threshold = 1
         item.relatedness_threshold = 1
         item.save
      end
   rescue Exception => e
      puts "Exception initialize_thresholds"
      puts e.message
      puts e.backtrace.inspect
   end
end     
     
  def expand_resource_incrementally(resource, threshold_concept_weight, threshold_expanded_concept_relatedness, wikipediator_ip = nil)   
      puts "Proceeding to expand resource incrementally"  
      expanded_wikitopics = Array.new
      wikipediator = Wikipediator.new
      if resource.wikify_threshold == nil || resource.wikify_threshold == ""
         resource.wikify_threshold = 1
      end
      if resource.relatedness_threshold == nil || resource.relatedness_threshold == ""
         resource.relatedness_threshold = 1
      end      
      if threshold_concept_weight.to_f < resource.wikify_threshold.to_f
         old_wikify_threshold = resource.wikify_threshold
         old_relatedness_threshold = resource.relatedness_threshold
         resource.wikify_threshold = threshold_concept_weight
         resource.relatedness_threshold = threshold_expanded_concept_relatedness
         resource.save
         
         resource.taggable_tag_annotations.where(:type_tag => "automatic").where("weight >= ?", threshold_concept_weight).where("weight <= ?", old_wikify_threshold).each do |annotation|
            wikipediator.expand_it_incrementally(annotation.id, annotation.wikipedia_article_id, threshold_expanded_concept_relatedness, old_relatedness_threshold, 1, wikipediator_ip = nil).each do |expansion|
               expanded_wikitopics << expansion
            end  
         end  
      elsif threshold_expanded_concept_relatedness.to_f < resource.relatedness_threshold.to_f
         old_relatedness_threshold = resource.relatedness_threshold
         resource.relatedness_threshold = threshold_expanded_concept_relatedness   
         resource.save
         resource.taggable_tag_annotations.where(:type_tag => "automatic").where("weight >= ?", threshold_concept_weight).each do |annotation|
            wikipediator.expand_it_incrementally(annotation.id, annotation.wikipedia_article_id, threshold_expanded_concept_relatedness, old_relatedness_threshold, 0, wikipediator_ip = nil).each do |expansion|
               expanded_wikitopics << expansion
            end  
         end  
      else
         puts "Resource already expanded."
      end
      return expanded_wikitopics
  end

   def concept_translation(concept, original_language, target_language)
      begin
         url = URI.encode("https://" + original_language.to_s + ".wikipedia.org/wiki/" + concept)
         wikipedia_page = Nokogiri::HTML(open(url))
         if !wikipedia_page.css("div.body ul li.interlanguage-link.interwiki-" + target_language.to_s + " a").empty?
            translated_concept = URI.decode(wikipedia_page.css("div.body ul li.interlanguage-link.interwiki-" + target_language.to_s + " a")[0]['href'])
            translated_concept = translated_concept.gsub("//" + target_language.to_s + ".wikipedia.org/wiki/","").gsub("_"," ")
         elsif !wikipedia_page.css("div.body ul li.interlanguage-link.interwiki-" + "simple" + " a").empty?
            translated_concept = URI.decode(wikipedia_page.css("div.body ul li.interlanguage-link.interwiki-" + "simple" + " a")[0]['href'])
            translated_concept = translated_concept.gsub("//" + "simple" + ".wikipedia.org/wiki/","").gsub("_"," ")
            #puts "El concepto correspondiente en el idioma " + target_language.to_s + " es: " + translated_concept.to_s
         else
            puts "No existe correspondencia"
            puts url
         end
      rescue Exception => e
         puts "Exception concept translation (classify.rb)"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   #For ReutersNewItem Annotations
   def document_language_concept_correspondence(document, original_language, target_language)
      begin
         array = Array.new
         array_original = Array.new
         document.taggable_tag_annotations.where(:type_tag => "automatic").each do |annotation|
            correspondent_concept = concept_translation(annotation.tag.name,original_language,target_language)
            #array_original << {:name => annotation.tag.name, :weight => annotation.weight}         
            if correspondent_concept != nil
               #array << {:name => correspondent_concept, :weight => annotation.weight}
               add_annotation(correspondent_concept, annotation.weight, "translated", annotation.wikipedia_article_id)               
            end
         end
         #puts array_original
         #puts array
      rescue Exception => e
         puts "Exception document_es_en_concept_correspondence"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   #For document simplified annotations
   def simplified_document_language_concept_correspondence(document, original_language, target_language)
      begin
         array = Array.new
         document.annotations.each do |annotation|
            correspondent_concept = concept_translation(annotation.name,original_language,target_language)   
            if correspondent_concept != nil
               add_simplified_annotation(correspondent_concept, annotation.weight, "", annotation.old_id)               
            end
         end
      rescue Exception => e
         puts "Exception document_es_en_concept_correspondence"
         puts e.message
         puts e.backtrace.inspect
      end
   end


     
     
     
  def extract_wikitopics_from_description (description, wikipediator_ip = nil)
    puts "Proceeding to extract wikitopics from description"
    wikipediator = Wikipediator.new
    wikitopics_from_description = wikipediator.wikify_it(description, wikipediator_ip)
  end   
    
  def extract_wikitopics_from_manual_tags (manual_tags, control_tags, wikipediator_ip = nil)  
    puts "Proceeding to extract wikitopics from manual tags"
    wikipediator = Wikipediator.new
    manual_tags_length = manual_tags.length
    # Descartar a partir del primer label que incluya texto del primer tag de control
    wikitopics_from_manual_tags = wikipediator.complex_search_it(manual_tags.map{|manual_tag| manual_tag}.join(" and ") + " and " +  control_tags.map{|control_tag| control_tag[:name].to_s}.join(" and "), wikipediator_ip = nil)
    wikitopics_from_manual_tags.first(manual_tags.length)
  end
  
  def extract_wikitopics_from_name (name, control_tags, wikipediator_ip = nil)
    puts "Proceeding to extract wikitopics from name"
    wikipediator = Wikipediator.new
    wikitopics_from_name_and_control_tags = wikipediator.complex_search_it(name + " and " + control_tags.map{|control_tag| control_tag[:name].to_s}.join(" and "), wikipediator_ip)
    wikitopics_from_name_and_control_tags
  end
  
end
