# Cookbook:: redis
# Provider:: config

action :add do
  begin


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
      query['Address'] = "#{node['ipaddress_sync']}"
      query['Port'] = 6379
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
