# encoding: utf-8

require 'capybara/rails'
require "capybara"
require "capybara/dsl"
require 'feedjira'

class ScraperBlogs
  include ActionView::Helpers::SanitizeHelper
  include Capybara::DSL
  
  ###############################################################
  #######  SCRAPE_BOTW (BETS OF DE THE WEB BLOGS)
  ###############################################################

  def scrape_botw(*reintentos)
    begin

      if reintentos[0]==1
        reintentos = reintentos[1].to_i
      else
        reintentos = 2
      end
      
      i=0
      url = "http://blogs.botw.org/"   
      page = Nokogiri::HTML(open(url))
          
      page.css("div.categories-holder ul.category-list li.category").each do |category|
        if category.css("a")[0]['href'] == "/Science/"
          category_page = Nokogiri::HTML(open("http://blogs.botw.org" + category.css("a")[0]['href']))
          puts category.css("a")[0]['href']
          if !category_page.css(".categories-empty li a").empty?
            puts "tiene subcategorias"
            category_page.css(".categories-empty li a").each do |subcategory|
              subcategory_page = Nokogiri::HTML(open("http://blogs.botw.org" + subcategory['href']))
              if !subcategory_page.css(".categories-empty li a").empty?
                puts "Buscar si hay mas categorias"
              else
                puts "No hay subcategorias, escrapeamos blogs"
                subcategory_page.css("div#Listings.listings div.listing p a img").each do |blog|
                  puts i+=1
                  scrape_rss_feed blog['alt'], "Post"
                end
                #y miramos si hay subcategorias en sidebar, hasta profundidad de nivel 1 (seguir mirando como hacer para profundidad de nivel 2)
                if !subcategory_page.css("div#ShowSpecificCategory1_SideBarTopLevelCategoriesPanel ul li a").empty?
                  subcategory_page.css("div#ShowSpecificCategory1_SideBarTopLevelCategoriesPanel ul li a").each do |subcategory_sidebar|
                    subcategory_sidebar_page = Nokogiri::HTML(open("http://blogs.botw.org" + subcategory_sidebar['href']))
                    subcategory_page.css("div#Listings.listings div.listing p a img").each do |blog|
                      puts i+=1
                      scrape_rss_feed blog['alt'], "Post"
                    end
                  end
                end
                if !subcategory_page.css("div#ShowSpecificCategory1_SideBarMidLevelCategoriesPanel ul li a").empty?
                  subcategory_page.css("div#ShowSpecificCategory1_SideBarMidLevelCategoriesPanel ul li a").each do |subcategory_sidebar|
                    subcategory_sidebar_page = Nokogiri::HTML(open("http://blogs.botw.org" + subcategory_sidebar['href']))
                    subcategory_page.css("div#Listings.listings div.listing p a img").each do |blog|
                      puts i+=1
                      scrape_rss_feed blog['alt'], "Post"
                    end
                  end
                end
                if !subcategory_page.css("div#ShowSpecificCategory1_SideBarBottomLevelCategoriesPanel ul li a").empty?
                  subcategory_page.css("div#ShowSpecificCategory1_SideBarBottomLevelCategoriesPanel ul li a").each do |subcategory_sidebar|
                    subcategory_sidebar_page = Nokogiri::HTML(open("http://blogs.botw.org" + subcategory_sidebar['href']))
                    subcategory_page.css("div#Listings.listings div.listing p a img").each do |blog|
                      puts i+=1
                      scrape_rss_feed blog['alt'], "Post"
                    end
                  end
                end
              end
            end
          else
            puts "no tiene subcategorías, escrapeamos blogs"
            category_page.css("div#Listings.listings div.listing p a img").each do |blog|
              puts i+=1
             scrape_rss_feed blog['alt'], "Post"
            end
            #y miramos si hay subcategorias en sidebar, hasta profundidad de nivel 1
            if !category_page.css("div#ShowSpecificCategory1_SideBarTopLevelCategoriesPanel ul li a").empty?
              category_page.css("div#ShowSpecificCategory1_SideBarTopLevelCategoriesPanel ul li a").each do |subcategory_sidebar|
                subcategory_page = Nokogiri::HTML(open("http://blogs.botw.org" + subcategory_sidebar['href']))
                subcategory_page.css("div#Listings.listings div.listing p a img").each do |blog|
                  puts i+=1
                  scrape_rss_feed blog['alt'], "Post"
                end
              end
            end
          end
        end #if Science
      end              
    rescue  Exception => e
      puts "Exception in scrape_botw"
      puts "Reintentamos dos veces, sino abortamos"
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos-=1
        sleep 2
        scrape_botw(1,reintentos)
      end
    end
  end #scrape_botw

