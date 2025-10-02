module Redis
  module Helper
    def find_ip_of_master_node
      redis_ips = node['redborder']['cluster_info']
        .select { |m, _| node['redborder']['managers_per_services']['redis'].include?(m) }
        .map    { |_, v| v['ipaddress_sync'] }

      redis_ips.first
    end

    def get_cluster_info(redis_hosts)
      is_cluster = redis_hosts.length > 1
      master_host = is_cluster ? redis_hosts.first : nil
      master_ip = master_host ? find_ip_of_master_node : nil
      is_master_here = (master_host == node['hostname'])

      {
        is_cluster: is_cluster,
        master_host: master_host,
        master_ip: master_ip,
        is_master_here: is_master_here,
      }
    end
  end
end
