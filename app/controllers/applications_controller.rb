class ApplicationsController < ApplicationController
  def index
    @resource_type = "Application"
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
         advanced_parameters = Hash[:functionality => params[:functionality]]
         @search = Search.advanced_search_elements_by_type('Application', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
         @num_results = @search[:total]
         @applications = @search[:results]
         
      
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
             
      @search = Search.search_elements_by_type('Application', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])          
      @num_results = @search[:total]          
      @applications = @search[:results]
      
    else
      @search = Search.listing_elements_by_type('Application', search_languages, current_user, per_page,params[:page])
      @applications = @search[:results]          
      @num_results = @search[:total]
        
=begin      
      @search = Application.search do       
        if current_user != nil && current_user.circumstances != []
          search_form = current_user.circumstances.first.tag_list_quoted+", "+current_user.circumstances.first.subject.name
          with :operating_systems, [current_user.circumstances.first.operating_system_id, 6]
          if current_user.circumstances.first.has_internet == false
            without :operating_systems, 6
          end
          keywords search_form, :fields => [:tags] {minimum_match 1}
        end
        
        with(:translations, search_languages)
        order_by :updated_at, :desc                
        paginate :page => params[:page], :per_page => per_page
      end
      @applications = @search.results 
      @num_results=@search.total   
=end      
    end  
        
    @previous_search_params=params
    @funtionalities=Functionality.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @applications }
    end
  end
    
  # GET /application/1
  # GET /applications/1.json
  def show
    @application = Application.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@application.taggable_tag_annotations)
    end
    @related_elements = RelatedElement.new(@application)
    @functionalities=Functionality.all
    @operating_systems=OperatingSystem.all
    @edition_mode=false
    @resource_type="Application"

    if notice == 'Application was successfully created.' || notice == 'Application was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @application }
    end
    
  end
  
  # GET /applications/new
  # GET /applications/new.json
  def new
    if current_user != nil 
      @application = Application.new
      @functionalities = Functionality.all
      @operating_systems=OperatingSystem.all
      @edition_mode=true

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @application }
      end
    else
      redirect_to applications_path
    end
  end
  
  # GET /applications/1/edit
  def edit    
      @application = Application.find(params[:id])            
      if current_user !=nil && ((@application.owner == current_user) or (@application.owner_type=="Group" && @application.owner.users.exists?(current_user)))
        @functionalities=Functionality.all
        @operating_systems=OperatingSystem.all
        @edition_mode=true
      else 
        redirect_to application_path(@application)
      end
    
  end

  # POST /applications
  # POST /applications.json
  def create
    @application = Application.new(params[:application])
    if (params[:application][:owner_type]==nil)
      @application.owner_type="User"
      @application.owner=current_user
    end
    @application.creator = current_user
    manual_tags = params[:application][:tag_list].split(',')    
    operating_systems = []
    #@application.persist([], @application.description, manual_tags,operating_systems,nil,nil,"")

    respond_to do |format|
      if @application.save
         #@application.persist([], @application.description, manual_tags,operating_systems,nil,nil)
        format.html { redirect_to @application, notice: 'Application was successfully created.' }
        format.json { render json: @application, status: :created, location: @application }
      else
        format.html { render action: "new" }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /applications/1
  # PUT /applications/1.json
  def update
    @application = Application.find(params[:id])
    if (params[:application][:owner_type]==nil)
      @application.owner_type="User"
      @application.owner=current_user
    end
    @application.functionalities.destroy_all
    @application.operating_systems.destroy_all
    name = params[:application][:name]
    description = params[:application][:description]
    manual_tags = params[:application][:tag_list].split(',')    
    
    respond_to do |format|
      if @application.update_attributes(params[:application])
        @application.tags.destroy_all
        @application.extract_wikitopics(name, description, manual_tags)        
        format.html { redirect_to @application, notice: 'Application was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1
  # DELETE /applications/1.json
  def destroy
    @application = Application.find(params[:id])
    @application.destroy

    respond_to do |format|
      format.html { redirect_to applications_url }
      format.json { head :ok }
    end
  end
  
  def popup_show_application
    @application = Application.find(params[:element_id])
     
    @functionalities=Functionality.all
    @edition_mode=false
    @resource_type = "Application"
    @popup = true

    
    respond_to do |format|
      format.js
    end
  end
end