# Handles volume folder creation
#
# Sample Usage:
#   class { 'dellstorageprovisioning::volume_folder':
#     folder_definition_array => [{
#       num_folders => 1,
#       base_name => 'Volume Folder',
#       do_not_number => true,
#       ensure => present,
#       storage_center => 12345,
#     }]
#   }
#
class dellstorageprovisioning::volume_folder (
  $folder_definition_array = [],
  # Volume Folder property defaults
  $ensure                  = 'present', # Desired state of resource
  $notes                   = '', # String
  $parent_name             = '', # ScVolumeFolder InstanceName
  $storage_center, # StorageCenter InstanceId
  # Variables
  $num_folders             = 0, # Number of folders to create with the same properties
  $folder_name             = '', # Base name to use for folder creation
  $do_not_number           = true, # Do not number folders created singly
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

  # Reverse the order of definition for deletions
  if $tear_down {
    $ordered_definition_array = reverse($folder_definition_array)
  } else {
    $ordered_definition_array = $folder_definition_array
  }

  # Repeats on each definition in the array
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
      $folder_hash = merge($complete_property_hash, $ensure_hash)
    } else {
      $folder_hash = $complete_property_hash
    }

    # Folder naming
    if $folder_hash['folder_name'] . is_array == true {
      validate_array($folder_hash['folder_name'])
      $name_array = $folder_hash['folder_name']
    } else {
	    if $folder_hash['num_folders'] == 1 {
	      if $folder_hash['do_not_number'] == true {
	        # Leave name as-is
	        $name_array = $folder_hash['folder_name']
	      }
	    } else {
	      # Create a range of numbered folders
	      if $folder_hash['num_folders'] < 10 {
	        # Add a leading zero to end of range
	        $num = "0${folder_hash['num_folders']}"
	      } else {
	        $num = "${folder_hash['num_folders']}"
	      }
	      # Create an array of folders from 01 to num_folders
	      $name_array = range("${folder_hash['folder_name']}01", "${folder_hash['folder_name']}${num}")
	    }
    }
    
    # Defines the folder using the properties specified in the definition
    dellstorageprovisioning_volume_folder { $name_array:
      ensure        => $folder_hash['ensure'],
      notes         => $folder_hash['notes'],
      parent   => $folder_hash['parent_name'],
      storagecenter => $folder_hash['storage_center'],
    }
  }
}