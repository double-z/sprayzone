package :php_install, :provides => :php do

  requires :php_install_with_php_apache_module
  
end

package :php_install_with_php_apache_module do
  description "Installs PHP5 as well as the PHP Apache module"

  runner "aptitude -y install php5 php5-mysql"
  runner "aptitude -y install libapache2-mod-php5"
  runner "service apache restart"

  verify do
    has_apt "libapache2-mod-php5"
  end
end