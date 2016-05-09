class RaeWord < ActiveRecord::Base
   
   searchable do
      integer :id
   end

   attr_accessible :element_image, :name, :description, :url, :link, :book_subject_annotations_attributes, :owner_type, :owner_id, :scraped_from, :creator_id, :tag_list, :author, :museum
   has_attached_file :element_image, :styles => { :original => "300x300>", :medium => "200x200>", :thumb => "30x30>" }, :default_url => "none"


end