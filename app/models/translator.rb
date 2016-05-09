require 'wtf_lang'
require 'whatlanguage'
require 'capybara/rails'
require "capybara"
require "capybara/dsl"
# encoding: utf-8

class Translator
  def translate (text, translation_direction)
    result = RestClient.post 'http://www.xunta.es/tradutor/text.do', :text => '#b# ' + text + ' #e#', :subjectArea => '(GV)', :translationDirection => translation_direction    
    translation = result.scan(/#b# ([^>]*) #e#/).last.first    
  end
  
  
  def translate_xunta (text, translation_direction="ENGLISH-GALICIAN")
      begin
        result = RestClient.post 'http://www.xunta.es/tradutor/text.do', :text => text, :subjectArea => '(GV)', :translationDirection => translation_direction
        puts result       
        translation = result.scan(/writeTranslation\(\"([^>]*)\"\)\;/).last.first
        return translation
      rescue
        puts "No se pudo traducir al gallego"
        return text
      end
  end
  
  
  def translate_bing (text,from_language,to_language)
      available_languages = ["ar", "bg", "ca", "zh-CHS", "zh-CHT", "cs", "da", "nl", "en", "et", "fi", "fr", "de", "el", "ht", "he", "hi", "mww", "hu", "id", "it", "ja", "tlh", "tlh-Qaak", "ko", "lv", "lt", "ms", "m
  t", "no", "fa", "pl", "pt", "ro", "ru", "sk", "sl", "es", "sv", "th", "tr", "uk", "ur", "vi"]
      text_translate=""
      begin 
        if available_languages.include?(from_language) && available_languages.include?(to_language)
            bing_translator = BingTranslator.new('itec-sdeb510', 'Gy3JXxkxHJ/RvouagIf9hr7XX5cMonM3W7uze3ZiqaU=')
            text_translate = bing_translator.translate text, :from => from_language, :to => to_language
        else
          puts "translate_bing: Language not available"
        end
      rescue
        puts "translate_bing: Excepcion traduciendo"
        text_translate=text
      end
      return text_translate
  end 
  
  def translate_bing_through_url(text,from_language,to_language)
    begin
      url = "http://api.microsofttranslator.com/v2/ajax.svc/TranslateArray2?appId=%22TvgH5l9fTymIclpQz1HxvAr8wHl8rYt1qQ71as7UtrhloB607hyZ9aZJw2ZQgRThf%22&texts=[%22" + URI.encode(text) +
       "%22]&from=%22" + from_language + "%22&to=%22" + to_language + "%22&oncomplete=_mstc15&onerror=_mste15&loc=" + from_language + "&c" + to_language + "=&rgp=5ce42ef"   
      page = Nokogiri::HTML(open(url)) 
      texto = page.css("p").text  
      translated_text = texto.split('TranslatedText":"')[1].split('","TranslatedTextSentenceLengths"')[0]  
      return translated_text
    rescue
      puts "Exception translate_bing_without_api"
    end
  end
  
  
  def translate_all_tags    
    #available_languages=["de", "bg", "cs", "da", "sk", "sl", "es", "et", "fi", "fr", "el", "hu", "en", "it", "lv", "lt", "nl", "pl", "pt", "ro", "sv", "tr", "no", "gl"]
    available_languages=["hu", "tr", "nl", "lt", "no", "sk", "pt", "fi", "fr", "es", "gl"]
    Tag.all.each do |tag|      
        puts "Traduciendo tag="+Tag.name
        available_languages.each do |language|          
            I18n.locale="en"
            if language =="gl"
              text_translate=translate_xunta tag.name
              I18n.locale = language
              tag.name=text_translate                            
            else
              text_translate=translate_bing tag.name, "en", language
              I18n.locale = language
              tag.name=text_translate                            
            end          
        end
        tag.save!
        break        
    end    
  end 
  
  def self.translate_bing_detect_language (text,to_language="en")
      available_languages = ["ar", "bg", "ca", "zh-CHS", "zh-CHT", "cs", "da", "nl", "en", "et", "fi", "fr", "de", "el", "ht", "he", "hi", "mww", "hu", "id", "it", "ja", "tlh", "tlh-Qaak", "ko", "lv", "lt", "ms", "m
  t", "no", "fa", "pl", "pt", "ro", "ru", "sk", "sl", "es", "sv", "th", "tr", "uk", "ur", "vi"]
      text_translate=""
      begin 
        if available_languages.include?(to_language)
            bing_translator = BingTranslator.new('itec-sdeb510', 'Gy3JXxkxHJ/RvouagIf9hr7XX5cMonM3W7uze3ZiqaU=')
            text_translate = bing_translator.translate text, :to => to_language
        else
          puts "translate_bing: Language not available"
        end
      rescue
        puts "translate_bing: Excepcion traduciendo"
        text_translate=text
      end
      return text_translate
  end 
   
  def self.bing_detect_language (text,to_language="en")
      available_languages = ["ar", "bg", "ca", "zh-CHS", "zh-CHT", "cs", "da", "nl", "en", "et", "fi", "fr", "de", "el", "ht", "he", "hi", "mww", "hu", "id", "it", "ja", "tlh", "tlh-Qaak", "ko", "lv", "lt", "ms", "m
  t", "no", "fa", "pl", "pt", "ro", "ru", "sk", "sl", "es", "sv", "th", "tr", "uk", "ur", "vi"]
      begin 
        if available_languages.include?(to_language)
            bing_translator = BingTranslator.new('itec-sdeb510', 'Gy3JXxkxHJ/RvouagIf9hr7XX5cMonM3W7uze3ZiqaU=')
            language = bing_translator.detect text
        else
          puts "bing_detect_language: Language not available"
        end
      rescue
        puts "translate_bing: Excepcion detectando idioma"
        text_translate=text
      end
      return language
  end  
  
  
  def self.detect_language(text)
    begin
      WtfLang::API.key = "0546477544664b6dab1840b30e2f3263"
      return text.lang
    rescue
      puts "Exception detect_language"
    end
  end
  
  def self.detect_language_whatlanguage(text)
     begin
        return text.language
     rescue
        puts "Exception detect_language_whatlanguage"
     end
  end
   
  def translate_google_through_url(text)
     begin
         Capybara.register_driver :webkit do |app|
           Capybara::Selenium::Driver.new(app)
         end
         Capybara.javascript_driver = :webkit
         session = Capybara::Session.new(:webkit)   
        
        #text = URI.encode(text.gsub(/[^0-9a-z:,. ]/i, ' '))
        
        url = "https://translate.google.com/#es/en/" + text
        url = URI.encode(url)
        url = url.gsub("%23","#")
        
        session.visit(url)
        
        sleep 1
                              
        nokogiri_html_page = Nokogiri::HTML(session.body)        
        
        translation = nokogiri_html_page.css("span#result_box").text
        
        puts translation
        
        session.driver.browser.quit
        
        return translation
        
     rescue Exception => e
        puts "Exception translate_google_through_url (translator.rb)"
        puts e.message
        puts e.backtrace.inspect
     end
  end 
   
  def translate_google_through_url_sanitized(text)
     begin
        
         Capybara.register_driver :webkit do |app|
           Capybara::Selenium::Driver.new(app)
         end
         Capybara.javascript_driver = :webkit
         session = Capybara::Session.new(:webkit)   
         
           
        
        text = URI.encode(text.gsub(/[^0-9A-z ][:punct:][:word:]/i, ' '))
        
        url = "https://translate.google.com/#es/en/" + text
        url = URI.encode(url)
        url = url.gsub("%23","#")
        
        session.visit(url)
        
        sleep 1
                              
        nokogiri_html_page = Nokogiri::HTML(session.body)        
        
        translation = nokogiri_html_page.css("span#result_box").text
        
        puts translation
        
        session.driver.browser.quit
        
        return translation
        
     rescue Exception => e
        puts "Exception translate_google_through_url (translator.rb)"
        puts e.message
        puts e.backtrace.inspect
     end
  end    
   
                        
end