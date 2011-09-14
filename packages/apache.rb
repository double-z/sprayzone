package :apache_install, :provides => :webserver do

  requires :apache_core, :apache_ports
  
end

package :apache_core do
  runner "aptitude -y install apache2"
  runner "a2dissite default" # disable the interfering default virtualhost
  runner "sed -i -e 's/^NameVirtualHost \*$/NameVirtualHost *:80/' /etc/apache2/ports.conf"
  
  verify do
    has_executable 'apache2'
  end
end

package :apache_ports do
  requires :apache_core
  
  runner "echo 'NameVirtualHost *:80' > /etc/apache2/ports.conf.tmp"
  runner "cat /etc/apache2/ports.conf >> /etc/apache2/ports.conf.tmp"
  runner "mv -f /etc/apache2/ports.conf.tmp /etc/apache2/ports.conf"
  
  verify do
    file_contains '/etc/apache2/ports.conf', 'NameVirtualHost'
  end
end