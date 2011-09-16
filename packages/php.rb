package :php_install, :provides => :php do

  requires :php_install_with_php_apache_module
  
end


package :php_install_with_php_apache_module do
  description "Installs PHP5 as well as the PHP Apache module"

  runner "aptitude -y install php5 php5-mysql libapache2-mod-php5"
  runner "touch /tmp/restart-apache2"

  verify do
    has_apt "libapache2-mod-php5"
  end
end