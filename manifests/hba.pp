# Manages adding and removing HBAs from Servers
#
# Sample Usage:
#   class { 'storagemanager::hba':
#     hba_definition_array => [{
#       port_type => 'Iscsi',
#       wwn_or_iscsi_name => 'iqn.yyyy-mm.naming-authority:unique.name',
#       server_name => 'Server01',
#       storage_center => 12345,
#     }]
#   }
#
class storagemanager::hba (
  $hba_definition_array = [],
  # HBA property defaults
  $ensure               = 'present', # Desired state of resource
  $allow_manual         = false, # Boolean
  $port_type            = '', # FrontEndTransportTypeEnum
  $storage_center, # StorageCenter InstanceId
  $wwn_or_iscsi_name    = '', # String
  $server_name          = '', # ScServer InstanceName
  ) {
  include stdlib
  # Create a hash of default properties to allow merge
  $default_hba_properties = {
    ensure            => $ensure,
    allow_manual      => $allow_manual,
    port_type         => $port_type,
    storage_center    => $storage_center,
    wwn_or_iscsi_name => $wwn_or_iscsi_name,
    server_name       => $server_name,
  }
  
  # Repeats on each definition in the array
  $hba_definition_array.each |$index, $property_hash| {
    validate_hash($property_hash)
    
    # Fill in missing key/value pairs with default values
    # Merge will give priority to rightmost argument
    $complete_property_hash = merge($default_hba_properties, $property_hash)

    # Error message for empty title string
    if $complete_property_hash['server_name'] == '' {
      fail "Must provide ScServer InstanceName."
    }

    # Adds HBA
    storagemanager_hba { $complete_property_hash['server_name']:
      ensure        => $complete_property_hash['ensure'],
      allowmanual   => $complete_property_hash['allow_manual'],
      porttype      => $complete_property_hash['port_type'],
      storagecenter => $complete_property_hash['storage_center'],
      wwn           => $complete_property_hash['wwn_or_iscsi_name'],
    }
  }
}