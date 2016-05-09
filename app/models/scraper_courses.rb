# encoding: utf-8

require 'capybara/rails'
require "capybara"
require "capybara/dsl"

class ScraperCourses
  include ActionView::Helpers::SanitizeHelper
  include Capybara::DSL
  
  ###############################################################
  #######     SCRAPE_COURSERA
  ###############################################################
  
  def scrape_coursera (*reintentos)
    begin
      source_name = __method__.to_s    
      #Add new source, or select it if exists
      source = Source.create_or_select_source(source_name, "Course", "https://www.coursera.org/courses")
=begin            
      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end
      
      i=0
      array_courses = Array.new
      
      #pillamos todos los courses del json que aparece a continuacion, y metemos los nombres de los cursos
      #en un array para luego construir la url de cada curso, que será del tipo http://coursera.com/course/courses_names[i]
      
      url_json = "https://d1hpa2gdx2lr6r.cloudfront.net/maestro/api/topic/list2?unis=id%2Cname%2Cshort_name%2Cpartner_type%2Cfavicon%2Chome_link%2Cdisplay&topics=id%2Clanguage%2Cname%2Cshort_name%2Csubtitle_languages_csv%2Cself_service_course_id%2Csmall_icon_hover%2Clarge_icon%2Cshort_description&cats=id%2Cname%2Cshort_name&insts=id%2Cfirst_name%2Cmiddle_name%2Clast_name%2Cshort_name%2Cuser_profile__user__instructor__id&courses=id%2Cstart_day%2Cstart_month%2Cstart_year%2Cstatus%2Csignature_track_open_time%2Csignature_track_close_time%2Celigible_for_signature_track%2Cduration_string%2Chome_link%2Ctopic_id%2Cactive&__cf_version=dcb84056c91fda3cf54d03ea4d381f100ffca90d&__cf_origin=https%3A%2F%2Fwww.coursera.org"
      result = Nokogiri::HTML(open(url_json, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
      parsed_result = JSON.parse result

      courses = parsed_result['topics']
      
      reintentos = 2
      
      courses.each do |course|
        course = course[1]
        array_courses << {:short_name => course['short_name']}
      end
      
      array_courses.each do |course|
        scrape_course_coursera course
      end
=end      
      source.correct_scrape
    rescue  Exception => e
      puts "Exception in scrape_coursera"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_coursera(1,reintentos)
      end
      source.incorrect_scrape
    end
  end #scrape_coursera
  
 def scrape_course_coursera(course, *reintentos)
    begin    
      scraped_course = Course.new
      short_name = course[:short_name]
      course_url = "https://www.coursera.org/course/" + short_name
      idiomas_disponibles = Array.new     
      scraped_from = "https://www.coursera.org/courses"
      name = ""
      short_description = ""
      about_the_course = ""
      description = ""
      language = ""
      
      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end
      
      puts ""
      
      url_json = "https://www.coursera.org/maestro/api/topic/information?topic-id=" + short_name
      course_json = Nokogiri::HTML(open(url_json, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
      parsed_course_json = JSON.parse course_json
      reintentos = 2
      
      begin
        language = parsed_course_json['language']
        puts "Language: " + language
        idiomas_disponibles << language
      rescue
        puts "Failed language coursera"
      end
      
      begin
        name = parsed_course_json['name']
        #puts "Name: " + name
      rescue
        puts "Failed Name coursera"
      end
      
      begin
        short_description = strip_tags parsed_course_json['short_description']
      rescue
        puts "Failed short description coursera"
      end
      
      begin     
        about_the_course= strip_tags parsed_course_json['about_the_course']
      rescue
        puts "Failed Description coursera"
      end
      
      description = short_description + "\n" +  about_the_course
      #puts "La description es : " + description
      
      human_tags = Array.new
      begin
        categories = parsed_course_json['categories']
        categories.each do |category|
          human_tags << category['name']
        end      
      rescue
        puts "Failed Tags Coursera"
      end
      
      begin
        photo_url = parsed_course_json['photo']
        puts "photo_url: " + photo_url
      rescue
        puts "Failed Photo coursera"
        photo_url = nil
      end
      
      if photo_url!=nil
          begin
            a = URI.parse(photo_url)
            scraped_course.element_image=URI.parse(photo_url)
          rescue
            puts "coursera:  IMAGEN NO GUARDADA"
            scraped_course.element_image.clear
          end
        end
        
      I18n.locale = language
      scraped_course.name = name
      scraped_course.description = description      
      scraped_course.url = course_url
      scraped_course.link = course_url
      scraped_course.scraped_from = scraped_from
      prosa = name + ". " + description
      if language != "en"
        prosa = Translator.translate_bing_detect_language(prosa)
      end
      scraped_course.persist(idiomas_disponibles,prosa,human_tags)

    rescue Exception => e
      puts "Exception in scrape_coursera"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_course_coursera(course,1,reintentos)
      end
    end
  end  
  
  ###############################################################
  #######     SCRAPE_MIT
  ###############################################################
  
  
 def scrape_mit (*reintentos)
    begin
      source_name = __method__.to_s    
      #Add new source, or select it if exists
      source = Source.create_or_select_source(source_name, "Course", "http://ocw.mit.edu/courses/")

      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end
      
      i=0
      url = "http://ocw.mit.edu/courses/"
      page = Nokogiri::HTML(open(url))
      reintentos = 2

      page.css("table.courseList tbody tr td a").each_with_index do |course,index|
        if (index + 1) % 3 == 2 ## solo cogemos el segundo de cada 3 resultados
          puts i+=1
          scrape_course_mit "http://ocw.mit.edu" + course['href']
        end
      end
      source.correct_scrape
    rescue  Exception => e
      puts "Exception in scrape_mit"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_mit(1,reintentos)
      end
      source.incorrect_scrape
    end
  end #scrape_mit
  
  
  def scrape_course_mit(course_url, *reintentos)
    begin    
      scraped_course = Course.new
      human_tags = Array.new
      idiomas_disponibles = ["en"]    
      scraped_from = "http://ocw.mit.edu/courses/"
      name = ""
      description = ""
      puts course_url
            
      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end

      course_page = Nokogiri::HTML(open(course_url))
      reintentos = 2
           
      begin 
        name = course_page.css("div#course_title h1.title")[0].text.strip
        puts "Name: " + name
      rescue
        puts "Failed Name mit"
      end

      begin
        description = strip_tags course_page.css(" div#description.tabContent")[0].text
        description = description.split("Course Description")
        description = description[description.length-1].strip
        #puts "Description: "
        #puts description
      rescue
        puts "Failed description mit"
      end
      
      begin
        category = course_page.css("div#breadcrumb_chp p a")[2].text.strip
        human_tags << category
        course_page.css("div#related.tabContent div ul li a").each do |related_category|
          related_category = related_category.text.strip
          related_category = related_category.split(">")
          related_category.each do |tag|
            human_tags << tag.strip
          end
        end      
        #puts "human_tags: "
        #puts human_tags
      rescue Exception => e
        puts "Failed Tags mit"
        puts e.message
        puts e.backtrace.inspect
      end

      begin
        photo_url = "http://ocw.mit.edu" + course_page.css("div#chpImage div.image img")[0]['src']
        #puts "photo_url: " + photo_url
      rescue Exception => e
        puts "Failed Photo mit"
        puts e.message
        puts e.backtrace.inspect
        photo_url = nil
      end
      
      if photo_url!=nil
          begin
            a = URI.parse(photo_url)
            scraped_course.element_image=URI.parse(photo_url)
          rescue
            puts "mit:  IMAGEN NO GUARDADA"
            scraped_course.element_image.clear
          end
        end
        
      I18n.locale = "en"
      scraped_course.name = name
      scraped_course.description = description      
      scraped_course.url = course_url
      scraped_course.link = course_url
      scraped_course.scraped_from = scraped_from
      prosa = name + ". " + description
      prosa = prosa.gsub("&","")
      scraped_course.persist(idiomas_disponibles,prosa,human_tags)

    rescue Exception => e
      puts "Exception in scrape_course_mit"
      puts "Reintentamos dos veces, sino saltamos al siguiente curso"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_course_mit(course_url,1,reintentos)
      end
    end
  end  
  
  ###############################################################
  #######     SCRAPE_EDX
  ###############################################################
  
  
 def scrape_edx (*siguiente)
    begin
      source_name = __method__.to_s    
      #Add new source, or select it if exists
      source = Source.create_or_select_source(source_name, "Course", "https://www.edx.org")      
      
      if siguiente[1]==1
        reintentos = siguiente[2]
      else
        reintentos = 2
      end
      
      i=0
      url = "https://www.edx.org/course-list/allschools/allsubjects/allcourses"

      
      if siguiente[1]!=1
        page = Nokogiri::HTML(open(url))
        reintentos = 2
        page.css("div.view-content div.views-row div.col-left-courses div.top h2.title strong a").each do |course|
          scrape_course_edx course['href']
        end
      end
      
      if siguiente[1]!=1         
        siguiente = "https://www.edx.org" + page.css("div.view div.item-list ul.pager li.pager-next a")[0]['href']
      else
        siguiente = siguiente[0]
      end
      
      while siguiente != nil
        sleep 2
        puts "URL_SIGUIENTE --> " + siguiente
        page2 =  Nokogiri::HTML(open(siguiente))
        reintentos = 2

        page2.css("div.view-content div.views-row div.col-left-courses div.top h2.title strong a").each do |course|
          scrape_course_edx course['href']
        end

        if page2.css("div.view div.item-list ul.pager li.pager-next a").empty?
          siguiente = nil
        else
         siguiente = "https://www.edx.org" + page2.css("div.view div.item-list ul.pager li.pager-next a")[0]['href']
        end
      end
     
      source.correct_scrape
    rescue  Exception => e
      puts "Exception in scrape_edx"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_edx(siguiente,1,reintentos)
      end
      source.incorrect_scrape
    end
  end #scrape_edx
  
   
 def scrape_course_edx(course_url, *reintentos)
    begin
      scraped_course = Course.new
      human_tags = Array.new
      idiomas_disponibles = ["en"]
      scraped_from = "https://www.edx.org"
      name = ""
      subtitle = ""
      about_course = ""
      description = ""
      puts course_url

      if reintentos[0]==1
      reintentos = reintentos[1].to_i
      else
      reintentos = 2
      end

      course_page = Nokogiri::HTML(open(course_url))
      reintentos = 2

      begin
        name = course_page.css("div.course-section h2.course-detail-title")[0].text.strip
        puts "Name: " + name
      rescue
        puts "Failed Name edx"
      end

      begin
        subtitle = strip_tags course_page.css("div.course-section div.course-detail-subtitle")[0].text.strip
        about_course = strip_tags course_page.css("div.view div.view-content div div.course-section")[1].text.strip
        about_course = about_course.gsub("About this Course","")
        description = subtitle + "\n" + about_course
        #puts description
      rescue
        puts "Failed description edx"
      end

      begin
        photo_url = course_page.css("div.view-content div div.course-detail-image img")[0]['src']
        #relaxputs "photo_url: " + photo_url
      rescue Exception => e
        puts "Failed Photo edx"
      end

      if photo_url!=nil
        begin
          a = URI.parse(photo_url)
          scraped_course.element_image=URI.parse(photo_url)
        rescue
          puts "edx:  IMAGEN NO GUARDADA"
        scraped_course.element_image.clear
        end
      end

      prosa = name + ". " + description
      
      I18n.locale = "en"
      scraped_course.name = name
      scraped_course.description = description
      scraped_course.url = course_url
      scraped_course.link = course_url
      scraped_course.scraped_from = scraped_from

      language = Translator.bing_detect_language(prosa)

      if language.to_s == "en"
        scraped_course.persist(idiomas_disponibles,prosa,human_tags)
      end

    rescue Exception => e
      puts "Exception in scrape_course_edx"
      puts "Reintentamos dos veces, sino saltamos al siguiente curso"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_course_edx(course_url,1,reintentos)
      end
    end
  end


  
  
  
  
end #class