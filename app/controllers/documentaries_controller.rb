class DocumentariesController < ApplicationController
  
  def index
    @resource_type = "Documentary"
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
      advanced_parameters = Hash[]
      @search = Search.advanced_search_elements_by_type('Documentary', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
      @num_results = @search[:total]
      @documentaries = @search[:results]
      
      
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
             
      @search = Search.search_elements_by_type('Documentary', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])
      @documentaries = @search[:results]          
      @num_results = @search[:total]
         
    else
      @search = Search.listing_elements_by_type('Documentary', search_languages, current_user, per_page,params[:page])
      @documentaries = @search[:results]          
      @num_results = @search[:total]

=begin      
      @search = Documentary.search do |query|
        
          if current_user != nil && current_user.circumstances != []
            search_terms = current_user.circumstances.first.tag_list_quoted + ", " + current_user.circumstances.first.subject.name
            query.keywords search_terms, :fields => [:tags, :name] {minimum_match 1}
          end
        
          query.with(:translations, search_languages)  
          query.paginate :page => params[:page],:per_page => per_page 
      end
      @documentaries = @search.results 
      @num_results=@search.total
=end        
    end    
     
    @previous_search_params=params      
    @subjects=Subject.all     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @documentaries }
    end
  end
  
  
  def show
    @documentary = Documentary.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@documentary.taggable_tag_annotations)
    end
         
    @subjects=Subject.all   
    @related_elements=RelatedElement.new(@documentary)
    @edition_mode=false
    @resource_type="Documentary"
        
    if notice == 'Documentary was successfully created.' || notice == 'Documentary was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @documentary }
    end
  end
  
  
  def new
    if current_user != nil
      @documentary = Documentary.new
      @subjects=Subject.all
      @edition_mode=true
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @documentary }
      end
    else
      redirect_to documentaries_path
    end
  end
  
  def edit
    @documentary = Documentary.find(params[:id])
    if current_user !=nil && ((@documentary.owner == current_user) or (@documentary.owner_type=="Group" && @documentary.owner.users.exists?(current_user)))
      @subjects=Subject.all
      @edition_mode=true
    else
      redirect_to documentary_path(@documentary)
    end
  end
  
  
  def create
    @documentary = Documentary.new(params[:documentary])
    if (params[:documentary][:owner_type]==nil)
      @documentary.owner_type="User"
      @documentary.owner=current_user
    end
    @documentary.creator = current_user
    manual_tags = params[:documentary][:tag_list].split(',')
    #@documentary.persist([], @documentary.description, manual_tags)


    respond_to do |format|
      if @documentary.save
        #@documentary.persist([], @documentary.description, manual_tags)
        format.html { redirect_to @documentary, notice: 'Documentary was successfully created.' }
        format.json { render json: @documentary, status: :created, location: @documentary }
      else
        format.html { render action: "new" }
        format.json { render json: @documentary.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    @documentary = Documentary.find(params[:id])
    if (params[:documentary][:owner_type]==nil)
      @documentary.owner_type="User"
      @documentary.owner=current_user
    end
    @documentary.subjects.destroy_all
    name = params[:documentary][:name]
    description = params[:documentary][:description]
    manual_tags = params[:documentary][:tag_list].split(',')
    @documentary.info_to_wikify = name + ". " + description      
    
    respond_to do |format|
      if @documentary.update_attributes(params[:documentary])
        @documentary.tags.destroy_all
        @documentary.extract_wikitopics(name, description, manual_tags)        
        format.html { redirect_to @documentary, notice: 'Documentary was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @documentary.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  
  def destroy
    @documentary = Documentary.find(params[:id])
    @documentary.destroy

    respond_to do |format|
      format.html { redirect_to documentaries_url }
      format.json { head :ok }
    end
  end
  
  
  def popup_show_documentary
    @documentary = Documentary.find(params[:element_id])
    @subjects=Subject.all
    @edition_mode=false
    @resource_type = "Documentary"    
    @popup = true

    respond_to do |format|
      format.js
    end
  end
  
  
end