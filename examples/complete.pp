# This is an example main mainfest to show how to use this module
# to provision a system using puppet apply.
# 
# Information on puppet main manifests:
# https://docs.puppet.com/puppet/latest/reference/dirs_manifest.html
# 
# Set default values in 'storagemanager' and its subclasses
# 
# The order in which these parameters are assigned is unimportant.
#
class { 'storagemanager': 
  ip_address => "100.00.00.00",
  password => "passw0rd",
  username => "user1",
  tear_down => false,
  default_storage_center => 12345,
  
  # == Definition Arrays:
  # Variables not declared in the definion arrays will be
  # filled in by defaults declared in the respective subclass.
  
  server_folder_definition_array => [
    # Create parent folders before child folders
    {
      num_folders => 1,
      do_not_number => true,
      base_name => 'ServerFolder1',
    },
    {
      num_folders => 1,
      do_not_number => true,
      base_name => 'ServerFolder2',
      parent => 'ServerFolder1',
    },
  ],
  
  server_definition_array => [
    # Within the server_definition_array, Server Clusters should
    # be declared before Servers.
    {
      num_servers => 1,
      base_name => 'ExampleCluster',
      do_not_number => true,
      is_server_cluster => true,
      operating_system => 'Other Singlepath',
      folder_name => 'ServerFolder2',
    },
    {
      num_servers => 3,
      base_name => 'ExampleServer',
      parent => 'ExampleCluster',
      operating_system => 'Other Singlepath',
    },
  ],

  hba_definition_array => [
    {
      wwn_or_iscsi_name => 'iqn.yyyy-mm.naming-authority:unique.name',
      port_type => 'Iscsi',
      server_name => 'ExampleServer03',
    }
  ],
  
  volume_folder_definition_array => [
    {
      num_folders => 1,
      do_not_number => true,
      base_name => 'VolumeFolder',
    }
  ],  

  volume_definition_array => [
    {
      num_volumes => 1,
      base_name => 'FirstExampleVolume',
      do_not_number => true,
      size => 500GB,
      server_name => 'ExampleCluster',
    },
    {
      num_volumes => 5,
      base_name => 'SecondExampleVolume',
      size => 100GB,
      folder_name => 'VolumeFolder',
    },
  ],
  
  mapping_definition_array => [
    {
      volume_name_array => ['SecondExampleVolume01', 'SecondExampleVolume05'],
      volume_name_array_is_range => true,
      server_name => 'ExampleServer01',
    }
  ],
}