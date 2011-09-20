Update the config.rb file with your settings, it contains the application-wide constants such as host IP address, root password, and anything else you wish to store. 

By default this script will attempt to install wordpress and some content for the learning centre. You can comment either or both of these lines out of the setup.rb file.
  
Also take a look at the ssh connection info at the bottom of the setup.rb file as well.

##Instructions
    
    bundle install
    bundle exec sprinkle -v -c -s setup.rb
