# Common statsd configuration for all hypervisors
class openstack::common::gnocchi ( 
) {

    class { '::gnocchi::client': }

    # make sure ceph pool exists before running gnocchi (dbsync & services)
    #Exec['create-gnocchi'] -> Exec['gnocchi-db-sync']
# TODO: enable statsd
    class { '::gnocchi::statsd':
      archive_policy_name => 'high',
      flush_delay         => '100',
      # random datas:
	# Tree root for all metrics:
      resource_id         => '07f26121-5777-48ba-8a0b-d70468133dd9',
      user_id             => 'f81e9b1f-9505-4298-bc33-43dfbd9a973b',
      project_id          => '203ef419-e73f-4b8a-a73f-3d599a72b18d',
    }

}
