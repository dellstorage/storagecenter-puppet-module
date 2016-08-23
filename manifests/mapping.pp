# Handles mapping volumes to servers
# Sample Usage:
#   class { 'storagemanager::mapping':
#     mapping_definition_array => [{
#       'ensure'            => 'present',
#       'volume_name_array' => ['Volume01', 'Volume05'],
#       'volume_name_array_is_range => true,
#       'server_name'       => 'Server01',
#       'storagecenter'    => 12345,
#     }]
#   }
#
class storagemanager::mapping (
  # An array of hashes containing mapping properties
  $mapping_definition_array   = [],
  # Mapping property defaults
  $ensure                     = 'present', # Desired state of resource
  $volume_name_array          = [], # ScVolume InstanceName(s)
  $volume_name_array_is_range = false, # The two values listed in the volume_name_array indicate a range of volume names
  $server_name                = '', # ScServer InstanceName
  $storage_center, # StorageCenter InstanceId
  ) {
  include stdlib
  # Create a hash from the default properties to allow merge
  $default_mapping_properties = {
    ensure                     => $ensure,
    volume_name_array          => $volume_name_array,
    volume_name_array_is_range => $volume_name_array_is_range,
    server_name                => $server_name,
    storage_center             => $storage_center,
  }
  # Repeats on each hash of properties in the array
  $mapping_definition_array.each |$property_hash| {
    validate_hash($property_hash)

    # Fill in missing key/value pairs with default values
    # Merge will give priority to rightmost argument
    $complete_property_hash = merge($default_mapping_properties, $property_hash)

    # Check if volume_name_array is a range
    if $complete_property_hash['volume_name_array_is_range'] == true {
      $full_volume_name_array = range($complete_property_hash['volume_name_array'][0], $complete_property_hash['volume_name_array'][
        1])
    } else {
      $full_volume_name_array = $complete_property_hash['volume_name_array']
    }

    # Creates mappings
    storagemanager_volume_map { $full_volume_name_array:
      ensure        => $complete_property_hash['ensure'],
      servername    => $complete_property_hash['server_name'],
      storagecenter => $complete_property_hash['storage_center'],
    }
  }
}