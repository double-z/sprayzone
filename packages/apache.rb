package :apache_install, :provides => :webserver do

  requires :apache_core, :apache_ports, :apache_tune
  
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

# System updates already happen via :system_update, no need to add it again.

# configure apache virtualhost, with the reverse dns
# ALSO, postfix_install_loopback_only
#ALSO:
#  mysql_install "$DB_PASSWORD" && mysql_tune 40
#  mysql_create_database "$DB_PASSWORD" "$DB_NAME"
#  mysql_create_user "$DB_PASSWORD" "$DB_USER" "$DB_USER_PASSWORD"
#  mysql_grant_user "$DB_PASSWORD" "$DB_USER" "$DB_NAME"

# DO BEFORE APACHE:
#  php_install_with_apache && php_tune

# ALSO: 'goodstuff', restartServices, etc.