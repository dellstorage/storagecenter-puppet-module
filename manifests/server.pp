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
# Handles server creation
#
# Sample Usage:
#   class { 'dellstorageprovisioning::server':
#     server_definition_array => [{
#       num_servers => 5,
#       base_name => 'Server',
#       ensure => present,
#       parent_name => 'Parent',
#       storage_center => 12345,
#     }]
#   }
#
class dellstorageprovisioning::server (
  # An array of hashes containing server properties
  $server_definition_array       = [],
  # Server property defaults
  $ensure        = 'present', # Desired state of resource.
  $alert_on_connectivity         = true, # Boolean
  $alert_on_partial_connectivity = true, # Boolean
  $notes         = '', # String
  $operating_system              = '', # ScServerOperatingSystem InstanceName
  $parent_name   = '', # ScServer InstanceName
  $folder_name   = '', # ScServerFolder InstanceName
  $storage_center, # StorageCenter InstanceId
  $wwn_or_iscsi_name             = [], # WWN or Iscsi Name
  $port_type     = '', # FrontEndTransportTypeEnum
  # Variables
  $is_server_cluster             = false, # Indicates whether the server should be created as a server cluster
  $num_servers   = 0, # Number of servers to create with the defined properties.
  $server_name   = '', # Base Name to use to create the server.
  $do_not_number = true, # Do not number servers created singly.
  $tear_down     = false, # Delete all servers defined.
  ) {
  include stdlib
  # Create a hash from the default properties to allow merge
  $default_server_properties = {
    ensure                => $ensure,
    alert_on_connectivity => $alert_on_connectivity,
    alert_on_partial_connectivity => $alert_on_partial_connectivity,
    notes                 => $notes,
    operating_system      => $operating_system,
    parent_name           => $parent_name,
    folder_name           => $folder_name,
    storage_center        => $storage_center,
    wwn_or_iscsi_name     => $wwn_or_iscsi_name,
    port_type             => $port_type,
    num_servers           => $num_servers,
    server_name           => $server_name,
    do_not_number         => $do_not_number,
  }

  # Reverse definition order for deletion
  if $tear_down {
    $ordered_definition_array = reverse($server_definition_array)
  } else {
    $ordered_definition_array = $server_definition_array
  }

  # Repeats on each hash of properties in the array
  $ordered_definition_array.each |$property_hash| {
    validate_hash($property_hash)

    # Fill in missing key/value pairs with default values
    # Merge will give priority to rightmost argument
    $complete_property_hash = merge($default_server_properties, $property_hash)

    # Error message for empty title string
    if $complete_property_hash['server_name'] == '' {
      fail "Must provide name for server."
    }

    # Teardown override
    if $tear_down == true {
      $ensure_hash = {
        'ensure' => 'absent'
      }
      $server_hash = merge($complete_property_hash, $ensure_hash)
    } else {
      $server_hash = $complete_property_hash
    }

    # Naming
    if $server_hash['server_name'] . is_array == true {
      validate_array($server_hash['server_name'])
      $name_array = $server_hash['server_name']
    } else {
      if $server_hash['num_servers'] == 1 {
        if $server_hash['do_not_number'] == true {
          # Leave name as-is
          $name_array = $server_hash['server_name']
        }
      } else {
        # Create a range of numbered servers
        if $server_hash['num_servers'] < 10 {
          # Add a leading zero to end of range
          $num = "0${server_hash['num_servers']}"
        } else {
          $num = "${server_hash['num_servers']}"
        }
        # Create an array of servers from 01 to num_servers
        $name_array = range("${server_hash['server_name']}01", "${server_hash['server_name']}${num}")
      }
    }

    # Creates the number of servers specified in the property hash
    if $server_hash['is_server_cluster'] == true {
      # Creates a servercluster
      dellstorageprovisioning_servercluster { $name_array:
        ensure              => $server_hash['ensure'],
        alertonconnectivity => $server_hash['alert_on_connectivity'],
        alertonpartialconnectivity => $server_hash['alert_on_partial_connectivity'],
        notes               => $server_hash['notes'],
        operatingsystem     => $server_hash['operating_system'],
        serverfolder        => $server_hash['folder_name'],
        storagecenter       => $server_hash['storage_center'],
      }
    } else {
      # Creates a server
      dellstorageprovisioning_server { $name_array:
        ensure              => $server_hash['ensure'],
        alertonconnectivity => $server_hash['alert_on_connectivity'],
        alertonpartialconnectivity => $server_hash['alert_on_partial_connectivity'],
        notes               => $server_hash['notes'],
        operatingsystem     => $server_hash['operating_system'],
        parent              => $server_hash['parent_name'],
        serverfolder        => $server_hash['folder_name'],
        storagecenter       => $server_hash['storage_center'],
      }

      # Adds HBA when provided
      unless $server_hash['wwn_or_iscsi_name'] == [] {
        unless $server_hash['port_type'] == '' {
          # No point adding an HBA to a deleted volume.
          unless $server_hash['ensure'] == 'absent' {
            if $name_array.is_string == true {
              dellstorageprovisioning_hba { $name_array:
                ensure        => 'present',
                allowmanual   => false,
                porttype      => $server_hash['port_type'],
                storagecenter => $server_hash['storage_center'],
                wwn           => $server_hash['wwn_or_iscsi_name']
              }
            } else {
              if $server_hash['wwn_or_iscsi_name'] . is_string == true {
                fail "Must provide one WWN or iSCSI name per Server."
              }
              $name_array.each |$index, $name| {
                dellstorageprovisioning_hba { $name:
                  ensure        => 'present',
                  allowmanual   => false,
                  porttype      => $server_hash['port_type'],
                  storagecenter => $server_hash['storage_center'],
                  wwn           => $server_hash['wwn_or_iscsi_name'][$index],
                }
              }
            }
          }
        }
      }
    }
  }
}