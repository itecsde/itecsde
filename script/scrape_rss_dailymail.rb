
wikipediator = Wikipediator.new

rss_feeds = [{:url_feed => "http://www.dailymail.co.uk/sport/index.rss", :section => wikipediator.complex_search_it("Sport")[0][:name]},
   {:url_feed => "http://www.dailymail.co.uk/health/index.rss", :section => wikipediator.complex_search_it("Health")[0][:name]},
   {:url_feed => "http://www.dailymail.co.uk/sciencetech/index.rss", :section => wikipediator.complex_search_it("Science")[0][:name]},
   {:url_feed => "http://www.dailymail.co.uk/money/index.rss", :section => wikipediator.complex_search_it("Economy")[0][:name]},
   {:url_feed => "http://www.dailymail.co.uk/femail/fashionfinder/index.rss", :section => wikipediator.complex_search_it("Fashion")[0][:name]},
   {:url_feed => "http://www.dailymail.co.uk/tvshowbiz/index.rss", :section => wikipediator.complex_search_it("ShowBusiness")[0][:name]}]
   
a=Scraper.new

rss_feeds.each do |rss|
   a.scrape_rss_feed(rss[:url_feed],"Report")
end
