#    Copyright 2016 Dell Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# Handles mapping volumes to servers
# Defaults can be set in this subclass
#
# Sample Usage:
#   class { 'dellstorageprovisioning::mapping':
#     mapping_definition_array => [{
#       'ensure'            => 'present',
#       'volume_name_array' => ['Volume01', 'Volume05'],
#       'volume_name_array_is_range => true,
#       'server_name'       => 'Server01',
#       'storagecenter'    => 12345,
#     }]
#   }
# This sample parameter could also be passed to the main init.pp class with the same effect.
#
class dellstorageprovisioning::mapping (
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

    # Resource Type definition for mapping
    dellstorageprovisioning_volume_map { $full_volume_name_array:
      ensure        => $complete_property_hash['ensure'],
      servername    => $complete_property_hash['server_name'],
      storagecenter => $complete_property_hash['storage_center'],
    }
  }
}