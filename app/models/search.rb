# encoding: utf-8


class Search
  #include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers

  def self.search_elements_by_type(element_type,search_text,english_search_terms,article_id,results_per_page,page = 1)
    if element_type == "Widget" && I18n.locale.to_s != "en"## HACK para ver Widgets en ingles en todos los idiomas
      search_languages = [I18n.locale.to_s,"en"]
    elsif I18n.locale.to_s == "gl"
      search_languages = ["gl","es"]    
    else 
      search_languages = [I18n.locale.to_s]
    end
    
    #CASO DE BUSQUEDA DESAMBIAGUADA 
    if search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") == nil    
        search_terms = search_text 
        search = element_type.constantize.search do |query|
          query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
            boost_fields :w100_wikitopics => 10.0
            boost_fields :w95_wikitopics => 9.5
            boost_fields :w90_wikitopics => 9
            boost_fields :w85_wikitopics => 8.5
            boost_fields :w80_wikitopics => 8.0
            boost_fields :w75_wikitopics => 7.5
            boost_fields :w70_wikitopics => 7.0
            boost_fields :w65_wikitopics => 6.5
            boost_fields :w60_wikitopics => 6.0
            boost_fields :w55_wikitopics => 5.5
            boost_fields :w50_wikitopics => 5.0
          end        
          query.with(:translations, search_languages)  
          query.paginate :page => page, :per_page => results_per_page 
        end
        elements = search.results
        num_results = search.total       
        return :results => elements, :total => num_results
        
       #CASO DESAMBIGUACION EN OTRO IDIOMA
       elsif search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") != nil                           
         #No encontramos tag de la wikiepdia en ingles
         if english_search_terms == nil
           search_terms = Util.to_tag(search_text)                                
           if search_terms.index("@") != nil
              search_terms = search_terms[0,search_terms.index("@")]
           end           
           search = element_type.constantize.search do |query|
              query.fulltext search_terms
              query.with(:translations, search_languages)  
              query.paginate :page => page, :per_page => results_per_page 
           end
           elements = search.results
           num_results = search.total       
           return :results => elements, :total => num_results
           
         #Esta en la wikipedia en ingles seguimos buscando con el termino ingles de hashtag 
         else           
            search_terms = Util.to_hashtag(english_search_terms)            
            search = element_type.constantize.search do |query|
              query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
                boost_fields :w100_wikitopics => 10.0
                boost_fields :w95_wikitopics => 9.5
                boost_fields :w90_wikitopics => 9
                boost_fields :w85_wikitopics => 8.5
                boost_fields :w80_wikitopics => 8.0
                boost_fields :w75_wikitopics => 7.5
                boost_fields :w70_wikitopics => 7.0
                boost_fields :w65_wikitopics => 6.5
                boost_fields :w60_wikitopics => 6.0
                boost_fields :w55_wikitopics => 5.5
                boost_fields :w50_wikitopics => 5.0
              end        
              query.with(:translations, search_languages)  
              query.paginate :page => page, :per_page => results_per_page 
            end
            elements = search.results
            num_results = search.total       
            return :results => elements, :total => num_results           
         end

        
    #CASO DE BUSQUEDA SIN DESAMBIGUAR (Como no pudimos poner bien el tokenizador lo separamos, si no con esto ya valdria)
    else 
      search_terms = search_text 
      search = element_type.constantize.search do |query|
        query.fulltext search_terms do
          boost_fields :hashtags_100 => 10.0
          boost_fields :hashtags_95 => 9.5
          boost_fields :hashtags_90 => 9
          boost_fields :hashtags_85 => 8.5
          boost_fields :hashtags_80 => 8.0
          boost_fields :hashtags_75 => 7.5
          boost_fields :hashtags_70 => 7.0
          boost_fields :hashtags_65 => 6.5
          boost_fields :hashtags_60 => 6.0
          boost_fields :hashtags_55 => 5.5
          boost_fields :hashtags_50 => 5.0
          
          boost_fields :tags => 4.0          
          #phrase_fields :tags => 10.0 
          #query.keywords search_terms, :fields => [:categories, :tags, :name] {minimum_match 1}       
        end        
        query.with(:translations, search_languages)  
        query.paginate :page => page, :per_page => results_per_page 
      end
      elements = search.results
      num_results = search.total       
      return :results => elements, :total => num_results      
    end        

   
  end
      
