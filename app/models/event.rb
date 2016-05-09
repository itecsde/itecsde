class Event < ActiveRecord::Base
  include Taggable
  include Ownable
  include Wikipediable
  include Aggregable  
  include Globalizable
  include Categorizable
  include Scrapeable
 
  extend FriendlyId
  friendly_id :name, use: :slugged
 
  translates :name
  translates :description
  translates :link
  #translates :address
  geocoded_by :address
  #after_validation :geocode  
  #before_save :annotate
  
  searchable do
    integer :id
    text :name
    latlon(:location) { Sunspot::Util::Coordinates.new(latitude, longitude) }
    
    location :geohash_location do
      Sunspot::Util::Coordinates.new(latitude, longitude)
    end 
    
    text :tags do |p|
      p.tags.map(&:name)
    end
    
    text :w100_wikitopics, :as => :w100_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight == 1.0)}
    end
    text :w95_wikitopics, :as => :w95_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.95 && annotation.weight < 1.0)}
    end
    text :w90_wikitopics, :as => :w90_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.90 && annotation.weight < 0.95)}
    end
    text :w85_wikitopics, :as => :w85_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.85 && annotation.weight < 0.90)}
    end
    text :w80_wikitopics, :as => :w80_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.80 && annotation.weight < 0.85)}
    end
    text :w75_wikitopics, :as => :w75_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.75 && annotation.weight < 0.80)}
    end
    text :w70_wikitopics, :as => :w70_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.70 && annotation.weight < 0.75)}
    end
    text :w65_wikitopics, :as => :w65_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.65 && annotation.weight < 0.70)}
    end
    text :w60_wikitopics, :as => :w60_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.60 && annotation.weight < 0.65)}
    end
    text :w55_wikitopics, :as => :w55_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.55 && annotation.weight < 0.60)}
    end
    text :w50_wikitopics, :as => :w50_wikitopics do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.50 && annotation.weight < 0.55)}
    end

    text :hashtags_100 do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight == 1.0)}
    end
    text :hashtags_95 do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.95 && annotation.weight < 1.0)}
    end
    text :hashtags_90 do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.9 && annotation.weight < 0.95)}
    end
    text :hashtags_85 do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.85 && annotation.weight < 0.9)}
    end
    text :hashtags_80 do |elem|
       elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.8 && annotation.weight < 0.85)}
    end
    text :hashtags_75 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.75 && annotation.weight < 0.8)}
    end
    text :hashtags_70 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.7 && annotation.weight < 0.75)}
    end
    text :hashtags_65 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.65 && annotation.weight < 0.7)}
    end
    text :hashtags_60 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.6 && annotation.weight < 0.65)}
    end
    text :hashtags_55 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight >= 0.55 && annotation.weight < 0.6)}
    end    
    text :hashtags_50 do |elem|
      elem.taggable_tag_annotations.map{|annotation| annotation.tag.hashtag if ((annotation.type_tag == "automatic" or annotation.type_tag == "automatic_from_human") && annotation.weight < 0.55)}
    end

    
    text :categories do |p|
      p.categories.map(&:name)
    end
    text :subjects do |p|
      p.subjects.map(&:name)
    end
    string :translations, :multiple => true do
      translations.map{|translation| translation.locale}
    end 
    string :itec_id
    time :start_date, :trie => true
    I18n.available_locales.each do |locale|
      text "description_" + locale.to_s do
        read_attribute(:description, :locale => locale.to_s)
      end
    end
    
    integer :owner_id
    time :updated_at
  end
  
   
  has_many :event_concrete_requirement_event_annotations, :as => :resource
  has_many :event_concrete_requirement_event_assignments 
  has_many :event_requirement_event_assignments
  
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  has_many :event_subject_annotations, :dependent => :destroy
  has_many :subjects, :through => :event_subject_annotations
  
  belongs_to :education_level
  belongs_to :contextual_language
  
  
  # Relationship with bookmarked_by users
  has_many :bookmark_user_element_annotations, :as => :element, :dependent => :destroy
  has_many :bookmarked_by, :through => :bookmark_user_element_annotations, :source =>:user
  
  
  accepts_nested_attributes_for :event_subject_annotations, :allow_destroy => :true
  
  attr_accessible :element_image, :name, :description, :url, :link, :event_subject_annotations_attributes, :education_level_id, :contextual_language_id, :address, :latitude, :longitude, :start_date,:end_date,:age_range, :owner_type, :owner_id, :tag_list
  has_attached_file :element_image, :styles => { :original => "300x300>", :medium => "200x200>", :thumb => "30x30>" }, :default_url => "none"
  
  def tag_list=(new_value)
    tag_names = new_value.split(/,\s+/)
    self.tags = tag_names.map { |name| Tag.where('name = ?', name).first or Tag.create(:name => name.strip) }
  end
   
  def persist(idiomas_disponibles, prosa, manual_tags)
      
    if (self.address!=nil && self.start_date!=nil)
      hash_event=Digest::MD5.hexdigest(self.name+self.description+self.start_date+self.address)
    elsif (self.address==nil && self.start_date!=nil)
      hash_event=Digest::MD5.hexdigest(self.name+self.description+self.start_date)
    else
      hash_event=Digest::MD5.hexdigest(self.name+self.description)
    end
    check_result = Scraper.check_resource_storage_state(self.class.to_s ,self.url, hash_event)
       
    if check_result=="insert"
      if self.address != nil && (self.latitude.nil? or self.longitude.nil?)
        puts "Vamos a geolocalizar evento"        
        begin
          scraper=Scraper.new
          arr_coordinates = scraper.geolocate_address(self.address)
          if arr_coordinates.size > 1
            self.latitude= arr_coordinates[0]          
            self.longitude = arr_coordinates[1]            
          end          
          if arr_coordinates.size >= 1
            self.scraping_status.geolocalized = true
            if arr_coordinates.size > 1
              self.scraping_status.geolocalized_by = arr_coordinates[2]
            else
              self.scraping_status.geolocalized_by = arr_coordinates[0]
            end 
          end
         
        rescue
          puts "Failed geolocation Event.persist"
        end

      elsif self.latitude != nil && self.longitude != nil                
        self.scraping_status.geolocalized = true
        self.scraping_status.geolocalized_by = "manual" 
        self.scraping_status.save
      end
      
      self.info_to_wikify = prosa
      self.extract_wikitopics(self.name, prosa, manual_tags)
      #self.categorize(automatic_tags_ids)
      self.hash_resource = hash_event
      self.save      
      self.reload
      Sunspot.index self
      Sunspot.commit
      return
    elsif check_result == "update"
      puts "ACTUALIZAMOS EVENTO"     
      scraped_event = Event.where(:url=> url)[0]
      idiomas_disponibles.each do |idioma|
        I18n.locale = idioma
        scraped_event.name = self.name
        scraped_event.link = self.link
        scraped_event.description = self.description
      end
      scraped_event.start_date = self.start_date
      scraped_event.end_date = self.end_date
      scraped_event.address = self.address
      if (self.address!=nil) && ((self.latitude==nil) || (self.longitude==nil))
        begin
          scraper=Scraper.new
          arr_coordinates=scraper.geolocate_address(self.address)
          if arr_coordinates.size > 1
            scraped_event.latitude=arr_coordinates[0]
            scraped_event.longitude =arr_coordinates[1]          
          end
          if arr_coordinates.size >= 1
            scraped_event.scraping_status.geolocalized = true
            if arr_coordinates.size > 1
              scraped_event.scraping_status.geolocalized_by = arr_coordinates[2]
            else
              scraped_event.scraping_status.geolocalized_by = arr_coordinates[0]
            end 
          end
        rescue
          puts "Failed geolocation Event.persist"
        end
      elsif (self.latitude!=nil && self.longitude!=nil)
        scraped_event.scraping_status.geolocalized = true
        scraped_event.scraping_status.geolocalized_by= "manual"
        scraped_event.scraping_status.save 
      end
      scraped_event.info_to_wikify = prosa
      scraped_event.extract_wikitopics(self.name, prosa, manual_tags)
      #scraped_event.categorize(automatic_tags_ids)
      scraped_event.hash_resource = hash_event
      scraped_event.url = self.url
      scraped_event.scraped_from = self.scraped_from
      scraped_event.save
      scraped_event.reload
      Sunspot.index scraped_event
      Sunspot.commit
      return
    end
    puts "NO HACE FALTA INSERTAR NI ACTUALIZAR EL EVENTO"

    if Event.where(:url=> self.url).size != 0
      event = Event.find_by_url(self.url)
      if (idiomas_sin_traducciones = idiomas_disponibles - event.translated_locales) != []
        puts "ACTUALIZAMOS TRADUCCIONES"
        idiomas_sin_traducciones.each do |idioma|
          I18n.locale = idioma
          puts I18n.locale
          puts self.description
          event.name = self.name
          event.description = self.description
          event.link = self.link
          event.save
        end
      else
        puts "LAS TRADUCCIONES ESTAN COMPLETAS. NO HACEMOS NADA"
      end
    end
    return  
  end
   
  
  def generate_hash
    if (address!=nil && start_date!=nil)
      hash_event=Digest::MD5.hexdigest(name+description+start_date+address)
    elsif (address==nil && start_date!=nil)
      hash_event=Digest::MD5.hexdigest(name+description+start_date)
    else
      hash_event=Digest::MD5.hexdigest(name+description)
    end
    self.hash_resource = hash_event
  end
  
  
end