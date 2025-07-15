# Cookbook:: redis
# Provider:: config

include Redis::Helper

action :add do
  begin
    user = new_resource.user
    group = new_resource.group
    redis_dir = new_resource.redis_dir
    data_dir = new_resource.data_dir
    log_file = new_resource.log_file
    pid_file = new_resource.pid_file
    redis_hosts = new_resource.redis_hosts
    redis_secrets = new_resource.redis_secrets
    redis_password = redis_secrets['pass'] unless redis_secrets.empty?
    cluster_info = get_cluster_info(redis_hosts, node['hostname'])

    dnf_package 'redis' do
      action :upgrade
    end

    execute 'create_user' do
      command "/usr/sbin/useradd -r #{user} -s /sbin/nologin"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    directory redis_dir do
      owner user
      group group
      mode '0755'
    end

    directory data_dir do
      owner user
      group group
      mode '0755'
    end

    template "#{redis_dir}/redis.conf" do
      source 'redis.conf.erb'
      owner user
      group group
      mode '0644'
      variables(
        port: node['redis']['port'],
        password: redis_password,
        data_dir: data_dir,
        log_file: log_file,
        pid_file: pid_file,
        is_cluster: cluster_info[:is_cluster],
        master_host: cluster_info[:master_host],
        is_master_here: cluster_info[:is_master_here]
      )
      notifies :restart, 'service[redis]'
    end
    Chef::Log.info('Redis cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redis' do
      service_name 'redis'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    directory data_dir do
      recursive true
      action :delete
      ignore_failure true
    end

    directory redis_dir do
      recursive true
      action :delete
      ignore_failure true
    end

    file log_file do
      action :delete
      ignore_failure true
    end

    file pid_file do
      action :delete
      ignore_failure true
    end

    Chef::Log.info('Redis service has been removed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['redis']['registered']
      query = {}
      query['ID'] = "redis-#{node['hostname']}"
      query['Name'] = 'redis'
      query['Address'] = node['ipaddress_sync']
      query['Port'] = node['redis']['port']
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['redis']['registered'] = true
    end
    Chef::Log.info('Redis service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['redis']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/redis-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['redis']['registered'] = false
    end
    Chef::Log.info('Redis service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
