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
# Handles server folder creation
# Defaults can be set in this subclass
#
# Sample Usage:
#   class { 'dellstorageprovisioning::server_folder':
#     folder_definition_array => [{
#       num_folders => 1,
#       folder_name => 'Server Folder',
#       do_not_number => true,
#       ensure => present,
#       storage_center => 12345,
#     }]
#   }
# This sample parameter could also be passed to the main init.pp class with the same effect.
#
class dellstorageprovisioning::server_folder (
  $folder_definition_array = [],
  # Server Folder property defaults
  $ensure                  = 'present', # Desired state of resource
  $notes                   = '', # String
  $parent_name             = '', # ScServerFolder InstanceName
  $storage_center, # StorageCenter InstanceId
  # Variables
  $num_folders             = 0, # Number of folders to create with the specified properties
  $folder_name             = '', # Base name to create  the folder with
  $do_not_number           = true,
  $tear_down               = false, # Delete all folders defined
  ) {
  include stdlib
  # Create a hash of default properties to allow merge
  $default_folder_properties = {
    ensure         => $ensure,
    notes          => $notes,
    parent_name    => $parent_name,
    storage_center => $storage_center,
    num_folders    => $num_folders,
    folder_name    => $folder_name,
    do_not_number  => $do_not_number,
  }

  # Reverse definition order for deletion
  if $tear_down {
    $ordered_definition_array = reverse($folder_definition_array)
  } else {
    $ordered_definition_array = $folder_definition_array
  }

  # Repeat on each definition
  $ordered_definition_array.each |$property_hash| {
    validate_hash($property_hash)

    # Fill in missing key/value pairs with default values
    # Merge will give priority to rightmost argument
    $complete_property_hash = merge($default_folder_properties, $property_hash)

    # Error message for empty title string
    if $complete_property_hash['folder_name'] == '' {
      fail "Must provide name for folder."
    }

    # Teardown override
    if $tear_down == true {
      $ensure_hash = {
        'ensure' => 'absent'
      }
      # Overrides ensure
      $folder_hash = merge($complete_property_hash, $ensure_hash)
    } else {
      $folder_hash = $complete_property_hash
    }

    # Naming
    if $folder_hash['folder_name'] . is_array == true {
      validate_array($folder_hash['folder_name'])
      $name_array = $folder_hash['folder_name']
    } else {
      if $folder_hash['num_folders'] == 1 {
        if $folder_hash['do_not_number'] == true {
          # Leave folder un-numbered
          $name_array = $folder_hash['folder_name']
        }
      } else {
        # Create an array of folders
        if $folder_hash['num_folders'] < 10 {
          # Add leading zero
          $num = "0${folder_hash['num_folders']}"
        } else {
          $num = "${folder_hash['num_folders']}"
        }
        # Array of folders from 01 to num_folders
        $name_array = range("${folder_hash['folder_name']}01", "${folder_hash['folder_name']}${num}")
      }
    }

    # Resource Type definition for Server Folder
    dellstorageprovisioning_server_folder { $name_array:
      ensure        => $folder_hash['ensure'],
      notes         => $folder_hash['notes'],
      parent        => $folder_hash['parent_name'],
      storagecenter => $folder_hash['storage_center'],
    }
  }
}