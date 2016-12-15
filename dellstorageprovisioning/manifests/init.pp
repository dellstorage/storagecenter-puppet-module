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
# This is the main class called by the program. From here, all other classes will be called.
# Some defaults can be set in this class.
#
class dellstorageprovisioning (
  # Parameters required for login
  # These values should all be strings.
  $ip_address, # DNS Host Name or IP Address of the API server
  $username, # DSM User to log in as
  $password, # Password of DSM User

  # The following parameters are a series of arrays used to create Storage Center Objects.
  # Each "Definition Array" may contain any number of hashes.
  # Each Hash ("Definition") should contain all of the parameters necessary to call the subclass corresponding
  #   to the Definition Array.
  # There are sample definitions in each of the dellstorageprovisioning subclasses.
  # Any value not specified in the definition will use the default value assigned in the respective subclass.
  # A full examples of all possible definition styles can be found in the 'Examples' folder.

  $volume_definition_array  = [], # Parameters for Volumes
  $server_definition_array  = [], # parameters for Servers
  $mapping_definition_array = [], # Parameters for mapping
  $server_cluster_definition_array = [], # Parameters for Server Clusters
  $volume_folder_definition_array  = [], # Parameters for Volume folders
  $server_folder_definition_array  = [], # Parameters for Server folders
  $hba_definition_array     = [], # Parameters for HBA

  # The following variables are for configuration purposes.

  # Default storage center
  # This variable can be given a default value which will be used by all subclasses,
  #   unless the subclass has its own default Storage Center ID.
  # This value can be overwritten on the subclass and definition levels.
  $default_storage_center,
  # This variable can be used to change the name of the main folder in which the Puppet module manages storage.
  # This variable should not be an empty string.
  $main_folder_name         = "Puppet",
  # This variable allows the user to change the port number used when connecting to the DSM Data Collector or Dell Storage Center.
  $port_number              = 3033,
  # This variable is used to completely remove a defined setup.
  # The teardown variable will delete your entire setup if set to true.
  # Don't use this variable unless you know what you're doing.
  $tear_down                = false,) {
  info "Default Storage Center is ${default_storage_center}."

  # Resource declaration to log into the DSM DC/Dell SC
  dellstorageprovisioning_login { "$ip_address":
    username         => $username,
    password         => $password,
    ensure           => present,
    main_folder_name => $main_folder_name,
    port_number      => $port_number,
  }

  # Calls are made in a different order if deleting to avoid issues with dependency.
  if $tear_down == true {
    warning "tear_down is true; tearing down system."

    # Deletion must be done from child up to parent
    # Volume -> Volume Folder -> Server -> Server Cluster -> Server Folder
    # Delivering default values and definition array to volume subclass.
    class { 'dellstorageprovisioning::volume':
      volume_definition_array => $volume_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::volume_folder':
      # Delivering default values and definition array to volume folder subclass.
      folder_definition_array => $volume_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server':
      # Delivering default values and definition array to server subclass.
      server_definition_array => $server_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_cluster':
      # Delivering default values and definition array to server cluster subclass.
      server_cluster_definition_array => $server_cluster_definition_array,
      tear_down      => $tear_down,
      storage_center => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_folder':
      # Delivering default values and definition array to server folder subclass.
      folder_definition_array => $server_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

  } else {
    # Creation must be done from parent down to child
    # Server Folder -> Server Cluster -> Server -> HBA -> Volume Folder -> Volume -> Mapping
    class { 'dellstorageprovisioning::server_folder':
      # Delivering default values and definition array to server folder subclass.
      folder_definition_array => $server_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_cluster':
      # Delivering default values and definition array to server cluster subclass.
      server_cluster_definition_array => $server_cluster_definition_array,
      storage_center                  => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server':
      # Delivering default values and definition array to server subclass.
      server_definition_array => $server_definition_array,
      storage_center          => $default_storage_center,
    }

    # The HBA subclass should not be called with an empty array as it will still attempt to process the data
    unless $hba_definition_array == [] {
      class { 'dellstorageprovisioning::hba':
        # Delivering default values and definition array to hba subclass.
        hba_definition_array => $hba_definition_array,
        storage_center       => $default_storage_center,
      }
    }

    class { 'dellstorageprovisioning::volume_folder':
      # Delivering default values and definition array to volume folder subclass.
      folder_definition_array => $volume_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::volume':
      # Delivering default values and definition array to volume subclass.
      volume_definition_array => $volume_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::mapping':
      # Delivering default values and definition array to mapping subclass.
      mapping_definition_array => $mapping_definition_array,
      storage_center           => $default_storage_center,
    }
  }
}