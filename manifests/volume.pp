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
# Handles volume creation
# Defaults can be set in this subclass
#
# Sample Usage:
#   class { 'dellstorageprovisioning::volume':
#     volume_definition_array => [{
#       num_volumes => 5,
#       base_name => 'Volume',
#       ensure => present,
#       size => '500GB',
#       folder => 'Folder01',
#       storage_center => 12345,
#     }]
#   }
# This sample parameter could also be passed to the main init.pp class with the same effect.
#
class dellstorageprovisioning::volume (
  # An array of hashes containing volume properties
  $volume_definition_array = [],
  # Volume property defaults -- documentation in Volume Type Definition.
  $ensure                  = 'present', # Desired state of resource
  $data_page_size          = '', # DataPageSizeEnum
  $data_reduction_profile  = '', # ScDataReductionProfile InstanceId
  $disk_folder             = '', # ScDiskFolder InstanceId
  $group_qos_profile       = '', # ScQosProfile InstanceId
  # Notes for the volume.
  $notes                   = '', # String
  $read_cache              = true, # Boolean
  $redundancy              = '', # RedundancyEnum
  $replay_profile_list     = '', # ScReplayProfile[]
  $size                    = '10GB', # Size
  $storage_center, # StorageCenter InstanceId
  $storage_profile         = '', # ScStorageProfile InstanceId
  $storage_type            = '', # ScStorageType InstanceId
  $folder_name             = '', # ScVolumeFolder InstanceName
  $volume_qos_profile      = '', # ScQosProfile InstanceId
  $write_cache             = true, # Boolean
  # Variables
  $num_volumes             = 0, # Number of volumes to create with the same properties.
  $server_name             = '', # Name of a Server to which the volume should be mapped.
  $volume_name             = '', # The base name to use for the volume.
  $do_not_number           = true, # Do not number volumes created singly.
  $tear_down               = false, # Delete all volumes defined.
  ) {
  # Creating a hash from the default properties to allow merge
  include stdlib
  $default_volume_properties = {
    ensure                 => $ensure,
    data_page_size         => $data_page_size,
    data_reduction_profile => $data_reduction_profile,
    disk_folder            => $disk_folder,
    group_qos_profile      => $group_qos_profile,
    notes                  => $notes,
    read_cache             => $read_cache,
    redundancy             => $redundancy,
    replay_profile_list    => $replay_profile_list,
    size                   => $size,
    storage_center         => $storage_center,
    storage_profile        => $storage_profile,
    folder_name            => $folder_name,
    volume_qos_profile     => $volume_qos_profile,
    write_cache            => $write_cache,
    server_name            => $server_name,
    volume_name            => $volume_name,
    num_volumes            => $num_volumes,
    do_not_number          => $do_not_number,
  }
  # Repeats on each hash of volume properties in the array.
  $volume_definition_array.each |$property_hash| {
    validate_hash($property_hash)
    # Fill in missing key/value pairs with default values
    # Merge will give priority to rightmost argument.
    $complete_property_hash = merge($default_volume_properties, $property_hash)

    # Error message for empty title string
    if $complete_property_hash['base_name'] == '' {
      fail "Must provide name for volume."
    }

    # Teardown override
    if $tear_down == true {
      $ensure_hash = {
        'ensure' => 'absent'
      }
      $volume_hash = merge($complete_property_hash, $ensure_hash)
    } else {
      $volume_hash = $complete_property_hash
    }

    # Volume naming
    if $volume_hash['volume_name'] . is_array == true {
      $name_array = $volume_hash['volume_name']
    } else {
      if $volume_hash['num_volumes'] == 1 {
        if $volume_hash['do_not_number'] == true {
          # Leave name as-is
          $name_array = $volume_hash['volume_name']
        }
      } else {
        # Create a range of numbered volumes
        if $volume_hash['num_volumes'] < 10 {
          # Add a leading zero to end of range
          $num = "0${volume_hash['num_volumes']}"
        } else {
          $num = "${volume_hash['num_volumes']}"
        }
        # Create an array of volumes from 01 to num_volumes
        $name_array = range("${volume_hash['volume_name']}01", "${volume_hash['volume_name']}${num}")
      }
    }

    # Resource Type definition for Volume
    dellstorageprovisioning_volume { $name_array:
      ensure               => $volume_hash['ensure'],
      datapagesize         => $volume_hash['data_page_size'],
      datareductionprofile => $volume_hash['data_reduction_profile'],
      diskfolder           => $volume_hash['disk_folder'],
      groupqosprofile      => $volume_hash['group_qos_profile'],
      notes                => $volume_hash['notes'],
      readcache            => $volume_hash['read_cache'],
      redundancy           => $volume_hash['redundancy'],
      replayprofilelist    => $volume_hash['replay_profile_list'],
      size                 => $volume_hash['size'],
      storagecenter        => $volume_hash['storage_center'],
      storageprofile       => $volume_hash['storage_profile'],
      storagetype          => $volume_hash['storage_type'],
      volumefolder         => $volume_hash['folder_name'],
      volumeqosprofile     => $volume_hash['volume_qos_profile'],
      writecache           => $volume_hash['write_cache'],
    }

    # Map the volume if server name is provided
    unless $volume_hash['server_name'] == '' {
      # No point in mapping deleted volumes
      if $volume_hash['ensure'] == 'present' {
        # Resource Type definition for mapping
        dellstorageprovisioning_volume_map { $name_array:
          ensure        => "present",
          servername    => $volume_hash['server_name'],
          storagecenter => $volume_hash['storage_center'],
        }
      }
    }
  }
}