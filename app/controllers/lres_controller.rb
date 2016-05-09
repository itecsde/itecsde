class LresController < ApplicationController
  
  def index
    @resource_type = "Lre"
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
      @search = Search.advanced_search_elements_by_type('Lre', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
      @num_results = @search[:total]
      @lres = @search[:results]     
    
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
             
      @search = Search.search_elements_by_type('Lre', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])
      @lres = @search[:results]          
      @num_results = @search[:total]                   
    else
      @search = Search.listing_elements_by_type('Lre', search_languages, current_user, per_page,params[:page])
      @lres = @search[:results]          
      @num_results = @search[:total]
=begin        
      @search = Lre.search do |query|       
          if current_user != nil && current_user.circumstances != []
            search_terms = current_user.circumstances.first.tag_list + ", " + current_user.circumstances.first.subject.name
            query.keywords search_terms, :fields => [:tags, :name] {minimum_match 1}
          end         
          query.with(:translations, search_languages)  
          query.paginate :page => params[:page],:per_page => per_page 
      end
      @lres = @search.results 
      @num_results=@search.total
=end      
    end  
            
    @previous_search_params=params      
    @subjects=Subject.all     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lres }
    end
  end
  
  
  def show
    @lre = Lre.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@lre.taggable_tag_annotations)
    end
         
    @subjects=Subject.all
    @related_elements=RelatedElement.new(@lre)   
    @edition_mode=false
    @resource_type="Lre"
            
    if notice == 'Lre was successfully created.' || notice == 'Lre was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lre }
    end
  end
  
  
  def new
    if current_user !=nil 
      @lre = Lre.new
      @subjects=Subject.all
      @edition_mode=true
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @lre }
      end
    else
      redirect_to lres_path
    end
  end
  
  def edit
    @lre = Lre.find(params[:id])
    if current_user !=nil && ((@lre.owner == current_user) or (@lre.owner_type=="Group" && @lre.owner.users.exists?(current_user)))
      @subjects=Subject.all
      @edition_mode=true
    else
      redirect_to lre_path(@lre) 
    end
  end
  
  
  def create
    @lre = Lre.new(params[:lre])
    if (params[:lre][:owner_type]==nil)
      @lre.owner_type="User"
      @lre.owner=current_user
    end
    @lre.creator = current_user
    manual_tags = params[:lre][:tag_list].split(',')
    #@lre.persist([], @lre.description, manual_tags)

    respond_to do |format|
      if @lre.save
        #@lre.persist([], @lre.description, manual_tags)
        format.html { redirect_to @lre, notice: 'Lre was successfully created.' }
        format.json { render json: @lre, status: :created, location: @lre }
      else
        format.html { render action: "new" }
        format.json { render json: @lre.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    @lre = Lre.find(params[:id])
    if (params[:lre][:owner_type]==nil)
      @lre.owner_type="User"
      @lre.owner=current_user
    end
    @lre.subjects.destroy_all
    name = params[:lre][:name]
    description = params[:lre][:description]
    manual_tags = params[:lre][:tag_list].split(',')  
    @lre.info_to_wikify = name + ". " + description        
    
    respond_to do |format|
      if @lre.update_attributes(params[:lre])
        @lre.tags.destroy_all
        @lre.extract_wikitopics(name, description, manual_tags)                
        format.html { redirect_to @lre, notice: 'Lre was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @lre.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  
  def destroy
    @lre = Lre.find(params[:id])
    @lre.destroy

    respond_to do |format|
      format.html { redirect_to lres_url }
      format.json { head :ok }
    end
  end
  
  
  def popup_show_lre
    @lre = Lre.find(params[:element_id])
    @subjects=Subject.all
    @edition_mode=false
    @resource_type="Lre"
    @popup = true


    respond_to do |format|
      format.js
    end
  end
  
  
end