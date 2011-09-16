package :wordpress_install, :provides => :wordpress do

  requires :wordpress_core
  
end

package :wordpress_core do
  description "Install Wordpress"
  
  requires :webserver, :php, :database
  
  VPATH="/srv/www/#{APPNAME}/public_html" # path to DocumentRoot
  WPROOT="#{VPATH}/wordpress"

  runner "aptitude -y install wget"
  
  # download, extract, chown, and get our config file started
  runner "cd #{VPATH}; wget http://wordpress.org/latest.tar.gz; tar xfz latest.tar.gz"
  runner "chown -R www-data: #{WPROOT}/"
  runner "mkdir -p #{WPROOT}"
  runner "cd #{WPROOT}"
  runner "cp #{WPROOT}/wp-config-sample.php  #{WPROOT}/wp-config.php"
  runner "chown www-data  #{WPROOT}/wp-config.php"
  runner "chmod 640  #{WPROOT}/wp-config.php"

  runner "echo 'CREATE DATABASE wordpress;' | mysql -u root -p#{MYSQLROOTPASSWORD}"
  runner %{echo "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '#{WPPASS}';" | mysql -u root -p#{MYSQLROOTPASSWORD}}
  
  runner %{echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';" | mysql -u root -p#{MYSQLROOTPASSWORD}}
  runner "echo 'FLUSH PRIVILEGES;' | mysql -u root -p#{MYSQLROOTPASSWORD}"
  
  wordpress_config = ERB.new(File.read('assets/wp-config.php.erb')).result
  
  # wordpress_config = `cat assets/wp-config.php.erb`
  
  runner "rm  #{WPROOT}/wp-config.php"
  push_text wordpress_config, "#{WPROOT}/wp-config.php"

  verify do
    file_contains "#{WPROOT}/wp-config.php", "#{WPPASS}"
  end
end