=begin  
  def scrape_rss_blog(rss_feed, *reintentos)
    begin   
      puts "RSS FEED " 
      puts rss_feed
      puts "FIN RSS FEED"
      idiomas_disponibles = []
      
      if reintentos[0]==1
        reintentos = reintentos[1].to_i
      else
        reintentos = 2
      end
      
      post_summary = ""
      post_content = ""
      human_tags = Array.new

      scraped_blog = Blog.new
      
      # Reads the feed
      feed = Feedjira::Feed.fetch_and_parse(rss_feed,{ :max_redirects => 3 })
      html_page = Nokogiri::HTML(open(rss_feed))
      
      begin
        blog_name = feed.title
        blog_description = feed.description
        blog_image = html_page.css("image url").text.strip
        blog_language = html_page.css("language").text.strip.split("-")[0]
        puts blog_language
        idiomas_disponibles << blog_language
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      
      # If Blog doesn't exist, gets the name and description of the blog and saves it
      # If Blog exists, find it, and uses it for associate his posts 
      if Blog.find_by_name(blog_name)!=nil      
        scraped_blog = Blog.find_by_name(blog_name)       
      else
        scraped_blog = Blog.new
        scraped_blog.name = blog_name
        scraped_blog.description = blog_description
        scraped_blog.rss_feed = rss_feed
        scraped_blog.scraped_from = "http://" + URI.parse(rss_feed).host
        scraped_blog.save
      end         

      # Retrieves the posts, extracts the info, and saves them
      source_name = feed.title   
      #Add new source, or select it if exists
      source = Source.create_or_select_source(source_name, "Post", rss_feed)
      begin
        if blog_image != nil          
          source.element_image = URI.parse(blog_image)
          source.save
        end
      rescue
      end
      post_name = ""
      info_to_wikify = ""    
      post_summary = ""
      post_content = ""       
      feed.entries.each do |post|
      begin
        scraped_post = Post.new
        begin
          post_name = post.title.strip
          post_summary = strip_tags post.summary
          post_content = strip_tags post.content
          post_url = post.url
          post_publication_date = post.published
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
             
        return_values = extract_info_from_post(post_url, post_name)
        image_url = return_values[:image_url]
        info_to_wikify = return_values[:info_to_wikify]

        if image_url != nil          
          scraped_post.element_image = URI.parse(image_url)
        end
        
        I18n.locale = idiomas_disponibles[0]      
        scraped_from = rss_feed
        #post_description = post_summary + post_content
        scraped_post.name = post_name
        scraped_post.description = info_to_wikify
        scraped_post.publication_date = post_publication_date
        scraped_post.url = post_url
        scraped_post.link = post_url
        scraped_post.blog_id = scraped_blog.id
        scraped_post.info_to_wikify = post_name + info_to_wikify
        scraped_post.scraped_from = scraped_from
        scraped_post.persist(idiomas_disponibles,scraped_post.info_to_wikify,[])  
      rescue Exception => e
        puts "Failed Post"
        puts e.message
        puts e.backtrace.inspect
      end
    end 
    source.correct_scrape
    rescue  Exception => e
      puts e.backtrace.inspect
      puts e.message
      if reintentos > 0
        puts reintentos
        reintentos -= 1
        sleep 2
        scrape_rss_blog(rss_feed, 1, reintentos)
      end
      source.incorrect_scrape
    end   
  end #scrape_rss_blog
  
    def extract_info_from_post(post_url, post_title)
    return_values = Hash.new
    puts post_url
    puts post_title
    # Builds post object
    post_html = open(post_url,"User-Agent" => "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0").read
    post_html.gsub!("\n", "")
    post_object = Nokogiri::HTML(post_html)      
    # Cleans it
    post_object.at_css("body").traverse do |node|
      if node.text?
        node.content = node.content.gsub("\r", "")
        node.content = node.content.gsub("\n", "")
        node.content = node.content.gsub("\t", "")
        node.content = node.content.strip
      end
    end
    post_object.encoding = 'UTF-8'
    
    begin     
    # Finds nodes that contain post_title
    post_title_matches = post_object.css("body")[0].search('[text()="' + post_title.strip + '"]')
    rescue Exception => e
      puts "Failed matches post title"
      puts e.message
      puts e.backtrace.inspect
    end

    # Gets the most suitable node
    best_match = post_title_matches[0]
    puts best_match
    if post_title_matches[0].parent.name == "li" or post_title_matches[0].parent.parent.name == "li" or post_title_matches[0].parent.parent.parent.name == "li" 
      best_match = post_title_matches[1]
    end

    # Extracts a representative image and the content of the post
    if best_match != nil
      if !best_match.parent.css("img").empty?
        # Gets an array of images
        image_matches = best_match.parent.css("img")
        # Gets the first image with size higher than 2k
        image_url = first_big_image(post_url, image_matches)
        info_to_wikify = ""
        best_match.parent.css("p").each do |parrafo|
          if parrafo['class'] == nil          
            info_to_wikify = info_to_wikify + parrafo.text
          end
        end
      end
      if image_url == nil
        if !best_match.parent.parent.css("img").empty?
          # Gets an array of images
          image_matches = best_match.parent.parent.css("img")
          # Gets the first image with size higher than 2k
          image_url = first_big_image(post_url, image_matches)
          info_to_wikify = ""
          best_match.parent.parent.css("p").each do |parrafo|
            if parrafo['class'] == nil            
              info_to_wikify = info_to_wikify + parrafo.text
            end
          end
        end
        if image_url == nil
          if !best_match.parent.parent.parent.css("img").empty?
            # Gets an array of images
            image_matches = best_match.parent.parent.parent.css("img")
            info_to_wikify = strip_tags best_match.parent.parent.parent.text.gsub(/\n/," ").gsub(/\s+/,' ').gsub("&"," ").gsub("%"," ")
            # Gets the first image with size higher than 2k
            image_url = first_big_image(post_url, image_matches)
            info_to_wikify = ""
            best_match.parent.parent.parent.css("p").each do |parrafo|
              if parrafo['class'] == nil              
                info_to_wikify = info_to_wikify + parrafo.text
              end
            end
          end
        end
      end
      if info_to_wikify == "" or info_to_wikify == nil
        info_to_wikify = ""
        best_match.parent.css("p").each do |parrafo|
          if parrafo['class'] == nil
            info_to_wikify = info_to_wikify + parrafo.text
          end
        end
      end
      if info_to_wikify == "" or info_to_wikify == nil
        info_to_wikify = ""
        best_match.parent.parent.css("p").each do |parrafo|
          if parrafo['class'] == nil          
            info_to_wikify = info_to_wikify + parrafo.text
          end
        end
      end
      if info_to_wikify == "" or info_to_wikify == nil
        info_to_wikify = ""
        best_match.parent.parent.parent.css("p").each do |parrafo|
          if parrafo['class'] == nil
            info_to_wikify = info_to_wikify + parrafo.text
          end
        end
      end         
    end
    return_values = {:image_url => image_url, :info_to_wikify => info_to_wikify}
  end
  
  def extract_info_from_post(post_url, post_title)
    return_values = Hash.new
    puts post_url
    puts post_title
    # Builds post object
    post_html = open(post_url).read
    post_html.gsub!("\n", "")
    post_object = Nokogiri::HTML(post_html)
    
    # Cleans it
    post_object.at_css("body").traverse do |node|
      if node.text?
        node.content = node.content.gsub("\r", "")
        node.content = node.content.gsub("\n", "")
        node.content = node.content.gsub("\t", "")
        node.content = node.content.strip
      end
    end
    post_object.encoding = 'UTF-8'
    
    begin     
    # Finds nodes that contain post_title
    post_title_matches = post_object.css("body")[0].search('[text()="' + post_title.strip + '"]')
    rescue Exception => e
      puts "Failed matches post title"
      puts e.message
      puts e.backtrace.inspect
      if e.message.include? "unexpected"
        puts "entro por aqui"
        post_title_matches = post_object.css("body")[0].search("[text()='" + post_title.strip + "']")
        puts "salgo por aqui"
      end
    end

    # Gets the most suitable node
    best_match = post_title_matches[0]
    if post_title_matches[0].parent.name == "li"
      best_match = post_title_matches[1]
    end

    # Extracts a representative image and the content of the post
    if best_match != nil
      if !best_match.parent.css("img").empty?
        # Gets an array of images
        image_matches = best_match.parent.css("img")
        # Gets the first image with size higher than 2k
        image_url = first_big_image(post_url, image_matches)
        info_to_wikify = strip_tags best_match.parent.text.gsub(/\n/," ").gsub(/\s+/,' ').gsub("&"," ").gsub("%"," ")
      end
      if image_url == nil
        if !best_match.parent.parent.css("img").empty?
          # Gets an array of images
          image_matches = best_match.parent.parent.css("img")
        end
        # Gets the first image with size higher than 2k
        image_url = first_big_image(post_url, image_matches)
        info_to_wikify = strip_tags best_match.parent.parent.text.gsub(/\n/," ").gsub(/\s+/,' ').gsub("&"," ").gsub("%"," ")
      end          
    end
    
    return_values = {:image_url => image_url, :info_to_wikify => info_to_wikify}
  end

  # Gets the first image with size higher than 2k
  def first_big_image(post_url, image_matches)
    image_url = nil
    image_matches.each do |match|
      dummy_post = Post.new
      # Builds the URL
      url = match['src']
      if !match['src'].include? "http://"
        url = "http://" + URI.parse(post_url).host + match['src']
      end
      # Parses it
      dummy_post.element_image = URI.parse(url)
      # Assigns the return value if the image is bigger than 2k
      if dummy_post.element_image.size > 2000
        image_url = url
        break
      end
    end
    return image_url
  end
=end
end #class ScraperBlogs