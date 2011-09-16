package :init, :provides => :initialize do
  description 'Gets things ready for building'
  
  requires :remove_authorized_keys
end

package :remove_authorized_keys do
  description "Remove the host from local authorized_keys"
  `ssh-keygen -R "#{HOSTIP}"`
end