class Activity < ActiveRecord::Base
   include Taggable
   include Ownable
   include Aggregable
   include Globalizable

   Globalize.fallbacks = {:en => [:en, :fi, :pt, :es], :fi => [:fi, :en, :pt, :es]}

   translates :name, :description

   searchable do
      I18n.available_locales.each do |locale|
         text "name_" + locale.to_s do
            read_attribute(:name, :locale => locale.to_s)
         end
         text "description_" + locale.to_s do
            read_attribute(:description, :locale => locale.to_s)
         end
      end

      string :status
      integer :owner_id
      time :updated_at
      string :translations, :multiple => true do
         translations.map{|translation| translation.locale}
      end 
   end

   belongs_to :activity_sequence
   acts_as_list :scope => :activity_sequence

   has_one :activity_interaction_annotation
   has_one :interaction, :through => :activity_interaction_annotation

   has_many :boxes, :dependent => :destroy, :as => :document

   has_many :concrete_requirements, :dependent => :destroy
   has_many :abstract_requirements, :dependent => :destroy
   has_many :contributor_requirements, :dependent => :destroy
   has_many :event_requirements, :dependent => :destroy
   has_many :person_concrete_requirements, :dependent => :destroy
   has_many :event_concrete_requirements, :dependent => :destroy
   has_many :content_concrete_requirements, :dependent => :destroy

   accepts_nested_attributes_for :boxes, :allow_destroy => :true
   accepts_nested_attributes_for :concrete_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :abstract_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :contributor_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :event_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :person_concrete_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :event_concrete_requirements, :allow_destroy => :true
   accepts_nested_attributes_for :content_concrete_requirements, :allow_destroy => :true

   has_many :comments, :as => :commentable, :dependent => :destroy

   attr_accessible :element_image, :name, :description, :status, :boxes_attributes, :concrete_requirements_attributes, :abstract_requirements_attributes,
                  :contributor_requirements_attributes, :event_requirements_attributes, :person_concrete_requirements_attributes, :event_concrete_requirements_attributes, :content_concrete_requirements_attributes, :referenced_activity_id

   has_attached_file :element_image, :styles => { :original => "300x300>", :medium => "200x200>", :thumb => "30x30>" }, :default_url => "none"

   def clone_with_associations
      new_activity = self.dup
      new_activity.element_image = self.element_image

      self.concrete_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.concrete_requirements << new_requirement
      end

      self.abstract_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.abstract_requirements << new_requirement
      end

      self.contributor_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.contributor_requirements << new_requirement
      end

      self.event_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.event_requirements << new_requirement
      end

      self.person_concrete_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.person_concrete_requirements << new_requirement
      end

      self.event_concrete_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.event_concrete_requirements << new_requirement
      end

      self.content_concrete_requirements.each do |requirement|
         new_requirement = requirement.clone_with_associations
         new_activity.content_concrete_requirements << new_requirement
      end

      self.translations.each do |translation|
         new_translation = translation.dup
         new_activity.translations << new_translation
      end

      self.boxes.each do |box|
         new_box = box.clone_with_associations
         new_activity.boxes << new_box
      end
      new_activity.save
      new_activity
   end

   def persist
      self.save
      self.reload
      Sunspot.index self
      Sunspot.commit
   end
   
   def check_resource_storage_state(name)
      puts "name"
      puts name
      puts "end name"
      resource = Activity.where(:name => name)
      if resource.size > 0
         result = "update"
      else
         result = "insert"
      end
   end #check_resource_storage_state


   def is_equal_to(activity)
      if (activity.trace_id == self.trace_id) && (activity.trace_version == self.trace_version)
      return true
      else
      return false
      end
   end

end
