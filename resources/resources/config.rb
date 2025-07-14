# Cookbook:: redis
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'redis'
attribute :group, kind_of: String, default: 'redis'
