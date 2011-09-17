package :wordpress_install, :provides => :wordpress do

  requires :wordpress_core

end

package :wordpress_core do
  description "Install Wordpress"

  requires :webserver, :php, :database

  PUBLIC_ROOT="/srv/www/#{APP_NAME}/public_html" # path to DocumentRoot
  WORDPRESS_ROOT="#{PUBLIC_ROOT}/wordpress"

  runner "aptitude -y install wget"

  # download, extract, chown, and get our config file started
  runner "cd #{PUBLIC_ROOT}; wget http://wordpress.org/latest.tar.gz; tar xfz latest.tar.gz"
  runner "chown -R www-data: #{WORDPRESS_ROOT}/"
  runner "mkdir -p #{WORDPRESS_ROOT}"
  runner "cd #{WORDPRESS_ROOT}"
  runner "cp #{WORDPRESS_ROOT}/wp-config-sample.php  #{WORDPRESS_ROOT}/wp-config.php"
  runner "chown www-data  #{WORDPRESS_ROOT}/wp-config.php"
  runner "chmod 640  #{WORDPRESS_ROOT}/wp-config.php"

  runner "echo 'CREATE DATABASE wordpress;' | mysql -u root -p#{MYSQL_ROOT_PASSWORD}"
  runner %{echo "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '#{WORDPRESS_DATABASE_PASSWORD}';" | mysql -u root -p#{MYSQL_ROOT_PASSWORD}}

  runner %{echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';" | mysql -u root -p#{MYSQL_ROOT_PASSWORD}}
  runner "echo 'FLUSH PRIVILEGES;' | mysql -u root -p#{MYSQL_ROOT_PASSWORD}"

  wordpress_config = ERB.new(File.read('assets/wp-config.php.erb')).result

  runner "rm  #{WORDPRESS_ROOT}/wp-config.php"
  push_text wordpress_config, "#{WORDPRESS_ROOT}/wp-config.php"

  verify do
    file_contains "#{WORDPRESS_ROOT}/wp-config.php", "#{WORDPRESS_DATABASE_PASSWORD}"
  end
end