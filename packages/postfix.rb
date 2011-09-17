package :postfix_install, :provides => :mailserver do

  requires :postfix_install, :postfix_loopback_only
  
end

package :postfix_install do
  description "Installs Postfix, a mail server"
  
  runner "echo 'postfix postfix/main_mailer_type select Internet Site' | debconf-set-selections"
  runner "echo 'postfix postfix/mailname string localhost' | debconf-set-selections"
  runner "echo 'postfix postfix/destinations string localhost.localdomain, localhost' | debconf-set-selections"
  runner "aptitude -y install postfix"

  verify do
    has_apt "postfix"
  end
end

package :postfix_loopback_only do
  description "Configure Postfix to listen only on the local interface. Also allows for local mail delivery"
  requires :postfix_install
  
  runner "/usr/sbin/postconf -e 'inet_interfaces = loopback-only'"
  runner "service postfix restart" # restart postfix
  
  verify do
    file_contains '/usr/sbin/postconf', 'inet_interfaces'
  end
end