class CoursesController < ApplicationController
  
  def index
    @resource_type = "Course"
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
      @search = Search.advanced_search_elements_by_type('Course', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
      @num_results = @search[:total]
      @courses = @search[:results] 
    
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
             
      @search = Search.search_elements_by_type('Course', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])
      @courses = @search[:results]          
      @num_results = @search[:total]
                       
    else
      @search = Search.listing_elements_by_type('Course', search_languages, current_user, per_page,params[:page])
      @courses = @search[:results]          
      @num_results = @search[:total] 
=begin
      @search = Course.search do |query|        
          if current_user != nil && current_user.circumstances != []
            search_terms = current_user.circumstances.first.tag_list + ", " + current_user.circumstances.first.subject.name
            query.keywords search_terms, :fields => [:tags, :name] {minimum_match 1}
          end
        
          query.with(:translations, search_languages)  
          query.paginate :page => params[:page],:per_page => per_page 
      end
      @courses = @search.results 
      @num_results=@search.total
=end      
    end  
        
     
    @previous_search_params=params      
    @subjects=Subject.all     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end
  
  
  def show
    @course = Course.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@course.taggable_tag_annotations)
    end
         
    @subjects=Subject.all
    @related_elements=RelatedElement.new(@course)   
    @edition_mode=false
    @resource_type="Course"
        
    if notice == 'Course was successfully created.' || notice == 'Course was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course }
    end
  end
  
  
  def new
    if current_user != nil
      @course = Course.new
      @subjects=Subject.all
      @edition_mode=true
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @course }
      end
    else
      redirect_to courses_path
    end
  end
  
  def edit
    @course = Course.find(params[:id])
    if current_user !=nil && ((@course.owner == current_user) or (@course.owner_type=="Group" && @course.owner.users.exists?(current_user)))
      @subjects=Subject.all
      @edition_mode=true
    else
      redirect_to course_path(@course)
    end
  end
  
  
  def create
    @course = Course.new(params[:course])
    if (params[:course][:owner_type]==nil)
      @course.owner_type="User"
      @course.owner=current_user
    end
    @course.creator = current_user
    manual_tags = params[:course][:tag_list].split(',')
    #@course.persist([], @course.description, manual_tags)
    
    respond_to do |format|
      if @course.save 
        #@course.persist([], @course.description, manual_tags)
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    @course = Course.find(params[:id])
    if (params[:course][:owner_type]==nil)
      @course.owner_type="User"
      @course.owner=current_user
    end
    @course.subjects.destroy_all
    name = params[:course][:name]
    description = params[:course][:description]
    manual_tags = params[:course][:tag_list].split(',')    
    @course.info_to_wikify = name + ". " + description      
    
    respond_to do |format|
      if @course.update_attributes(params[:course])
        @course.tags.destroy_all
        @course.extract_wikitopics(name, description, manual_tags)          
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :ok }
    end
  end
  
  
  def popup_show_course
    @course = Course.find(params[:element_id])
    @subjects=Subject.all
    @edition_mode=false
    @resource_type = "Course"   
    @popup = true 

    respond_to do |format|
      format.js
    end
  end
  
  
end