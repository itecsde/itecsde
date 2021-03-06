class ParticipantsController < ApplicationController
  
  def index
    @resource_type = "Participant"
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
      @search = Search.advanced_search_elements_by_type('Document', search_text,search_text_en_translation, advanced_parameters,per_page,params[:page])
      @num_results = @search[:total]
      @documents = @search[:results]
            
    
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
             
      @search = Search.search_elements_by_type('Document', search_text,search_text_en_translation, params[:article_id],per_page,params[:page])
      @documents = @search[:results]          
      @num_results = @search[:total]                   
    else
      #@search = Search.listing_elements_by_type('Document', search_languages, current_user, per_page,params[:page])
      #@documents = @search[:results]          
      #@num_results = @search[:total]    
      
   if params[:page] == nil
      if params[:repository] == nil or params[:repository] == ""
            array_docs = Document.where("classified_in_category_oercommons is not null and classified_in_category_oercommons not like ''").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
            
      elsif params[:repository] == "oercommons"
         if params[:section] == "all"
            array_docs = Document.where("classified_in_category_oercommons is not null and classified_in_category_oercommons not like ''").where("classified_in_category_oercommons not like ''").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         else
            array_docs = Document.where("classified_in_category_oercommons is not null and classified_in_category_oercommons not like ''").where("classified_in_category_oercommons like '%#{params[:section]}%'").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         end
         
      elsif params[:repository] == "merlot"
         if params[:section] == "all"
            array_docs = Document.where("classified_in_category_merlot is not null and classified_in_category_merlot not like ''").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = Document.where("classified_in_category_merlot is not null and classified_in_category_merlot not like ''").size
         else         
            array_docs = Document.where("classified_in_category_merlot is not null and classified_in_category_merlot not like ''").where("classified_in_category_merlot like '%#{params[:section]}%'").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         end
         
      elsif params[:repository] == "cnx"
         if params[:section] == "all" or params[:section] == "" or params[:section] == nil
            array_docs = Document.where("classified_in_category_cnx is not null and classified_in_category_cnx not like ''").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         else       
            array_docs = Document.where("classified_in_category_cnx is not null and classified_in_category_cnx not like ''").where("classified_in_category_cnx like '%#{params[:section]}%'").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         end   
         
      elsif params[:repository] == "wikipedia"
         if params[:section] == "all"
            array_docs = Document.where("classified_in_category_wikipedia is not null and classified_in_category_wikipedia not like ''").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         else         
            array_docs = Document.where("classified_in_category_wikipedia is not null and classified_in_category_wikipedia not like ''").where("classified_in_category_wikipedia like '%#{params[:section]}%'").shuffle
            @documents = Kaminari.paginate_array(array_docs).page(params[:page]).per(8)
            $documents = array_docs
            @num_results = array_docs.size
         end
      end   
   else
      @documents = Kaminari.paginate_array($documents).page(params[:page]).per(8)
      @num_results = $documents.size
   end      
   
   @participants = Participant.first
      
      #fin muestro todos de momento
=begin        
      @search = Document.search do |query|
      
          if current_user != nil && current_user.circumstances != []
            search_terms = current_user.circumstances.first.tag_list + ", " + current_user.circumstances.first.subject.name
            query.keywords search_terms, :fields => [:tags, :name] {minimum_match 1}
          end
       
          query.with(:translations, search_languages)  
          query.paginate :page => params[:page],:per_page => per_page 
      end
      @documents = @search.results 
      @num_results=@search.total
=end         
    end  
            
    @previous_search_params = params      
    #@subjects = Subject.all     
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @documents }
    end
  end
  
  
  def show
    @document = Document.find(params[:id])
    
    if current_user!=nil
      current_user.add_preferences_to_user_history(@document.taggable_tag_annotations)
    end
         
    #@subjects=Subject.all
    @related_elements=RelatedElement.new(@document)   
    @edition_mode=false
    @resource_type="Document"
            
    if notice == 'Document was successfully created.' || notice == 'Document was successfully updated.'
      @previous_action = 'saved'
    else
      @previous_action = 'list'
    end    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @document }
    end
  end
  
  
  def new
    if current_user !=nil 
      @document = Document.new
      @subjects=Subject.all
      @edition_mode=true
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @document }
      end
    else
      redirect_to documents_path
    end
  end
  
  def edit
    @document = Document.find(params[:id])
    if current_user !=nil && ((@document.owner == current_user) or (@document.owner_type=="Group" && @document.owner.users.exists?(current_user)))
      @subjects=Subject.all
      @edition_mode=true
    else
      redirect_to document_path(@document) 
    end
  end
  
  
  def create
    @document = Document.new(params[:document])
    if (params[:document][:owner_type]==nil)
      @document.owner_type="User"
      @document.owner=current_user
    end
    @document.creator = current_user
    manual_tags = params[:document][:tag_list].split(',')
    #@document.persist([], @document.description, manual_tags)
    
    respond_to do |format|
      if @document.save
        #@document.persist([], @document.description, manual_tags)
        format.html { redirect_to @document, notice: 'Document was successfully created.' }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: "new" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  def update
    name = params[:user_name]
    surname = params[:user_surname]
    sex = params[:user_sex]
    teacher = params[:teacher]
    educational_level = params[:teacher_level]
    subject = params[:subject]

    puts params[:url]
    @document = Document.find(params[:id])
    new_participant = Participant.new
    #new_participant.document_id = params[:id]
    new_participant.name = name
    new_participant.surname = surname
    new_participant.sex = sex
    new_participant.teacher = teacher
    new_participant.educational_level = educational_level
    new_participant.subject = subject
    new_participant.save
    puts new_participant.id
    

    respond_to do |format|
      if @document.update_attributes(params[:document])         
        format.html { redirect_to "/documents?user_id=" + new_participant.id .to_s , notice: 'Your evaluation was sent correctly.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end    
  end
  
  
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :ok }
    end
  end
  
  
  def popup_show_document
    @document = Document.find(params[:element_id])
    @subjects=Subject.all
    @edition_mode=false
    @resource_type = "Document"
    @popup = true

    respond_to do |format|
      format.js
    end
  end
  
  
end