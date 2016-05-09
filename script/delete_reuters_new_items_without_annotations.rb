ids = Array.new

ReutersNewItem.all.each do |item|
   if item.taggable_tag_annotations.size == 0
      puts item.id
      ids << item.id
   else
      puts item.id.to_s + " has annotations"
   end
   puts "ids"
   puts ids
end
