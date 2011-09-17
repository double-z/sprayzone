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

  runner "service apache2 restart" # restart apache

  verify do
    has_apt "apache2-mpm-prefork"
  end
end

package :apache_virtual_host do
  description "Configures a VirtualHost for the website"
  requires :apache_tune

  virtualhost_content = ERB.new(File.read('assets/virtualhost_content.erb')).result

  runner "sudo rm /etc/apache2/sites-available/default" # LET'S REMOVE THE DEFAULT TO JUST BE A DICK
  push_text virtualhost_content, "/etc/apache2/sites-available/default" # and replace it with ours
  
  runner "sudo rm /etc/apache2/sites-available/#{APP_NAME}"
  push_text virtualhost_content, "/etc/apache2/sites-available/#{APP_NAME}"

  runner "mkdir -p /srv/www/#{APP_NAME}/public_html/" # create the public web root
  runner "mkdir -p /srv/www/#{APP_NAME}/logs" # create a place to put log files

  runner "a2ensite #{APP_NAME}"
  runner "a2enmod rewrite" # enable mod_rewrite
  runner "service apache2 restart" # restart apache

  verify do
    file_contains "/etc/apache2/sites-available/#{APP_NAME}", "DocumentRoot /srv/www/#{APP_NAME}/public_html/"
  end
  
end