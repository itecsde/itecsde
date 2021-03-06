class EventsController < ApplicationController

  
  def index
    @resource_type = "Event"
    if I18n.locale.to_s == "gl"
      search_languages=["gl","es"]
    else 
      search_languages=[I18n.locale.to_s]
    end
    per_page = 32

    if (params[:advanced_search]=="1") 
      if params[:search] != nil && params[:search].size > 0
         search_text = params[:search]
         if search_text.index("#") != 0
            @disambiguation = Search.disambiguation(search_text)
         else
         #Esto es para tener el termino traducido al ingles para hacer las busquedas con el tag en ingles
            if I18n.locale.to_s != "en" && search_text.index("@") != nil
               clean_search_text = search_text[0,search_text.index("@")]
               search_text_en_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(clean_search_text),I18n.locale.to_s,"en")
            #Esto es para traducir el termino al idioma de la vista para ver la info de desambiguacion del termino en ese idioma
            elsif I18n.locale.to_s != "en" && search_text.index("@") == nil
               search_text_locale_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(search_text),"en",I18n.locale.to_s)
            end
            search = Search.new
            if I18n.locale.to_s != "en" && search_text_locale_translation != nil
               @disambigued_term_info = search.disambigued_term_info(Util.to_hashtag_with_language(search_text_locale_translation))
            else
               @disambigued_term_info = search.disambigued_term_info(search_text)
            end
         end         
      else
         search_text = ""
      end
      advanced_parameters = Hash[:start_date => params[:start_date], :end_date => params[:end_date], :radius => params[:radius], :latitude => params[:event_latitude], :longitude => params[:event_longitude]]
      @search = Search.advanced_search_elements_by_type('Event', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
      @num_results = @search[:total]
      @events = @search[:results]
      
      
    elsif (params[:search] != nil && params[:search].size > 0)
      search_text = params[:search]
      if search_text.index("#") != 0
        @disambiguation = Search.disambiguation(search_text)
      else        
        #Esto es para tener el termino traducido al ingles para hacer las busquedas con el tag en ingles
        if I18n.locale.to_s != "en" && search_text.index("@") != nil         
          clean_search_text = search_text[0,search_text.index("@")]
          search_text_en_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(clean_search_text),I18n.locale.to_s,"en")
        #Esto es para traducir el termino al idioma de la vista para ver la info de desambiguacion del termino en ese idioma          
        elsif I18n.locale.to_s != "en" && search_text.index("@") == nil
          search_text_locale_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(search_text),"en",I18n.locale.to_s)
        end
        search = Search.new
        if I18n.locale.to_s != "en" && search_text_locale_translation != nil
          @disambigued_term_info = search.disambigued_term_info(Util.to_hashtag_with_language(search_text_locale_translation))
        else
          @disambigued_term_info = search.disambigued_term_info(search_text)  
        end
      end 
             
      @search = Search.search_elements_by_type('Event', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])
      @events = @search[:results]          
      @num_results = @search[:total]
                 
    else
      @search = Search.listing_elements_by_type('Event', search_languages, current_user, per_page,params[:page])
      @events = @search[:results]          
      @num_results = @search[:total]      
=begin      
      @search = Event.search do |query|
        
#        if current_user !=nil && current_user.circumstances != []
#          search_terms = current_user.circumstances.first.tag_list_quoted + ", " + current_user.circumstances.first.subject.name
#          query.fulltext search_terms, :fields => [:tags, :subjects, :name] {minimum_match 1}
#          query.fulltext search_terms do
#            phrase_fields :tags => 5.0
#            boost_fields :tags => 5.0
#            boost_fields :description => 1.0
#            minimum_match 1
#          end        
#         #query.with(:geohash_location).near(current_user.circumstances.first.latitude, current_user.circumstances.first.longitude, :precision => 2, :boost => 5)
#          if current_user.circumstances.first.latitude!=nil
#            query.with(:location).in_radius(current_user.circumstances.first.latitude, current_user.circumstances.first.longitude, 2000)       
#            query.order_by_geodist(:location, current_user.circumstances.first.latitude, current_user.circumstances.first.longitude)
#          end 
#        end        
        if current_user !=nil && current_user.circumstances != [] && current_user.circumstances.first.latitude!=nil
           #query.with(:location).in_radius(current_user.circumstances.first.latitude, current_user.circumstances.first.longitude, 2000)       
           query.order_by_geodist(:location, current_user.circumstances.first.latitude, current_user.circumstances.first.longitude)         
        end
        query.with(:translations, search_languages)         
        query.paginate :page => params[:page],:per_page => per_page        
      end             
      @events = @search.results 
      @num_results=@search.total
=end         
    end
    
    @previous_search_params=params
    @subjects=Subject.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @applications }
    end
  end
  
  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@event.taggable_tag_annotations)
    end
     
    @subjects = Subject.all
    @education_levels = EducationLevel.all
    @languages = ContextualLanguage.all
    @related_elements=RelatedElement.new(@event)
    @resource_type="Event"
    
    @edition_mode=false

    if notice == 'Event was successfully created.' || notice == 'Event was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
    
  end
  
  # GET /events/new
  # GET /events/new.json
  def new
    if current_user !=nil 
      @event = Event.new
      @subjects = Subject.all
      @education_levels = EducationLevel.all
      @languages = ContextualLanguage.all
      @edition_mode=true
      
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @event }
      end
    else
      redirect_to events_path
    end
  end
  
    # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    if current_user !=nil && ((@event.owner == current_user) or (@event.owner_type=="Group" && @event.owner.users.exists?(current_user)))
      @subjects = Subject.all
      @education_levels = EducationLevel.all
      @languages = ContextualLanguage.all
      @edition_mode=true
    else 
      redirect_to event_path(@event)
    end
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    if (params[:event][:owner_type]==nil)
      @event.owner_type="User"
      @event.owner=current_user
    end
    if @event.start_date==""
        @event.start_date=nil
    end
    if @event.end_date==""
        @event.end_date=nil
    end
    @event.creator = current_user
    manual_tags = params[:event][:tag_list].split(',')
    #@event.persist([], @event.description, manual_tags)

    respond_to do |format|
      if @event.save
        #@event.persist([], @event.description, manual_tags)
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      elsif @event.id != nil
        puts "SALGO POR RESCATE: Algo fallo en persist pero guardo el elemento" 
        format.html { redirect_to @event }
        format.json { render json: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])
     if (params[:event][:owner_type]==nil)
      @event.owner_type="User"
      @event.owner=current_user
    end
    if @event.start_date==""
        @event.start_date=nil
    end
    if @event.end_date==""
        @event.end_date=nil
    end
    @event.taggable_tag_annotations.delete_all
    @event.subjects.destroy_all
    name = params[:event][:name]
    description = params[:event][:description]
    manual_tags = params[:event][:tag_list].split(',')
    @event.info_to_wikify = name + ". " + description    
     
    respond_to do |format|
      if @event.update_attributes(params[:event])
        @event.tags.destroy_all
        @event.extract_wikitopics(name, description, manual_tags)     
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
  
  def popup_show_event
    @event = Event.find(params[:element_id])
     
    @subjects = Subject.all
    @education_levels = EducationLevel.all
    @languages = ContextualLanguage.all
    @edition_mode=false
    @resource_type="Event" 
    @popup = true   
    
    respond_to do |format|
      format.js
    end
  end
  
  


end