=begin        
      else      
        ###############################################################
        #########CUANDO ESTEN TODOS MODELOS INDEXADOS BORRAR ESTO!!!!  
        ################################################################
        #Si accedemos por la URL de desambiguacion viene con article id      
        if article_id != nil
          if results_per_page == 4 #Busqueda general esta limitada a 4 resultados (aumento de velocidad)
            tags_annotations = TaggableTagAnnotation.where(:wikipedia_article_id => article_id, :taggable_type => element_type).order("weight DESC").limit(results_per_page)
            elements_results = element_type.constantize.find_all_by_id(tags_annotations.map{|annotation| annotation.taggable_id}).first(results_per_page)
          else #Busqueda en un recurso particular ya no esta limitada
            tags_annotations = TaggableTagAnnotation.where(:wikipedia_article_id => article_id, :taggable_type => element_type).order("weight DESC")
            elements_results = element_type.constantize.find_all_by_id(tags_annotations.map{|annotation| annotation.taggable_id})
          end
          if elements_results.size > 0
             elements = Kaminari.paginate_array(elements_results).page(page).per(results_per_page)         
             #elements = Sunspot::Search::PaginatedCollection.new(elements_results,1,elements_results.size,elements_results.size)           
             num_results = elements_results.size
          else
             search = self.get_empty_sunspot_search(element_type)           
             elements = search[:results]
             num_results=search[:total]           
          end
        #Si NO accedemos por la URL de desambiguacion. Puesto a saco la # en buscador                        
        else
          search_terms = Util.to_tag(search_text)
          tag_search_terms = Tag.find_by_name(search_terms)
          if tag_search_terms != nil 
            if results_per_page == 4 #Busqueda general esta limitada a 4 resultados (aumento de velocidad)
              tags_annotations = TaggableTagAnnotation.where(:tag_id => tag_search_terms.id, :taggable_type => element_type, :type_tag => ["automatic","automatic_from_human"]).order("weight DESC").limit(results_per_page)
              elements_results = element_type.constantize.find_all_by_id(tags_annotations.map{|annotation| annotation.taggable_id}).first(results_per_page)
            else #Busqueda en un recurso particular ya no esta limitada
              tags_annotations = TaggableTagAnnotation.where(:tag_id => tag_search_terms.id, :taggable_type => element_type, :type_tag => ["automatic","automatic_from_human"]).order("weight DESC")
              elements_results = element_type.constantize.find_all_by_id(tags_annotations.map{|annotation| annotation.taggable_id})
            end
            if elements_results.size > 0
              elements = Kaminari.paginate_array(elements_results).page(page).per(results_per_page)         
              #elements = Sunspot::Search::PaginatedCollection.new(elements_results,1,elements_results.size,elements_results.size)
              num_results = elements_results.size
            else
              search = self.get_empty_sunspot_search(element_type)           
              elements = search[:results]
              num_results=search[:total] 
            end
          else
            search = self.get_empty_sunspot_search(element_type)           
            elements = search[:results]
            num_results=search[:total]         
          end                
        end                      
        return :results => elements, :total => num_results                  
      end      
        
