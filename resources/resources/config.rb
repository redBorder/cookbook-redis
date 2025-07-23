# Cookbook:: redis
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'redis'
attribute :group, kind_of: String, default: 'redis'
attribute :redis_hosts, kind_of: Array, default: []
attribute :redis_secrets, kind_of: Hash, default: {}

# Redis configuration attributes
attribute :redis_dir, kind_of: String, default: '/etc/redis'
attribute :data_dir, kind_of: String, default: '/var/lib/redis'
attribute :log_file, kind_of: String, default: '/var/log/redis/redis.log'
attribute :pid_file, kind_of: String, default: '/var/run/redis/redis.pid'

# Sentinel configuration attributes
attribute :sentinel_data_dir, kind_of: String, default: '/var/lib/redis/sentinel'
attribute :sentinel_log_file, kind_of: String, default: '/var/log/redis/redis-sentinel.log'
attribute :sentinel_pid_file, kind_of: String, default: '/var/run/redis/redis-sentinel.pid'
