class HomeController < ApplicationController
  def index
     
     if current_user == nil
       redirect_to root_path
     end
    #@activities = Activity.find(:all,:conditions => { :template => nil, :status => 'class' }).last(5).reverse
    #@sequences= ActivitySequence.find(:all,:conditions => { :status => 'class' }).last(5).reverse
    #@guides= Guide.last(5).reverse
=begin    
     if ENV['RAILS_ENV'] == "development" 
      if Biography.first != nil         
        counter = Biography.where("element_image_file_size != ?", "").count
        if counter>0  
          @biography=Biography.where("element_image_file_size != ?", "").offset(rand(counter)).first
        else
          @biography=Biography.first(:offset => rand(Biography.count))
        end   
      end
  
      if Event.first != nil    
        counter = Event.where("element_image_file_size != ?", "").count
        if counter>0
          @event=Event.where("element_image_file_size != ?", "").offset(rand(counter)).first
        else
          @event=Event.first(:offset => rand(Event.count)) 
        end
      end
      
      if Application.first != nil     
        counter = Application.where("element_image_file_size != ?", "").count
        if counter>0
          @application=Application.where("element_image_file_size != ?", "").offset(rand(counter)).first
        else
          @application=Application.first(:offset => rand(Application.count)) 
        end
      end
      
      if Lecture.first != nil     
        counter = Lecture.where("element_image_file_size != ?", "").count
        if counter>0
          @lecture=Lecture.where("element_image_file_size != ?", "").offset(rand(counter)).first
        else
          @lecture=Lecture.first(:offset => rand(Lecture.count)) 
        end
      end
    
    
    elsif ENV['RAILS_ENV'] == "production"
       counter = 150
       counter2 = 160      
       if Biography.first != nil         
        begin  
          @biography = Biography.where("element_image_file_size != ?", "").limit(counter2).offset(rand(counter)).first
        rescue
          @biography = nil
        end
        if @biography == nil
          @biography=Biography.first #(:offset => rand(Biography.count))
        end   
      end
  
      if Event.first != nil            
        begin
          @event = Event.where("element_image_file_size != ?", "").limit(counter2).offset(rand(counter)).first
        rescue
          @event = nil
        end
        if @event == nil
          @event=Event.first #(:offset => rand(Event.count)) 
        end
      end
      
      if Application.first != nil     
        begin
          @application = Application.where("element_image_file_size != ?", "").limit(counter2).offset(rand(counter)).first
        rescue
          @application = nil
        end
        if @application == nil
          @application=Application.first #(:offset => rand(Application.count)) 
        end
      end
      
      if Lecture.first != nil            
        begin
          @lecture=Lecture.where("element_image_file_size != ?", "").limit(counter2).offset(rand(counter)).first
        rescue
          @lecture = nil
        end
        if @lecture == nil
          @lecture=Lecture.first #(:offset => rand(Lecture.count)) 
        end
      end
      
    end  
=end
    
    if current_user != nil 
      annotations = current_user.user_tag_annotations.order("weight DESC").limit(30)           
      ################ ESTO comentado es con el suggest ppero lo hemos comentado porque tardaba mucho a veces ###############################
=begin      
      array_wikitopics = annotations.map {|annotation| annotation.wikipedia_article_id} 
      # Util.to_hashtag(tag_annotation.tag.name) if tag_annotation.tag.name != nil && tag_annotation.tag.name != "" }
      
      if array_wikitopics.size > 0
        wikitopic = Array.new
        wikitopic << array_wikitopics[rand(array_wikitopics.size-1)]
        w = Wikipediator.new
        puts wikitopic
        hash_tags = w.suggest_articles(wikitopic)
        if hash_tags != nil && hash_tags.size > 0
          tags = hash_tags.map {|hash_tag| Util.to_hashtag(hash_tag[:title])}.join(" ")
          puts tags
        else
          #Si por alguna razon el suggest no devuleve bien las cosas tiramos de los tags
          tags = annotations.map {|tag_annotation| Util.to_hashtag(tag_annotation.tag.name) if tag_annotation.tag.name != nil && tag_annotation.tag.name != ""}.join(" ")
        end
      else
        tags = ""
      end     
=end   
      if annotations != nil && annotations.size > 0
         if annotations.size > 8
            number_tags_to_recommend = annotations.size / 4
         else
            number_tags_to_recommend = annotations.size
         end
         annotations_random = annotations.sample(number_tags_to_recommend)        
         tags = annotations_random.map {|tag_annotation| Util.to_hashtag(tag_annotation.tag.name) if tag_annotation.tag.name != nil && tag_annotation.tag.name != ""}.join(" ")
      else 
         tags = Util.to_hashtag("Learning")
      end
                      
      #tags = annotations.map { |tag_annotation| '"' + tag_annotation.tag.name + '"' if tag_annotation.tag.name != nil && tag_annotation.tag.name != ""}.join(", ")
      recommender = Recommender.new
      @recommended_reports = recommender.get_recommended_resources("Report",tags)
      @recommended_posts = recommender.get_recommended_resources("Post",tags)
      @recommended_events = recommender.get_recommended_resources("Event",tags)
      @recommended_sites = recommender.get_recommended_resources("Site",tags)
    end
            
    
  end

end