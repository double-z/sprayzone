package :php_install, :provides => :php do

  requires :php_install_with_php_apache_module, :php_tune
  
end


package :php_install_with_php_apache_module do
  description "Installs PHP5 as well as the PHP Apache module"

  runner "aptitude -y install php5 php5-mysql libapache2-mod-php5"
  runner "touch /tmp/restart-apache2"

  verify do
    has_apt "libapache2-mod-php5"
  end
end

package :php_tune do
  description "Tunes PHP to use up to 32MB per process"
  requires :php_install_with_php_apache_module
  
  runner "sed -i'-orig' 's/memory_limit = [0-9]\+M/memory_limit = 32M/' /etc/php5/apache2/php.ini"
  runner "touch /tmp/restart-apache2"
  
  verify do
    file_contains '/etc/php5/apache2/php.ini', '32M'
  end
end