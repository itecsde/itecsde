class ReutersNewItem < ActiveRecord::Base
   include Taggable
   include Ownable
   include Wikipediable
   include Globalizable
   include Categorizable
   include Scrapeable

   extend FriendlyId
   friendly_id :name
   
   searchable do
      integer :id
      text :name
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

      time :updated_at
   end

   # An reuters_new_item may have many comments
   has_many :comments, :as => :commentable, :dependent => :destroy

   # An reuters_new_item is categorised into many subjects

   # An reuters_new_item is bookmarkable
   has_many :bookmark_user_element_annotations, :as => :element, :dependent => :destroy
   has_many :bookmarked_by, :through => :bookmark_user_element_annotations, :source =>:user

   # And an reuters_new_item may include a representative picture
   attr_accessible :element_image, :name, :description, :url, :link, :reuters_new_item_subject_annotations_attributes, :owner_type, :owner_id, :scraped_from, :creator_id, :tag_list
   has_attached_file :element_image, :styles => { :original => "300x300>", :medium => "200x200>", :thumb => "30x30>" }, :default_url => "none"
 

   def persist_backup()
      #puts self.file_id
=begin      
      if ReutersNewItem.where(:file_id => self.file_id).size != 0
         item = ReutersNewItem.where(:file_id => self.file_id)[0]
         topics_anteriores = ReutersNewItem.where(:file_id => self.file_id)[0].topics
         topic_actual = self.topics
         if !topics_anteriores.include? topic_actual
            item.topics = topics_anteriores + "," + topic_actual
            #ReutersNewItem.where(:cgisplit => self.cgisplit, :file_id => self.file_id).destroy_all
            #self.create_semantic_annotations(manual_tags)      
            item.save
            item.reload
            Sunspot.index self
            Sunspot.commit
         else
            puts "This article already exists."
         end
      else
         #self.create_semantic_annotations(manual_tags)
         self.save
         self.reload
         Sunspot.index self
         Sunspot.commit
      end
=end      
         #if ReutersNewItem.where(:file_id => self.file_id).size == 0
         if 1
            #self.create_semantic_annotations(manual_tags)
            self.save
            self.reload
            Sunspot.index self
            Sunspot.commit
         else
            puts "Article already exists"
         end
   end
   
   def persist()
      #puts self.file_id    
      if ReutersNewItem.where(:file_id => self.file_id).where(:people => self.people).size != 0
         item = ReutersNewItem.where(:file_id => self.file_id).where(:people => self.people)[0]
         previous_topics = ReutersNewItem.where(:file_id => self.file_id).where(:people => self.people)[0].topics
         current_topic = self.topics
         if !previous_topics.include? current_topic
            puts "Topics updated!"
            item.topics = previous_topics + "," + current_topic  
            item.save
            item.reload
            Sunspot.index self
            Sunspot.commit
         else
            puts "This article already exists in the database."
         end
      else
         puts "New article saved!"
         self.save
         self.reload
         Sunspot.index self
         Sunspot.commit
      end
   end



   def tag_list=(new_value)
      tag_names = new_value.split(/,\s+/)
      self.tags = tag_names.map { |name| Tag.where('name = ?', name).first or Tag.create(:name => name.strip) }
   end

end