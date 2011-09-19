package :learning_centre, :provides => :learningcentre do
    requires :learning_centre_copy
end

package :learning_centre_copy do
  description "Copy the Learning Centre files to a directory"

  requires :webserver

  LEARNING_DIR="/srv/www/#{APP_NAME}/public_html/learning"

  runner "mkdir -p #{LEARNING_DIR}" # create a place for the Learning Centre files
  runner "rm #{LEARNING_DIR}/index.html" # remove the index if it was there before
  transfer "assets/learning-centre/index.html", "#{LEARNING_DIR}/index.html" # place the index from this repo in the dir
  transfer "assets/learning-centre/header.jpg", "#{LEARNING_DIR}/header.jpg" # place the header image from this repo in the dir

  verify do
    file_contains "#{LEARNING_DIR}/index.html", "Please login to view and register for courses."
  end
  
end