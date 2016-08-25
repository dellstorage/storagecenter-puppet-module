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
class dellstorageprovisioning (
  # Parameters required for login
  $ip_address, # DNS Host Name or IP Address of the API server
  $username, # DSM User to log in as
  $password, # Password of DSM User

  # Parameters for volumes
  $volume_definition_array  = [],
  # parameters for servers
  $server_definition_array  = [],
  # Parameters for mapping
  $mapping_definition_array = [],
  # Parameters for server clusters
  $server_cluster_definition_array = [],
  # Parameters for folders
  $volume_folder_definition_array  = [],
  $server_folder_definition_array  = [],
  # Parameters for HBA
  $hba_definition_array     = [],
  # Toggles
  $tear_down                = false,
  $default_storage_center   = 66090,
  # Configuration
  $main_folder_name         = "Puppet",
  $port_number              = 3033,) {
  # login to the dsm
  dellstorageprovisioning_login { "$ip_address":
    username         => $username,
    password         => $password,
    ensure           => present,
    main_folder_name => $main_folder_name,
    port_number      => $port_number,
  }

  if $tear_down == true {
    # Deletion must be done from child up to parent
    class { 'dellstorageprovisioning::volume':
      volume_definition_array => $volume_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::volume_folder':
      folder_definition_array => $volume_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server':
      server_definition_array => $server_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_cluster':
      server_cluster_definition_array => $server_cluster_definition_array,
      tear_down      => $tear_down,
      storage_center => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_folder':
      folder_definition_array => $server_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

  } else {
    # Creation must be done from parent down to child
    class { 'dellstorageprovisioning::server_folder':
      folder_definition_array => $server_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server_cluster':
      server_cluster_definition_array => $server_cluster_definition_array,
      storage_center                  => $default_storage_center,
    }

    class { 'dellstorageprovisioning::server':
      server_definition_array => $server_definition_array,
      storage_center          => $default_storage_center,
    }

    unless $hba_definition_array == [] {
      class { 'dellstorageprovisioning::hba':
        hba_definition_array => $hba_definition_array,
        storage_center       => $default_storage_center,
      }
    }

    class { 'dellstorageprovisioning::volume_folder':
      folder_definition_array => $volume_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::volume':
      volume_definition_array => $volume_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'dellstorageprovisioning::mapping':
      mapping_definition_array => $mapping_definition_array,
      storage_center           => $default_storage_center,
    }
  }
}