package :mysql_install, :provides => :database do

  requires :mysql, :mysql_tune
  
end

package :mysql do
  description "Installs mysql database"

  commands = [
    "echo 'mysql-server-5.1 mysql-server/root_password password #{MYSQLROOTPASSWORD}' | debconf-set-selections",
    "echo 'mysql-server-5.1 mysql-server/root_password_again password #{MYSQLROOTPASSWORD}' | debconf-set-selections",
    "apt-get -y install mysql-server mysql-client",
    "echo 'Sleeping while MySQL starts up for the first time...'",
    "sleep 5"]
               
  runner commands.join '; '
  
  verify do
    has_apt 'mysql-server'
  end
end


package :mysql_tune do
  description "Tunes MySQL's memory usage to utilize the percentage of memory you specify."

  mysql_config = `cat assets/my.cnf`
  
  runner "sudo rm /etc/mysql/my.cnf"
  push_text mysql_config, "/etc/mysql/my.cnf", :sudo => true

  runner "touch /tmp/restart-mysql"
  
  verify do
    file_contains "/etc/mysql/my.cnf", "myisam_sort_buffer_size=10M"
  end
end