# encoding: utf-8

require 'capybara/rails'
require "capybara"
require "capybara/dsl"

class ScraperImagesBlogs
  include ActionView::Helpers::SanitizeHelper
  include Capybara::DSL
  def scrape_images_blogs
    begin
      blogs_without_image = Blog.all
      blogs_without_image.each do |blog|
        blog_page = Nokogiri::HTML(open(blog.scraped_from))
        image_matches = blog_page.css("img")
        photo_url = first_big_image(blog.scraped_from,image_matches,blog_page)
        puts "IMAGE_URL: " + photo_url
        if photo_url!=nil
          begin
            blog.element_image = URI.parse(photo_url)
          rescue
            puts "scraper_images_blogs:  IMAGEN NO GUARDADA"
            blog.element_image.clear
          end
        end
        blog.save
      end     
    rescue Exception => e
      puts "Failed scrape_image_blogs"
      puts e.message
      puts e.backtrace.inspect
    end
  end
     
  def first_big_image(blog_url, image_matches, blog_page)
    image_url = nil
    image_matches.each do |match|
      dummy_blog = Blog.new
      
      
      blog_page.at_css("body").traverse do |node|
        puts n
      end
      # Builds the URL
      url = match['src']
      if !match['src'].include? "http://"
        url = "http://" + URI.parse(blog_url).host + match['src']
      end
      # Parses it
      dummy_blog.element_image = URI.parse(url)
      # Assigns the return value if the image is bigger than 2k
      if dummy_blog.element_image.size > 2000
        image_url = url
        break
      end
    end
    return image_url
  end
  
  
end