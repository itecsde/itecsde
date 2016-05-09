# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


set :output, "~/scraper_sources_cron.log"
every 4.hours do
  path_project = "/var/www/itec-sde-v1/"
  script = "scraper_sources_cron.rb"
  #entorno = "development"
  #command "RAILS_ENV=development rails r ~/Documents/Aptana \Studio 3 Workspace/iTEC-SDE/script/scraper_visitbudapest.rb"
  #command "/usr/local/bin/ruby ~/prueba_cron.rb"
  #command "export GEM_PATH='/home/marcos/ruby/gems:/usr/local/lib/ruby/gems/1.8'" 
  #command "export GEM_HOME='/home/marcos/ruby/gems'"
  #command "cd ~/Documents/Aptana' 'Studio' '3' 'Workspace/iTEC-SDE/"
  #command "cd " + path_project + "  && /usr/local/bin/rails runner " + path_project + "script/" + script + " RAILS_ENV=" + entorno
  command "cd " + path_project + "  && RAILS_ENV=production /usr/local/bin/rails r script/" + script
  #esta a continuacion es la que funciona
  #command "cd ~/Documents/Aptana' 'Studio' '3' 'Workspace/iTEC-SDE/  && /usr/local/bin/rails runner ~/Documents/Aptana' 'Studio' '3' 'Workspace/iTEC-SDE/script/threaded_scraper.rb RAILS_ENV=development"
  #runner "cd ~/Documents/Aptana' 'Studio' '3' 'Workspace/iTEC-SDE/  && /usr/local/bin/rails runner -e development 'script/scraper_visitbudapest' :output" 
end
