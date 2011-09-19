package :learning_centre, :provides => :learningcentre do
    requires :learning_centre_copy
end

package :learning_centre_copy do
  description "Copy the Learning Centre files to a directory"

  requires :webserver

  PUBLIC_ROOT="/srv/www/#{APP_NAME}/public_html" # path to DocumentRoot
  
  learningcentre_content = ERB.new(File.read('assets/learning-centre/index.html')).result
  
  runner "mkdir -p #{PUBLIC_ROOT}/learning" # create a place for the Learning Centre files
  push_text learningcentre_content, "#{PUBLIC_ROOT}/learning/index.html"
  
  
  # NEED TO PUSH HEADER IMAGE AS WELL
  # NEED TO VERIFY THE FILE IS THERE (CONTAINS)
  
  verify do
    file_contains "#{PUBLIC_ROOT}/learning/index.html", "Please login to view and register for courses."
  end
  
end