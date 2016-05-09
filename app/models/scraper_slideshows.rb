# encoding: utf-8

require 'capybara/rails'
require "capybara"
require "capybara/dsl"
require 'feedjira'

class ScraperSlideshows
  include ActionView::Helpers::SanitizeHelper
  include Capybara::DSL
  
  
  def scrape_slideshare
    begin 
      source_name = __method__.to_s    
      #Add new source, or select it if exists
      source = Source.create_or_select_source(source_name, "Slideshow", "http://www.slideshare.net")
             
      translator = Translator.new
      array_translated_categories = Array.new
      categories_array = ["art", "astronomy", "biology", "chemistry", "citizenship", "classical languages", "cross-curricular education", "culture", "economics", "educational administration", 
        "environmental education", "ethics", "European studies", "foreign language", "geography", "geology", "health education", "history", "home economics", "informatics/ICT", 
        "language and literature", "law", "mathematics", "media education", "music", "natural sciences", "philosophy", "physical education", "physics", "politics", "pre-school education",
        "primary education", "psychology", "religion", "school-community relationship", "social sciences", "special (needs) education", "technology"]
      languages = ["en","es","pt","tr","sk","no","fi","lt","nl","hu"]  
    
      categories_array.each do |category|
        puts "Traduciendo Category: " + category
        languages.each do |language|
          puts "Traduciendo category a idioma: " + language
          translated_category = translator.translate_bing_through_url(category,"en",language)
          array_translated_categories << {:translated_category => translated_category, :language => language}
        end
      end  
      array_translated_categories.each do |category|
        scrape_category_slideshare category[:translated_category], category[:language]
      end     
      source.correct_scrape
    rescue Exception => e
      puts "Exception scrape_slideshare"
      puts e.message
      puts e.backtrace.inspect
      source.incorrect_scrape      
    end
  end
  
  
  def scrape_category_slideshare(category, language, *siguiente)
    begin
      sleep 2  
      puts "Scraping category: " + category
      puts "Scraping language: " + language
      
      if siguiente[1] == 1
        reintentos = siguiente[2].to_i
      else
        reintentos = 2
      end
              
      if siguiente[1] != 1   
        pagina_actual = 1
      else
        pagina_actual = siguiente[0]
      end
                  
      for i in pagina_actual..8
        I18n.locale = language
        sleep 0.5
        pagina_actual = i
        puts "La pagina actual es: " + pagina_actual.to_s 
 
        url = URI.encode("http://www.slideshare.net/search/slideshow?lang=" + language + "&page=" + pagina_actual.to_s + "&q=" + category + "&searchfrom=header&sort=relevance")
        puts url
        page = Nokogiri::HTML(open(url))
        reintentos = 2

        page.css("li.clearfix").each do |slideshow|
          photo_url = nil
          slideshow_url = nil
          slideshow_url =  "http://www.slideshare.net" + slideshow.css(".slideshow-title")[0]['href']
          slideshow_url = slideshow_url.split("?qid")[0]
          photo_url =  slideshow.css("img.searchResultThumb")[0]['src']
          photo_url[0] = ""
          photo_url[0] = ""
          photo_url = "http://" + photo_url
          photo_url = photo_url.gsub("thumbnail-2","thumbnail-4")
          scrape_slideshow_slideshare slideshow_url, photo_url, language
        end  
      end
      
    rescue Exception => e
      puts "Exception scrape_idioma_slideshare"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.message
      puts e.backtrace.inspect
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        puts "antes de reintento, pag actual = " + pagina_actual.to_s
        scrape_category_slideshare(category,language,pagina_actual.to_i + 1,1,reintentos)
      end
    end
  end


 def scrape_slideshow_slideshare(slideshow_url, photo_url, language, *reintentos)
    begin
      puts
      puts "SLIDESHOW URL: " + slideshow_url
      idiomas_disponibles = Array.new
      idiomas_disponibles << language
      info_to_wikify = ""
      name = ""
      description = ""

      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end

      sleep 0.1

      scraped_slideshow = Slideshow.new
      slideshow_page = Nokogiri::HTML(open(slideshow_url))
      reintentos = 2
      begin
        name = slideshow_page.css("div.title h1.h-slideshow-title")[0].text.strip
        puts "Name: " + name
      rescue
        puts "Failed Name slideshare"
        name = ""
      end

      begin
        if !slideshow_page.css("div.articleCore p.descriptionExpanded").empty?
          description = slideshow_page.css("div.articleCore p.descriptionExpanded")[0].text.strip
          #puts "Description: " + description
        else
          description = slideshow_page.css("div.articleCore p.description")[0].text.strip
        end
      rescue
        puts "Failed Description slideshare"
        description = ""
      end

      if photo_url!=nil
        begin
          scraped_slideshow.element_image = URI.parse(photo_url)
        rescue
          puts "slideshare:  IMAGEN NO GUARDADA"
          scraped_slideshow.element_image.clear
        end
      end

      transcriptions = ""
 
      begin
        slideshow_page.css("div.notranslate ul.transcripts li").each do |li|
          transcriptions = transcriptions + ". " + li.text.strip
        end
        info_to_wikify = (name + ". " + description + ". " + transcriptions.gsub(/\n/," ").gsub(/\s+/,' ').gsub("&"," ").gsub("%"," ")).truncate(63000)
      rescue
        "Failed Info to wikify slideshare"
      end
      
      scraped_from = "http://www.slideshare.net"

      scraped_slideshow.name = name
      scraped_slideshow.description = description
      scraped_slideshow.url = slideshow_url
      scraped_slideshow.link = slideshow_url
      scraped_slideshow.scraped_from = scraped_from
      scraped_slideshow.persist(idiomas_disponibles,info_to_wikify,[])

    rescue Exception => e
      puts "Exception scrape_slideshow_slideshare"
      puts "Reintentamos dos veces, sino saltamos de slideshow"
      puts e.message
      puts e.backtrace.inspect
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_slideshow_slideshare(slideshow_url, photo_url, language, 1,reintentos)
      end
    end
  end


end
