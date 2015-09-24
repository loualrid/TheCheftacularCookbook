
mount_name  = "#{ node['hostname'].gsub('-','_') }_main_backup_storage"
volume_hash = node['TheCheftacularCookbook']['volume_config']['backup_server']

business_volume mount_name do
  primary_directory "/mnt/backupmaster"
  sub_directories { 
    "#{ node['main_backup_location'] }" => { mode: '777', recursive: true },
    "#{ node['main_backup_location'] }/main_backup" => { mode: '777', recursive: true }
  }

  size (volume_hash.has_key?("#{ node.chef_environment }_size") ? volume_hash["#{ node.chef_environment }_size"] : volume_hash['default_size'])
  type (volume_hash.has_key?("#{ node.chef_environment }_type") ? volume_hash["#{ node.chef_environment }_type"] : volume_hash['default_type'])
end