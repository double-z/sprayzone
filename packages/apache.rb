package :apache_install, :provides => :webserver do

  requires :apache_core, :apache_ports, :apache_tune, :apache_virtual_host
  
end

package :apache_core do
  description "Install Apache"

  runner "aptitude -y install apache2"
  runner "a2dissite default" # disable the interfering default virtualhost
  runner "sed -i -e 's/^NameVirtualHost \*$/NameVirtualHost *:80/' /etc/apache2/ports.conf"
  
  verify do
    has_executable 'apache2'
  end
end

package :apache_ports do
  description "Clean up, or add the NameVirtualHost line to ports.conf"
  requires :apache_core
  
  runner "echo 'NameVirtualHost *:80' > /etc/apache2/ports.conf.tmp"
  runner "cat /etc/apache2/ports.conf >> /etc/apache2/ports.conf.tmp"
  runner "mv -f /etc/apache2/ports.conf.tmp /etc/apache2/ports.conf"
  
  verify do
    file_contains '/etc/apache2/ports.conf', 'NameVirtualHost'
  end
end

package :apache_tune do
  description "Tune Apache's memory to use the percentage of RAM you specify, defaulting to 40%"
  requires :apache_ports
  
  commands = [ "PERCENT=40",
               "aptitude -y install apache2-mpm-prefork",
               "PERPROCMEM=10",
               "MEM=$(grep MemTotal /proc/meminfo | awk '{ print int($2/1024) }')",
               "MAXCLIENTS=$((MEM*PERCENT/100/PERPROCMEM))",
               "MAXCLIENTS=${MAXCLIENTS/.*}",
               "sed -i -e 's/\(^[ \t]*MaxClients[ \t]*\)[0-9]*/\1$MAXCLIENTS/' /etc/apache2/apache2.conf" ]
               
  runner commands.join '; '

  runner "touch /tmp/restart-apache2"
  
  verify do
    has_apt "apache2-mpm-prefork"
  end
end

package :apache_virtual_host do
  description "Configures a VirtualHost for the website"
  requires :apache_tune
  
  virtualhost_content = "<VirtualHost *:80>
                                ServerName #{APPNAME}
                                DocumentRoot /srv/www/#{APPNAME}/public_html/
                                ErrorLog /srv/www/#{APPNAME}/logs/error.log
                                CustomLog /srv/www/#{APPNAME}/logs/access.log combined
                            </VirtualHost>"
  
  push_text virtualhost_content, "/etc/apache2/sites-available/#{APPNAME}"

  runner "a2ensite #{APPNAME}" 
  runner "touch /tmp/restart-apache2"
  
  verify do
    file_contains "/etc/apache2/sites-available/#{APPNAME}", virtualhost_content
  end
  
end