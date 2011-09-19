package :wordpress_install, :provides => :wordpress do

  requires :wordpress_core, :wordpress_swap_config, :wordpress_supress_update_notifications

end

package :wordpress_core do
  description "Install Wordpress"

  requires :webserver, :php, :database

  APP_ROOT="/srv/www/#{APP_NAME}" # a level behind public
  WORDPRESS_ROOT="/srv/www/#{APP_NAME}/public_html" # where wordpress will install, essentially DocumentRoot

  runner "aptitude -y install wget"

  # Download, extract, and copy wordpress into a public location
  runner "cd #{APP_ROOT}; wget http://wordpress.org/latest.tar.gz; tar #{WORDPRESS_ROOT} -xfz latest.tar.gz"
#  runner "cd #{APP_ROOT}; cp -r wordpress/* #{WORDPRESS_ROOT}"
  
  # Remove our tarball and the private copy of the wordpress dir
  runner "rm #{APP_ROOT}/latest*"
#  runner "rm -rf #{APP_ROOT}/wordpress"

  # Let's set up a database for Wordpress to use
  runner "echo 'CREATE DATABASE wordpress;' | mysql -u root -p#{MYSQL_ROOT_PASSWORD}"
  runner %{echo "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '#{WORDPRESS_DATABASE_PASSWORD}';" | mysql -u root -p#{MYSQL_ROOT_PASSWORD}}
  runner %{echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';" | mysql -u root -p#{MYSQL_ROOT_PASSWORD}}
  runner "echo 'FLUSH PRIVILEGES;' | mysql -u root -p#{MYSQL_ROOT_PASSWORD}"

  verify do
    has_directory "#{WORDPRESS_ROOT}/wp-admin"
  end
end

package :wordpress_swap_config do
  description "Replace Wordpress' default config with our own"

  requires :wordpress_core

  wordpress_config = ERB.new(File.read('assets/wp-config.php.erb')).result

  runner "rm #{WORDPRESS_ROOT}/wp-config.php"
  push_text wordpress_config, "#{WORDPRESS_ROOT}/wp-config.php"

  verify do
    file_contains "#{WORDPRESS_ROOT}/wp-config.php", "#{WORDPRESS_DATABASE_PASSWORD}"
  end
end


package :wordpress_supress_update_notifications do
  description "Doesn't disable updates, but disables notification of updates"

  requires :wordpress_core

  WORDPRESS_THEME_FUNCTIONS="#{WORDPRESS_ROOT}/wp-content/themes/twentyeleven/functions.php"

  wordpress_functions = ERB.new(File.read('assets/wordpress_theme_functions.php')).result
  runner "rm  #{WORDPRESS_THEME_FUNCTIONS}"
  push_text wordpress_functions, "#{WORDPRESS_THEME_FUNCTIONS}"

  verify do
    file_contains "#{WORDPRESS_THEME_FUNCTIONS}", "pre_site_transient_update_core"
  end
end