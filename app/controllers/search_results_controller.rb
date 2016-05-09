class SearchResultsController < ApplicationController
  
  def index
    @search_text = params[:search]    
    @article_id = params[:article_id]   
    @array_resources_types = [{"name"=>"Site","elements"=>"@sites","path"=>"sites_path","plural"=>"sites"},{"name"=>"Artwork","elements"=>"@artworks","path"=>"artworks_path","plural"=>"artworks"}, {"name"=>"Event","elements"=>"@events","path"=>"events_path","plural"=>"events"},{"name"=>"Biography","elements"=>"@biographies","path"=>"biographies_path","plural"=>"biographies"},{"name"=>"Lecture","elements"=>"@lectures","path"=>"lectures_path","plural"=>"lectures"},{"name"=>"Documentary","elements"=>"@documentaries","path"=>"documentaries_path","plural"=>"documentaries"},{"name"=>"Course","elements"=>"@courses","path"=>"courses_path","plural"=>"courses"},{"name"=>"Article","elements"=>"@articles","path"=>"articles_path","plural"=>"articles"},{"name"=>"Post","elements"=>"@posts","path"=>"posts_path","plural"=>"posts"},{"name"=>"Slideshow","elements"=>"@slideshows","path"=>"slideshows_path","plural"=>"slideshows"},{"name"=>"Report","elements"=>"@reports","path"=>"reports_path","plural"=>"reports"},{"name"=>"Book","elements"=>"@books","path"=>"books_path","plural"=>"books"},{"name"=>"Application","elements"=>"@applications","path"=>"applications_path","plural"=>"applications"},{"name"=>"Lre","elements"=>"@lres","path"=>"lres_path","plural"=>"lres"},{"name"=>"Klascement","elements"=>"@klascements","path"=>"klascements_path","plural"=>"klascements"},{"name"=>"Widget","elements"=>"@widgets","path"=>"widgets_path","plural"=>"widgets"}]
          
    
    if @search_text != nil      
      if @search_text.index("#") != 0
        @disambiguation = Search.disambiguation(@search_text)
      elsif @search_text.index("#") == 0 
        if I18n.locale.to_s != "en" && @search_text.index("@") != nil
          #Esto es para tener el termino traducido al ingles para hacer las busquedas con el tag en ingles 
          clean_search_text = @search_text[0,@search_text.index("@")]
          @search_text_en_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(clean_search_text),I18n.locale.to_s,"en")          
        elsif I18n.locale.to_s != "en" && @search_text.index("@") == nil
          #Esto es para traducir el termino al idioma de la vista para ver la info de desambiguacion del termino en ese idioma
          @search_text_locale_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(@search_text),"en",I18n.locale.to_s)
        end
      end
            
      @sites = Search.search_elements_by_type('Site', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @events = Search.search_elements_by_type('Event', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @lectures = Search.search_elements_by_type('Lecture', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @documentaries = Search.search_elements_by_type('Documentary', @search_text,@search_text_en_translation,@article_id,4)[:results]
      #@people = Search.search_elements_by_type('Person', @search_text,@article_id,4)[:results]
      @applications = Search.search_elements_by_type('Application', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @courses = Search.search_elements_by_type('Course', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @articles = Search.search_elements_by_type('Article', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @lres = Search.search_elements_by_type('Lre', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @posts = Search.search_elements_by_type('Post', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @slideshows = Search.search_elements_by_type('Slideshow', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @biographies = Search.search_elements_by_type('Biography', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @reports = Search.search_elements_by_type('Report', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @klascements = Search.search_elements_by_type('Klascement', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @widgets = Search.search_elements_by_type('Widget', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @artworks = Search.search_elements_by_type('Artwork', @search_text,@search_text_en_translation,@article_id,4)[:results]
      @books = Search.search_elements_by_type('Book', @search_text,@search_text_en_translation,@article_id,4)[:results]
      
      if @sites.size > 0 or @events.size > 0 or @lectures.size > 0 or @documentaries.size > 0 or @applications.size > 0 or @courses.size > 0 or @articles.size > 0 or @lres.size > 0 or @posts.size > 0 or @slideshows.size > 0 or @biographies.size > 0 or @reports.size or @klascements.size or @widgets.size or @artworks.size or @books.size > 0 
        @best_results =Search.search_in_all_resources(@search_text,@search_text_en_translation,8)[:results]
      end
      
      if @search_text.index("#") == 0 
        search = Search.new
        if I18n.locale.to_s != "en" && @search_text_locale_translation != nil
          @disambigued_term_info = search.disambigued_term_info(Util.to_hashtag_with_language(@search_text_locale_translation))
        else
          @disambigued_term_info = search.disambigued_term_info(@search_text)  
        end        
      end
          
    else 
      @sites = []
      @events = []
      @lectures = []
      @documentaries = []
      #@people = []
      @applications = []
      @courses = []
      @articles = []
      @lres = []
      @posts = []
      @slideshows = []
      @biographies = []
      @reports = []
      @klascements = []
      @widgets = []
      @artworks = []
      @books = []
    end
    
    if @sites.size > 0 or @events.size > 0 or @lectures.size > 0 or @documentaries.size > 0 or @applications.size > 0 or @courses.size > 0 or @articles.size > 0 or @lres.size > 0 or @posts.size > 0 or @slideshows.size > 0 or @biographies.size > 0 or @reports.size or @klascements.size or @widgets.size > 0 or @artworks.size or @books.size > 0
      @no_results = false
    else
      @no_results = true
    end
    
  end
    
    
  
  def all_related_elements
    @edition_mode = false
    @element_id = params[:element_id]
    @element_type = params[:element_type]
    @related_type = params[:related_type]
    @title = params[:title] 
    @element = @element_type.constantize.find(@element_id)
    if @element != nil
      @related_elements=RelatedElement.new(@element)
      @elements=@related_elements.get_all_related_elements(@related_type,params[:page])
    end
  end
  
  
  
  
  def all_best_search_results
    @search_text = params[:search]    
    @article_id = params[:article_id]   
                   
    if @search_text != nil      
      if @search_text.index("#") == 0 
        if I18n.locale.to_s != "en" && @search_text.index("@") != nil
          #Esto es para tener el termino traducido al ingles para hacer las busquedas con el tag en ingles 
          clean_search_text = @search_text[0,@search_text.index("@")]
          @search_text_en_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(clean_search_text),I18n.locale.to_s,"en")
        end                  
      end      
      @elements = Search.search_in_all_resources(@search_text,@search_text_en_translation,32,params[:page])[:results]      
    end            
  end
  
  
  
   def load_more_search_results
      @search_text = params[:search]
      @article_id = params[:article_id]
      @element_type = params[:element_type]
      @page = params[:page]
   
      if @search_text != nil
         if @search_text.index("#") == 0
            if I18n.locale.to_s != "en" && @search_text.index("@") != nil
               #Esto es para tener el termino traducido al ingles para hacer las busquedas con el tag en ingles
               clean_search_text = @search_text[0,@search_text.index("@")]
               @search_text_en_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(clean_search_text),I18n.locale.to_s,"en")
            elsif I18n.locale.to_s != "en" && @search_text.index("@") == nil
               #Esto es para traducir el termino al idioma de la vista para ver la info de desambiguacion del termino en ese idioma
               @search_text_locale_translation = Wikipediator.wikipedia_get_article_title_tranlation(Util.to_tag(@search_text),"en",I18n.locale.to_s)
            end
         end
         @elements = Search.search_elements_by_type(@element_type, @search_text,@search_text_en_translation,@article_id,4,@page)[:results]
         #puts @elements
      end
   
      respond_to do |format|
         format.js
      end
   end


   def load_more_related_elements
      @element_type = params[:element_type]
      @related_type = params[:related_type]
      @page = params[:page]
      @id = params[:id]                  
      
      element = @element_type.constantize.find(@id)
      @related = RelatedElement.new(element)
      @related_elements = @related.get_related_elements(@related_type,@page)      
      respond_to do |format|
         format.js
      end
      
   end
    
end