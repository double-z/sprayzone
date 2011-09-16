package :mysql_install, :provides => :database do

  requires :mysql, :mysql_tune
  
end

package :mysql do
  description "Installs mysql database"

  commands = [
    "PERCENT=40",
    "echo 'mysql-server-5.1 mysql-server/root_password password MYSQLROOTPASSWORD' | debconf-set-selections",
    "echo 'mysql-server-5.1 mysql-server/root_password_again password MYSQLROOTPASSWORD' | debconf-set-selections",
    "apt-get -y install mysql-server mysql-client",
    "echo 'Sleeping while MySQL starts up for the first time...'",
    "sleep 5"]
               
  runner commands.join '; '
  
  verify do
    has_apt 'mysql-server'
  end
end

package :mysql_tune do
  description "Tunes MySQL's memory usage to utilize the percentage of memory you specify, defaulting to 40%"

  commands = [
    "PERCENT=40",
    "sed -i -e 's/^#skip-innodb/skip-innodb/' /etc/mysql/my.cnf # disable innodb - saves about 100M", 
    "MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)",
    "MYMEM=$((MEM*PERCENT/100))",
    "MYMEMCHUNKS=$((MYMEM/4))",
    "OPTLIST=(key_buffer sort_buffer_size read_buffer_size read_rnd_buffer_size myisam_sort_buffer_size query_cache_size)",
    "DISTLIST=(75 1 1 1 5 15)",
    "for opt in ${OPTLIST[@]}; do sed -i -e '/\[mysqld\]/,/\[.*\]/s/^$opt/#$opt/' /etc/mysql/my.cnf done",
    "for i in ${!OPTLIST[*]}; do val=$(echo | awk '{print int((${DISTLIST[$i]} * $MYMEMCHUNKS/100))*4}') if [ $val -lt 4 ] then val=4 fi config='${config}\n${OPTLIST[$i]} = ${val}M' done",
    "sed -i -e 's/\(\[mysqld\]\)/\1\n$config\n/' /etc/mysql/my.cnf"]
               
  runner commands.join '; '
  runner "touch /tmp/restart-mysql"

end