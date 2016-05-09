require "nokogiri"
require "open-uri"
require 'capybara/rails'
require "capybara"
require "capybara/dsl"
require 'watir-webdriver'
require 'net/http'
require 'net/https'
require 'uri'
require 'mechanize'
require 'csv'

class ScraperRae
   include ActionView::Helpers::SanitizeHelper
      
   #############################################
   ##                  RAE                    ##
   #############################################
   
   def insert_rae_word_list_into_database(filename)
      begin
         line_counter = 1
         File.open(filename,'r') do |file|
            while row = file.gets
               if line_counter != 1
                  row = row.split(" ")
                  order = row[0].gsub(".","").to_i
                  word = row[1]
                  absolute_frequency = row[2].gsub(",","").to_i
                  standardized_frequency = row[3].to_f
                  puts standardized_frequency
                  create_rae_word_database_entry(order, word, absolute_frequency, standardized_frequency)
               end
               line_counter += 1
            end
         end
      rescue Exception => e
         puts "Exception insert_rae_word_list_into_database"
         puts e.message
         puts e.backtrace.inspect 
      end
   end
   
   def create_rae_word_database_entry(order, word, absolute_frequency, standardized_frequency)
      begin
         rae_word_entry = RaeWord.new
         rae_word_entry.position = order
         rae_word_entry.word = word
         rae_word_entry.absolute_frequency = absolute_frequency       
         rae_word_entry.standardized_frequency = standardized_frequency
         rae_word_entry.save
      rescue Excepction => e
         puts "Exception create_raw_word_database_entry"
         puts e.message
         puts e.backtrace.inspect 
      end
   end
   
   def rae_frequency(filename)
      begin
         File.open(filename,'r') do |file|
            while row = file.gets
               list_name = row.split(':')[0].strip
               word_list = row.split(':')[1].strip.gsub('[','').gsub(']','').gsub("'",'')
               word_list = word_list.split(',')
               obtain_word_list_rae_frequency(word_list,list_name)
            end
         end
      rescue Exception => e
         puts "Exception rae_frequency"
         puts e.message
         puts e.backtrace.inspect 
      end
   end
   
   
   def obtain_word_list_rae_frequency(word_list, output_csv_file)
      begin
         table = Array.new
         word_array = ['word']
         csv_word_list = word_array + ['absolute_frequency','standardized_frequency']
         CSV.open("outputs_sonia/" + output_csv_file + "_rae.csv", "w") do |csv|
            csv << csv_word_list
         end
         word_list.each do |word|
            row = Array.new
            abs_freq, stand_freq = obtain_word_rae_frequency(word)
            row << word
            row << abs_freq
            row << stand_freq
            table << row
         end        
         CSV.open("outputs_sonia/" + output_csv_file + "_rae.csv", "a") do |csv|
            table.each do |row|
               csv << row
            end
         end

         text_file = File.read("outputs_sonia/" + output_csv_file + "_rae.csv")
         text_file = text_file.gsub(",",";")
         text_file = text_file.gsub(".",",")    
         File.open("outputs_sonia/" + output_csv_file + "_rae.csv","w") {|file| file.puts text_file}

      rescue Exception => e
         puts "Exception obtain_word_list_google_ngram_frequency"
         puts e.message
         puts e.backtrace.inspect
      end
   end   
   
   def obtain_word_rae_frequency(word)  
      begin              
         abs_freq = RaeWord.where('word="' + word + '" COLLATE utf8_bin')[0].absolute_frequency
         stand_freq = RaeWord.where('word="' + word + '" COLLATE utf8_bin')[0].standardized_frequency
         print word
         return abs_freq, stand_freq.to_f
      rescue Exception => e
         puts "Exception obtain_word_google_ngram_frequency"
         puts e.message
         puts e.backtrace.inspect     
      end     
   end   
end