=end
        
    
    
  ##########################################################################
  #### FUNCION PARA BUSCAR UN TERMINO EN TODOS LOS RECURSOS DEL SISTEMA ####
  ##########################################################################
  def self.search_in_all_resources(search_text,english_search_terms,results_per_page,page = 1)
    if I18n.locale.to_s == "gl"
      search_languages = ["gl","es"]
    else 
      search_languages = [I18n.locale.to_s]
    end
    
    #CASO DE BUSQUEDA DESAMBIAGUADA 
    if search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") == nil    
        search_terms = search_text 
        search = Sunspot.search [Application,Event,Biography,Lecture,Site,Documentary,Course,Article,Post,Slideshow,Report,Lre,Klascement,Widget,Artwork,Book] do |query|
          query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
            boost_fields :w100_wikitopics => 10.0
            boost_fields :w95_wikitopics => 9.5
            boost_fields :w90_wikitopics => 9
            boost_fields :w85_wikitopics => 8.5
            boost_fields :w80_wikitopics => 8.0
            boost_fields :w75_wikitopics => 7.5
            boost_fields :w70_wikitopics => 7.0
            boost_fields :w65_wikitopics => 6.5
            boost_fields :w60_wikitopics => 6.0
            boost_fields :w55_wikitopics => 5.5
            boost_fields :w50_wikitopics => 5.0
          end        
          query.with(:translations, search_languages)  
          query.paginate :page => page, :per_page => results_per_page 
        end
        elements = search.results
        num_results = search.total       
        return :results => elements, :total => num_results
        
       #CASO DESAMBIGUACION EN OTRO IDIOMA
       elsif search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") != nil                           
         #No encontramos tag de la wikiepdia en ingles
         if english_search_terms == nil
           search_terms = Util.to_tag(search_text)                                
           if search_terms.index("@") != nil
              search_terms = search_terms[0,search_terms.index("@")]
           end           
           search = Sunspot.search [Application,Event,Biography,Lecture,Site,Documentary,Course,Article,Post,Slideshow,Report,Lre,Klascement,Widget,Artwork,Book] do |query|
              query.fulltext search_terms
              query.with(:translations, search_languages)  
              query.paginate :page => page, :per_page => results_per_page 
           end
           elements = search.results
           num_results = search.total       
           return :results => elements, :total => num_results
           
         #Esta en la wikipedia en ingles seguimos buscando con el termino ingles de hashtag 
         else           
            search_terms = Util.to_hashtag(english_search_terms)            
            search = Sunspot.search [Application,Event,Biography,Lecture,Site,Documentary,Course,Article,Post,Slideshow,Report,Lre,Klascement,Widget,Artwork,Book] do |query|
              query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
                boost_fields :w100_wikitopics => 10.0
                boost_fields :w95_wikitopics => 9.5
                boost_fields :w90_wikitopics => 9
                boost_fields :w85_wikitopics => 8.5
                boost_fields :w80_wikitopics => 8.0
                boost_fields :w75_wikitopics => 7.5
                boost_fields :w70_wikitopics => 7.0
                boost_fields :w65_wikitopics => 6.5
                boost_fields :w60_wikitopics => 6.0
                boost_fields :w55_wikitopics => 5.5
                boost_fields :w50_wikitopics => 5.0
              end        
              query.with(:translations, search_languages)  
              query.paginate :page => page, :per_page => results_per_page 
            end
            elements = search.results
            num_results = search.total       
            return :results => elements, :total => num_results           
         end
        
    #CASO DE BUSQUEDA SIN DESAMBIGUAR (Como no pudimos poner bien el tokenizador lo separamos, si no con esto ya valdria)
    else 
      search_terms = search_text 
      search = Sunspot.search [Application,Event,Biography,Lecture,Site,Documentary,Course,Article,Post,Slideshow,Report,Lre,Klascement,Widget,Artwork,Book] do |query|
        query.fulltext search_terms do
          boost_fields :hashtags_100 => 10.0
          boost_fields :hashtags_95 => 9.5
          boost_fields :hashtags_90 => 9
          boost_fields :hashtags_85 => 8.5
          boost_fields :hashtags_80 => 8.0
          boost_fields :hashtags_75 => 7.5
          boost_fields :hashtags_70 => 7.0
          boost_fields :hashtags_65 => 6.5
          boost_fields :hashtags_60 => 6.0
          boost_fields :hashtags_55 => 5.5
          boost_fields :hashtags_50 => 5.0
          
          boost_fields :tags => 4.0          
          #phrase_fields :tags => 10.0 
          #query.keywords search_terms, :fields => [:categories, :tags, :name] {minimum_match 1}       
        end        
        query.with(:translations, search_languages)  
        query.paginate :page => page, :per_page => results_per_page 
      end
      elements = search.results
      num_results = search.total       
      return :results => elements, :total => num_results      
    end           
  end
  

  
  
   def self.advanced_search_elements_by_type(element_type,search_text,english_search_terms,advanced_parameters,results_per_page,page = 1)
      if I18n.locale.to_s == "gl"
         search_languages = ["gl","es"]
      else
         search_languages = [I18n.locale.to_s]
      end
      #CASO DE BUSQUEDA DESAMBIAGUADA
      if search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") == nil
         search_terms = search_text
         search = element_type.constantize.search do |query|
            if search_terms != ""
               query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
                  boost_fields :w100_wikitopics => 10.0
                  boost_fields :w95_wikitopics => 9.5
                  boost_fields :w90_wikitopics => 9
                  boost_fields :w85_wikitopics => 8.5
                  boost_fields :w80_wikitopics => 8.0
                  boost_fields :w75_wikitopics => 7.5
                  boost_fields :w70_wikitopics => 7.0
                  boost_fields :w65_wikitopics => 6.5
                  boost_fields :w60_wikitopics => 6.0
                  boost_fields :w55_wikitopics => 5.5
                  boost_fields :w50_wikitopics => 5.0
               end
            end
            if advanced_parameters[:functionality]!= nil && advanced_parameters[:functionality]!= ""
               query.with(:functionalities, advanced_parameters[:functionality])
            end
            if advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != "" && advanced_parameters[:end_date] != nil && advanced_parameters[:end_date] != ""
               query.with :start_date, advanced_parameters[:start_date]..advanced_parameters[:end_date]
            elsif  advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != ""
               query.with(:start_date).greater_than_or_equal_to(advanced_parameters[:start_date])             
            end
            if advanced_parameters[:radius] != nil && advanced_parameters[:radius] != "" && advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
               query.with(:location).in_radius(advanced_parameters[:latitude], advanced_parameters[:longitude], advanced_parameters[:radius])
            end
            if advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
               query.order_by_geodist(:location, advanced_parameters[:latitude], advanced_parameters[:longitude])
            end

            query.with(:translations, search_languages)
            query.paginate :page => page, :per_page => results_per_page
         end
         elements = search.results
         num_results = search.total
         return :results => elements, :total => num_results

      #CASO DESAMBIGUACION EN OTRO IDIOMA
      elsif search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") != nil
         #No encontramos tag de la wikiepdia en ingles
         if english_search_terms == nil
            search_terms = Util.to_tag(search_text)
            if search_terms.index("@") != nil
               search_terms = search_terms[0,search_terms.index("@")]
            end
            search = element_type.constantize.search do |query|
               if search_terms != ""
                  query.fulltext search_terms
               end
               if advanced_parameters[:functionality]!= nil && advanced_parameters[:functionality]!= ""
                  query.with(:functionalities, advanced_parameters[:functionality])
               end
               if advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != "" && advanced_parameters[:end_date] != nil && advanced_parameters[:end_date] != ""
                  query.with :start_date, advanced_parameters[:start_date]..advanced_parameters[:end_date]
               elsif  advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != ""
                  query.with(:start_date).greater_than_or_equal_to(advanced_parameters[:start_date])             
               end
               if advanced_parameters[:radius] != nil && advanced_parameters[:radius] != "" && advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
                  query.with(:location).in_radius(advanced_parameters[:latitude], advanced_parameters[:longitude], advanced_parameters[:radius])
               end
               if advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
                  query.order_by_geodist(:location, advanced_parameters[:latitude], advanced_parameters[:longitude])
               end
               query.with(:translations, search_languages)
               query.paginate :page => page, :per_page => results_per_page
            end
            elements = search.results
            num_results = search.total
            return :results => elements, :total => num_results

         #Esta en la wikipedia en ingles seguimos buscando con el termino ingles de hashtag
         else
            search_terms = Util.to_hashtag(english_search_terms)
            search = element_type.constantize.search do |query|
               if search_terms != ""
                  query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
                     boost_fields :w100_wikitopics => 10.0
                     boost_fields :w95_wikitopics => 9.5
                     boost_fields :w90_wikitopics => 9
                     boost_fields :w85_wikitopics => 8.5
                     boost_fields :w80_wikitopics => 8.0
                     boost_fields :w75_wikitopics => 7.5
                     boost_fields :w70_wikitopics => 7.0
                     boost_fields :w65_wikitopics => 6.5
                     boost_fields :w60_wikitopics => 6.0
                     boost_fields :w55_wikitopics => 5.5
                     boost_fields :w50_wikitopics => 5.0
                  end
               end
               if advanced_parameters[:functionality]!= nil && advanced_parameters[:functionality]!= ""
                  query.with(:functionalities, advanced_parameters[:functionality])
               end
               if advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != "" && advanced_parameters[:end_date] != nil && advanced_parameters[:end_date] != ""
                  query.with :start_date, advanced_parameters[:start_date]..advanced_parameters[:end_date]
               elsif  advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != ""
                  query.with(:start_date).greater_than_or_equal_to(advanced_parameters[:start_date])             
               end
               if advanced_parameters[:radius] != nil && advanced_parameters[:radius] != "" && advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
                  query.with(:location).in_radius(advanced_parameters[:latitude], advanced_parameters[:longitude], advanced_parameters[:radius])
               end
               if advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
                  query.order_by_geodist(:location, advanced_parameters[:latitude], advanced_parameters[:longitude])
               end
               query.with(:translations, search_languages)
               query.paginate :page => page, :per_page => results_per_page
            end
            elements = search.results
            num_results = search.total
            return :results => elements, :total => num_results
         end

      #CASO DE BUSQUEDA SIN DESAMBIGUAR (Como no pudimos poner bien el tokenizador lo separamos, si no con esto ya valdria)
      else
         search_terms = search_text
         search = element_type.constantize.search do |query|
            if search_terms!= nil && search_terms != ""
               query.fulltext search_terms do
                  boost_fields :hashtags_100 => 10.0
                  boost_fields :hashtags_95 => 9.5
                  boost_fields :hashtags_90 => 9
                  boost_fields :hashtags_85 => 8.5
                  boost_fields :hashtags_80 => 8.0
                  boost_fields :hashtags_75 => 7.5
                  boost_fields :hashtags_70 => 7.0
                  boost_fields :hashtags_65 => 6.5
                  boost_fields :hashtags_60 => 6.0
                  boost_fields :hashtags_55 => 5.5
                  boost_fields :hashtags_50 => 5.0
   
                  boost_fields :tags => 4.0                            
               end
            end
            if advanced_parameters[:functionality]!= nil && advanced_parameters[:functionality]!= ""
               query.with(:functionalities, advanced_parameters[:functionality])
            end
            if advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != "" && advanced_parameters[:end_date] != nil && advanced_parameters[:end_date] != ""
               query.with :start_date, advanced_parameters[:start_date]..advanced_parameters[:end_date]
            elsif  advanced_parameters[:start_date] != nil && advanced_parameters[:start_date] != ""
               query.with(:start_date).greater_than_or_equal_to(advanced_parameters[:start_date])             
            end
            if advanced_parameters[:radius] != nil && advanced_parameters[:radius] != "" && advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
               query.with(:location).in_radius(advanced_parameters[:latitude], advanced_parameters[:longitude], advanced_parameters[:radius])
            end
            if advanced_parameters[:latitude] != nil && advanced_parameters[:latitude] != "" && advanced_parameters[:longitude] != nil && advanced_parameters[:longitude] != ""
               query.order_by_geodist(:location, advanced_parameters[:latitude], advanced_parameters[:longitude])
            end
            query.with(:translations, search_languages)
            query.paginate :page => page, :per_page => results_per_page
         end
         elements = search.results
         num_results = search.total
         return :results => elements, :total => num_results
      end

   end


  
  
  
  def self.disambiguation(search_text)
    disambiguation = Array.new
    if search_text != nil && search_text.index("#") == nil
      case I18n.locale
      when :en
          wiki = Wikipediator.new
          begin 
            disamb_results = wiki.search(search_text)
            disamb_results.each do |alternative_search|
              title = alternative_search['title']
              definition = wiki.getDefinition(title)
              id = alternative_search['id']
              disambiguation << [title, definition, id] #[title, definition]
            end      
          rescue Exception => e
            puts "Exception in disambiguation"
            puts e.backtrace.inspect
            puts e.message 
          end
      else
        disambiguation = Wikipediator.wikipedia_disambiguate(search_text,I18n.locale)        
      end
    end
    return disambiguation
  end
  
  
  
  def self.get_empty_sunspot_search(element_type)
    search = element_type.constantize.search do 
      fulltext "cllldsojfndjdujdsksooeinsujhdff"                
      paginate :page => 1, :per_page => 10 
    end
    elements = search.results
    num_results = search.total  
    return :results => elements, :total => num_results   
  end
  
  
  
  def disambigued_term_info(search_text)    
    term_info = Hash.new 
     
    if search_text != nil && search_text.index("#") == 0
      #Obtenemos La Definicion del wikipediator (Esto igual lo podiamos sacar ya de la wikipedia para hacer una conexion menos a un servicio)          
      w = Wikipediator.new
      
      case I18n.locale
      when :en
        definition = w.getDefinition(Util.to_tag(search_text))
        term_info[:title] = Util.to_tag(search_text)            
        term_info[:definition] = definition
        search_text = search_text[1,search_text.size]
        url_wiki = "https://"+I18n.locale.to_s+".wikipedia.org/wiki/" + search_text
        begin
          page = Nokogiri::HTML(open(url_wiki))
          properties = Array.new
          infobox = page.css("table.infobox")[0]
          infobox.css("tr").each_with_index do |line,index| 
                               
            line_title = line.css("th")[0]
            article_image = false
            if line_title != nil
              line_title = strip_tags line_title.text.gsub("\n","")
            elsif line_title == nil && term_info[:image] == nil && index < 3
              begin                      
                line_title = "http:" + line.css("td")[0].css('img')[0]['src']
                article_image = true
              rescue
                puts "ERROR Obteniendo foto de infobox"
              end
            end     
                   
            line_content = line.css("td")[0]          
            if line_content != nil && line_title != nil && line_title != "Signature"
              line_content.search('sup').remove # Eliminamos los [1],[2], etc 
              line_content.search('br').each do |n|
                n.replace(", ")
              end
              
              #Colocamos espacios en blanco en las lista li                       
              line_content.search('ul').each do |ul|
                li_size = ul.search('li').size
                ul.search('li').each_with_index do |li,index_li|    
                  # Esto es por si hay listas dentro de listas            
                  li.search('ul').each do |sub_ul|
                    sub_li_size = sub_ul.search('li').size
                    sub_ul.search('li').each_with_index do |sub_li,index_sub_li|                   
                      if (index_sub_li+1) == sub_li_size
                        sub_li.replace("#{ sub_li.to_html.strip }")
                      else
                        sub_li.replace("#{ sub_li.to_html.strip }, ")
                      end                     
                    end
                    sub_ul.replace(sub_ul.to_html)
                  end
                  if (index_li+1) == li_size
                    li.replace("#{ li.to_html.strip }")
                  else
                    li.replace("#{ li.to_html.strip }, ")
                  end                
                end
                ul.replace(ul.to_html)
              end
              
              #Esto es para cuando un link no tiene pagia en wikipedia debido a que no se escribio aun pero tiene link
              line_content.css("a.new").each do |no_link_article|
                no_link_article.attributes['href'].remove              
                no_link_article.name = "span"              
              end
              #Eliminamos tags y y nos quedamos con el contenido
              #strip_tags line_content.text.gsub("\n","").gsub(",,",",")
              #line_content = line_content.gsub("\/wiki\/","\/search_results\/#")            
              line_content =  sanitize line_content.to_html.gsub("\n","").gsub(",,",","), tags: %w(a)
            else
              line_content = nil
            end
            if article_image == true
              term_info[:image] = line_title
            elsif line_title != nil && line_content != nil && line_title != "" && line_content != ""
              properties << {:name => line_title, :content => line_content}           
            end
          end
          term_info[:info] = properties
          return term_info
        rescue Exception => e
          puts "Exception in desambigued_term_info"
          puts e.backtrace.inspect
          puts e.message
          term_info[:info] = nil
          return term_info                
        end
                
      ######## EN OTROS IDIOMAS        
      else        
        search_text = search_text[1,search_text.size]
        if search_text.index("@") != nil
          search_text = search_text[0,search_text.index("@")]
        end
        term_info[:title] = Util.to_tag(search_text) 
        term_info[:definition] = Wikipediator.wikipedia_get_article_description(search_text,I18n.locale.to_s)
        if term_info[:definition] == nil
          return nil
        else       
          term_info[:image] = Wikipediator.wikipedia_get_article_image(search_text,I18n.locale.to_s)
          return term_info
        end
        
      end
      
      
                  
      
      
    end  
  end
  
  
  

  
  
  #################################################
  
   ######### LIST RESOURCES. If logued in order results boosting circumstances tags and subject ############

  def self.listing_elements_by_type(element_type,search_languages, current_user, per_page, page = 1)
     if page.nil? or page == 0
        page = 1
     end
     case element_type
     when "Biography"
         db_resource = "biographies"
     when "Documentary"
         db_resource = "documentaries"
     else
         db_resource = element_type.downcase + "s"   
     end      
     db_resource_translation = element_type.downcase + "_translations"
     
     #### SI usuario logueado     
     if current_user != nil && current_user.circumstances != []
         ## CASO especial de SITE ya que por motivos yo creo que de escalabilidad no funciona correctamente los search_ids como en los otros con per_pge muy elevado
         if element_type == "Site"
            searching = element_type.constantize.search do |query|                     
               query.with(:translations, search_languages)
               if current_user.circumstances.first.latitude != nil
                  query.order_by_geodist(:location, current_user.circumstances.first.latitude, current_user.circumstances.first.longitude)    
               end                                
               query.paginate :page => page,:per_page => per_page                             
            end
            elements = searching.results             
            num_results = searching.total
            return :results => elements, :total => num_results
         ### Resto de recursos 
         else        
            boosting_resources_ids = element_type.constantize.search_ids do |query|                     
               query.with(:translations, search_languages)
               if element_type == "Report" or element_type == "Post"
                  query.order_by(:publication_date, :desc)
               elsif element_type == "Application"
                  query.with :operating_systems, [current_user.circumstances.first.operating_system_id, 6]
                  if current_user.circumstances.first.has_internet == false
                     query.without :operating_systems, 6
                  end
               elsif element_type == "Event"## or element_type == "Site" 
                  if current_user.circumstances.first.latitude != nil
                     #query.with(:location).in_radius(current_user.circumstances.first.latitude, current_user.circumstances.first.longitude, 2000)       
                     query.order_by_geodist(:location, current_user.circumstances.first.latitude, current_user.circumstances.first.longitude)    
                  end                          
               end                                     
               search_terms = current_user.circumstances.first.tags.map { |t| '"' + Util.to_hashtag(t.name) + '"' if t.name != nil}.join(" ") + " " + current_user.circumstances.first.subject.name          
               query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics, :tags] do                              
                  minimum_match 1
               end                     
               query.paginate :page => 1,:per_page => 50000 ### ESTO ES PARA CONSEGUIR TODOS LOS IDS (SI CRECIERA BASE DE DATOS MUCHO SUBIR ESTE NUMERO                    
            end                  
            
            all_resources_ids = element_type.constantize.search_ids do |query|                     
               query.with(:translations, search_languages)
               if element_type == "Report" or element_type == "Post"
                  query.order_by(:publication_date, :desc)                           
               elsif element_type == "Event"## or element_type == "Site" 
                  if current_user.circumstances.first.latitude != nil
                     query.order_by_geodist(:location, current_user.circumstances.first.latitude, current_user.circumstances.first.longitude)    
                  end                          
               end                   
               query.paginate :page => 1,:per_page => 300000 ### ESTO ES PARA CONSEGUIR TODOS LOS IDS (SI CRECIERA BASE DE DATOS MUCHO SUBIR ESTE NUMERO)
            end
            #remain_resources_ids = element_type.constantize.select(:id).map(&:id)         
            #puts all_resources_ids.map{|a| a}.join(",")
            
            remain_resources_ids = all_resources_ids - boosting_resources_ids                                                                
            all_resources_ids = boosting_resources_ids + remain_resources_ids
            #puts all_resources_ids.map{|a| a}.join(",")                     
   
            min = (page.to_i * per_page.to_i) - per_page.to_i
            max = page.to_i * per_page.to_i
            #Cargamos solo los elementos de la pagina, para que vaya rapido los otros quedan con numeros        
            Array(min..max).each do |index|            
               aux = element_type.constantize.find_by_id(all_resources_ids[index])
               if aux != nil
                  all_resources_ids[index] = aux
               end
            end                                                          
            elements = Kaminari.paginate_array(all_resources_ids).page(page).per(per_page)
            num_results = all_resources_ids.size
            
            return :results => elements, :total => num_results
         end                            
     #### SI usuario no logueado se sacan sin ningun orden especifico         
     else
        listing_elements_by_type_without_boost_circumstance(element_type,search_languages, current_user, per_page, page)               
     end                   
               
  end
  
  ##############################  
  
  def self.listing_elements_by_type_without_boost_circumstance(element_type,search_languages, current_user, per_page, page = 1)
     searching = element_type.constantize.search do |query|    
        puts searching 
        puts query
        if element_type != "Document"         
           query.with(:translations, search_languages)    
        end
        if element_type == "Report"
           query.order_by(:publication_date, :desc)
        end                             
        query.paginate :page => page,:per_page => per_page                 
     end
     elements = searching.results             
     num_results = searching.total
     return :results => elements, :total => num_results 
  end
  
  
  
  ####################################### REPORT SECTIONS ####################################################
  
  def self.search_reports_by_section_and_date(section,date_range, search_text,english_search_terms,article_id,results_per_page,page = 1)
    section = section.capitalize
    element_type = "Report"  
    if element_type == "Widget" && I18n.locale.to_s != "en"## HACK para ver Widgets en ingles en todos los idiomas
      search_languages = [I18n.locale.to_s,"en"]
    elsif I18n.locale.to_s == "gl"
      search_languages = ["gl","es"]    
    else 
      search_languages = [I18n.locale.to_s]
    end
    
    #CASO DE BUSQUEDA DESAMBIAGUADA 
    if search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") == nil    
        search_terms = search_text 
        search = element_type.constantize.search do |query|
          if section.downcase != "all"
             query.fulltext section, :fields => [:section]            
          end 
          query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
            boost_fields :w100_wikitopics => 10.0
            boost_fields :w95_wikitopics => 9.5
            boost_fields :w90_wikitopics => 9
            boost_fields :w85_wikitopics => 8.5
            boost_fields :w80_wikitopics => 8.0
            boost_fields :w75_wikitopics => 7.5
            boost_fields :w70_wikitopics => 7.0
            boost_fields :w65_wikitopics => 6.5
            boost_fields :w60_wikitopics => 6.0
            boost_fields :w55_wikitopics => 5.5
            boost_fields :w50_wikitopics => 5.0
          end        
          query.with(:translations, search_languages)
          if element_type == "Report"
             if date_range == "last_day"
                query.with(:publication_date).greater_than(1.day.ago)
             elsif date_range == "last_week"
                query.with(:publication_date).between(1.week.ago..1.day.ago)
             elsif date_range == "last_month"
                query.with(:publication_date).between(1.month.ago..1.week.ago)            
             end
          end  
          query.paginate :page => page, :per_page => results_per_page 
        end
        elements = search.results
        num_results = search.total       
        return :results => elements, :total => num_results
        
       #CASO DESAMBIGUACION EN OTRO IDIOMA
       elsif search_text != nil && search_text.index("#") != nil &&  search_text.index("#") == 0 && search_text.index("@") != nil                           
         #No encontramos tag de la wikiepdia en ingles
         if english_search_terms == nil
           search_terms = Util.to_tag(search_text)                                
           if search_terms.index("@") != nil
              search_terms = search_terms[0,search_terms.index("@")]
           end           
           search = element_type.constantize.search do |query|
              if section.downcase != "all"
                  query.fulltext section, :fields => [:section]            
              end 
              query.fulltext search_terms
              query.with(:translations, search_languages)
              if element_type == "Report"
                  if date_range == "last_day"
                     query.with(:publication_date).greater_than(1.day.ago)
                  elsif date_range == "last_week"
                     query.with(:publication_date).between(1.week.ago..1.day.ago)
                  elsif date_range == "last_month"
                     query.with(:publication_date).between(1.month.ago..1.week.ago)                  
                  end
              end  
              query.paginate :page => page, :per_page => results_per_page 
           end
           elements = search.results
           num_results = search.total       
           return :results => elements, :total => num_results
           
         #Esta en la wikipedia en ingles seguimos buscando con el termino ingles de hashtag 
         else           
            search_terms = Util.to_hashtag(english_search_terms)            
            search = element_type.constantize.search do |query|
              if section.downcase != "all"
                  query.fulltext section, :fields => [:section]            
              end 
              query.fulltext search_terms, :fields => [:w100_wikitopics, :w95_wikitopics, :w90_wikitopics, :w85_wikitopics, :w80_wikitopics, :w75_wikitopics, :w70_wikitopics, :w65_wikitopics, :w60_wikitopics, :w55_wikitopics, :w50_wikitopics] do
                boost_fields :w100_wikitopics => 10.0
                boost_fields :w95_wikitopics => 9.5
                boost_fields :w90_wikitopics => 9
                boost_fields :w85_wikitopics => 8.5
                boost_fields :w80_wikitopics => 8.0
                boost_fields :w75_wikitopics => 7.5
                boost_fields :w70_wikitopics => 7.0
                boost_fields :w65_wikitopics => 6.5
                boost_fields :w60_wikitopics => 6.0
                boost_fields :w55_wikitopics => 5.5
                boost_fields :w50_wikitopics => 5.0
              end        
              query.with(:translations, search_languages)
              if element_type == "Report"
                 if date_range == "last_day"
                    query.with(:publication_date).greater_than(1.day.ago)
                 elsif date_range == "last_week"
                    query.with(:publication_date).between(1.week.ago..1.day.ago)
                 elsif date_range == "last_month"
                    query.with(:publication_date).between(1.month.ago..1.week.ago)            
                 end
              end   
              query.paginate :page => page, :per_page => results_per_page 
            end
            elements = search.results
            num_results = search.total       
            return :results => elements, :total => num_results           
         end

        
    #CASO DE BUSQUEDA SIN DESAMBIGUAR (Como no pudimos poner bien el tokenizador lo separamos, si no con esto ya valdria)
    else 
      search_terms = search_text 
      search = element_type.constantize.search do |query|
        if section.downcase != "all"
             query.fulltext section, :fields => [:section]            
        end 
        query.fulltext search_terms do
          boost_fields :hashtags_100 => 10.0
          boost_fields :hashtags_95 => 9.5
          boost_fields :hashtags_90 => 9
          boost_fields :hashtags_85 => 8.5
          boost_fields :hashtags_80 => 8.0
          boost_fields :hashtags_75 => 7.5
          boost_fields :hashtags_70 => 7.0
          boost_fields :hashtags_65 => 6.5
          boost_fields :hashtags_60 => 6.0
          boost_fields :hashtags_55 => 5.5
          boost_fields :hashtags_50 => 5.0
          
          boost_fields :tags => 4.0          
          #phrase_fields :tags => 10.0 
          #query.keywords search_terms, :fields => [:categories, :tags, :name] {minimum_match 1}       
        end        
        query.with(:translations, search_languages)
        if element_type == "Report"
           if date_range == "last_day"
              query.with(:publication_date).greater_than(1.day.ago)
           elsif date_range == "last_week"
              query.with(:publication_date).between(1.week.ago..1.day.ago)
           elsif date_range == "last_month"
              query.with(:publication_date).between(1.month.ago..1.week.ago)            
           end
        end   
        query.paginate :page => page, :per_page => results_per_page 
      end
      elements = search.results
      num_results = search.total       
      return :results => elements, :total => num_results      
    end        

   
  end
  
  
  
  
  
  
   def self.listing_reports_by_section_without_boost_circumstance(section,date_range,search_languages, current_user, per_page, page = 1)
      section = section.capitalize
      element_type = "Report"
      puts section
      searching = element_type.constantize.search do |query|
         query.with(:translations, search_languages)
         if element_type == "Report"
            if date_range == "last_day"
               query.with(:publication_date).greater_than(1.day.ago)
            elsif date_range == "last_week"
               query.with(:publication_date).between(1.week.ago..1.day.ago)
            elsif date_range == "last_month"
               query.with(:publication_date).between(1.month.ago..1.week.ago)
            else
               query.order_by(:publication_date, :desc)
            end
         end
         if section.downcase != "all"
            query.fulltext section, :fields => [:section]
         end
         query.paginate :page => page,:per_page => per_page
      end
      elements = searching.results
      num_results = searching.total
      return :results => elements, :total => num_results
   end
  
  
  
  
  
end