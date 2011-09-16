$: << File.dirname(__FILE__)

require 'config'
require 'lib/verifiers'
require 'packages/update'
require 'packages/deploy'
require 'packages/init'
require 'packages/postfix'
require 'packages/mysql'
require 'packages/php'
require 'packages/apache'

policy :stack, :roles => :app do
  requires :initialize
  requires :system_update
  requires :deployer
  requires :mailserver
  requires :php
  requires :webserver
end

deployment do
  delivery :ssh do
    roles :app => HOSTIP
    user 'root'
    password ROOT_PASSWORD
  end

  source do
    prefix   '/usr/local'           # where all source packages will be configured to install
    archives '/usr/local/sources'   # where all source packages will be downloaded to
    builds   '/usr/local/build'     # where all source packages will be built
  end
end
