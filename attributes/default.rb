
default['cheftacular']                   = Chef::DataBagItem.load('default', 'cheftacular').to_hash
default['TheCheftacularCookbook']        = node['cheftacular']['TheCheftacularCookbook']
default['loaded_applications']           = {} #array of all app codebases that will be loaded onto a server. This array is populated further on in the code
default['environment_name']              = node.chef_environment
default['base_application_location']     = node['TheCheftacularCookbook']['base_application_location']
default['secret_path']                   = '/etc/chef/data_bag_key'
default['secret']                        = Chef::EncryptedDataBagItem.load_secret("#{ node['secret_path'] }")
default['additional_db_schemas']         = node['TheCheftacularCookbook']['additional_db_schemas']
default['default_rackspace_volume_size'] = node['TheCheftacularCookbook']['default_rackspace_volume_size']
default['backupmaster_storage_location'] = '/mnt/backupmaster/backups'

#Some defaults for chef-rvm
default['desired_ruby']             = node['cheftacular']['ruby_version'].gsub('ruby-','')
default['rvm']['default_ruby']      = "ruby-#{ node['desired_ruby'] }"
default['rvm']['user_default_ruby'] = "ruby-#{ node['desired_ruby'] }"
default['rvm']['rvm_home']          = "/home/#{ node['cheftacular']['deploy_user'] }/.rvm"
default['rvm']['user_installs'] = [
  {
    'user' => node['cheftacular']['deploy_user'],
    'default_ruby' => node['desired_ruby'],
    'rubies' => [ node['desired_ruby'],'ruby-1.9.3-p327'], #1.9.3-p327 is chef's default ruby, it needs to be in a place rvm can find it
    'global_gems' => [
      { 'name'    => 'bundler', 'version' => node['TheCheftacularCookbook']['bundler_version'] }
    ]
  }
]

env_path = "#{ node['rvm']['rvm_home'] }/gems/#{ node['rvm']['default_ruby'] }/bin:" +
"#{ node['rvm']['rvm_home'] }/gems/#{ node['rvm']['default_ruby'] }@global/bin:" + 
"#{ node['rvm']['rvm_home'] }/rubies/#{ node['rvm']['default_ruby'] }:" +
"#{ node['rvm']['rvm_home'] }/bin:" +
"usr/local/sbin:" +
"usr/local/bin:" +
"usr/bin:" +
"usr/sbin:" +
"/sbin:" +
"usr/games:" +
"/bin:" +
"usr/local/games:"

default['ruby-env'] = {
  "RAILS_ENV"=> node.chef_environment,
  "PATH"=> env_path,
  "GEM_PATH"=>"#{ node['rvm']['rvm_home'] }/gems/#{ node['rvm']['default_ruby'] }:#{ node['rvm']['rvm_home'] }/gems/#{ node['rvm']['default_ruby'] }@global",
  "GEM_HOME"=>"#{ node['rvm']['rvm_home'] }/gems/#{ node['rvm']['default_ruby'] }"
}

default['bundle_command']           = "/etc/profile.d/rvm.sh && /home/#{ node['cheftacular']['deploy_user'] }/.rvm/gems/#{ node['rvm']['default_ruby'] }@global/bin/bundle"
default['unsourced_bundle_command'] = node['bundle_command'].gsub('/etc/profile.d/rvm.sh && ', '')

default['authorization']['sudo']['include_sudoers_d'] = true

#default['nodejs']['version'] = '4.4.7'
#default['nodejs']['source']['checksum'] = 'cbe1c6e421969dd5639d0fbaa6d3c1f56c0463b87efe75be8594638da4d8fc4f'
#default['nodejs']['binary']['checksum']['linux_x64'] = '5ad10465cc9d837c1fda8db0fd1bdc1a4ce823dd6afbc533ac2127e6a9a64133'
#default['nodejs']['binary']['checksum']['linux_x86'] = '604c4f85ef00a13c172465c9672a2a0f13524921e255eeb75242afb42af6d814'
#default['nodejs']['binary']['checksum']['linux_arm64'] = 'a1e2faf3859976ac7322b950353044863c2e36ad6e2e09a8fc9f80f72fd01b18'
#default["nodejs"]["install_method"] = "source"
#default["nodejs"]["npm"]["install_method"] = "source"



#TODO CHECK WITH BACKUP GEM AND RECIPES, ITS STUCK AT THIS
default[:rackspacecloud][:fog_version] = "1.28.0"
default['backup']['version']           = '4.1.10'