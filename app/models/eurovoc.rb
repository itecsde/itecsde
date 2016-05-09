class Eurovoc < ActiveRecord::Base
   include Taggable
   include Ownable
   include Wikipediable
   include Globalizable
   include Aggregable
   include Categorizable
   include Scrapeable

   acts_as_nested_set
   #has_ancestry

   searchable do
      integer :id
   end

   def obtain_eurovoc_id_correspondence(key)
      begin
         if get_node("NT_5_" + key) != nil
            return "NT_5_" + key
         elsif get_node("NT_4_" + key) != nil
            return "NT_4_" + key
         elsif get_node("NT_3_" + key) != nil
            return "NT_3_" + key
         elsif get_node("NT_2_" + key) != nil
            return "NT_2_" + key
         elsif get_node("NT_1_" + key) != nil
            return "NT_1_" + key
         elsif get_node("TT_" + key) != nil
            return "TT_" + key
         elsif get_node("MT_" + key) != nil
            return "MT_" + key
         elsif get_node("DM_" + key) != nil
            return "DM_" + key
         end                                                            
      rescue Exception => e
         puts "Exception obtain_eurovoc_id_correspondence"
         puts e.message
         puts e.backtrace.inspect
      end
   end


   def get_node(key)
      begin
         return Eurovoc.where(:eurovoc_id => key)[0]
      rescue Exception => e 
         puts "Exception get_node"
         puts e.message
         puts e.backtrace.inspect
      end
   end

   def add_root_helper_node(name,type_node,parent_id, key)
      begin
         new_node = Eurovoc.create!(:name => name) do |node|
         node.eurovoc_id = key
         node.type_node = type_node
         node.parent_id = nil
         end
         
      rescue Exception => e
         puts "Exception add_node"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def add_node(name,type_node,parent_id, key)
      begin
         new_node = Eurovoc.create!(:name => name) do |node|
         node.eurovoc_id = key
         node.type_node = type_node
         end
         parent_node = get_node(parent_id)
         puts parent_node
         new_node.move_to_child_of(parent_node)
         
      rescue Exception => e
         puts "Exception add_node"
         puts e.message
         puts e.backtrace.inspect
      end
   end
   
   def get_first_level(key)
      begin
         node = get_node(key)
         puts "node"
         puts node.eurovoc_id
         if (node.parent).eurovoc_id == "RH_0" and (node.parent.depth == 0)
            return node.name
         else
            get_first_level(node.parent.eurovoc_id)
         end
      rescue Exception => e
         puts "Exception get_first_level"
         puts e.message
         puts e.backtrace.inspect
      end
   end

   attr_accessible :element_image, :name, :description, :url, :link, :book_subject_annotations_attributes, :owner_type, :owner_id, :scraped_from, :creator_id, :tag_list, :author, :museum
   has_attached_file :element_image, :styles => { :original => "300x300>", :medium => "200x200>", :thumb => "30x30>" }, :default_url => "none"


end