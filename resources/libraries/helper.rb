module Redis
  module Helper
    def get_cluster_info(redis_hosts, this_node)
      is_cluster = redis_hosts.length > 1
      master_host = is_cluster ? redis_hosts.first : nil
      is_master_here = (master_host == this_node)

      {
        is_cluster: is_cluster,
        master_host: master_host,
        is_master_here: is_master_here,
      }
    end
  end
end
