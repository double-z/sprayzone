package :ftp, :provides => :ftpserver do
  description 'Set up and enable FTP access'

  requires :learningcentre, :install_ftp, :set_ftpuser_directory
end

package :install_ftp do
  description "Install the FTP server"

  runner "aptitude -y install vsftpd"
  runner "service vsftpd restart"

  verify do
    has_apt "vsftpd"
  end
end

package :set_ftpuser_directory do
  description "Set the FTP directory for our FTP user"
  requires :install_ftp, :deployer

  runner "usermod -d /srv/www/learning/public_html #{FTP_USER}"
  
  verify do
    has_file "/srv/www/learning/public_html/index.html"
  end
end