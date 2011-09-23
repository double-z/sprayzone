package :learning_centre, :provides => :learningcentre do
    requires :learning_centre_enable, :learning_centre_copy
end

package :learning_centre_enable do
  description "Configures a virtualhost for the Learning Centre"
  
  requires :webserver
  
  virtualhost_content = ERB.new(File.read('assets/virtualhost_content_learning.erb')).result
  
  runner "sudo rm /etc/apache2/sites-available/learning" # Remove the learning virtualhost config if it's there
  push_text virtualhost_content, "/etc/apache2/sites-available/learning" # Replace it with the one in this script

  runner "mkdir -p /srv/www/learning/public_html/" # create a public web root for learning
  runner "mkdir -p /srv/www/learning/logs" # create a place to put the learning log files

  runner "a2ensite learning" # enables the learning virtualhost
  runner "service apache2 restart" # restart apache

  verify do
    file_contains "/etc/apache2/sites-available/learning", "DocumentRoot /srv/www/learning/public_html/"
  end
  
end

package :learning_centre_copy do
  description "Copy the Learning Centre files to a directory"

  requires :webserver, :learning_centre_enable

  LEARNING_DIR="/srv/www/learning/public_html"

  runner "mkdir -p #{LEARNING_DIR}" # create a place for the Learning Centre files
  runner "rm #{LEARNING_DIR}/index.html" # remove the index if it was there before
  transfer "assets/learning-centre/index.html", "#{LEARNING_DIR}/index.html" # place the index from this repo in the dir
  transfer "assets/learning-centre/header.jpg", "#{LEARNING_DIR}/header.jpg" # place the header image from this repo in the dir

  verify do
    file_contains "#{LEARNING_DIR}/index.html", "Please login to view and register for courses."
  end
  
end