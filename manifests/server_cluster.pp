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
# Handles servercluster creation
# Defaults can be set in this subclass
#
# Sample Usage:
#   class { 'dellstorageprovisioning::server_cluster':
#     server_cluster_definition_array => [{
#       num_servers => 5,
#       cluster_name => 'Server Cluster',
#       ensure => present,
#       folder => 'Folder01',
#       storage_center => 12345,
#     }]
#   }
# This sample parameter could also be passed to the main init.pp class with the same effect.
#
class dellstorageprovisioning::server_cluster (
  # An array of hashes containing servercluster properties
  $server_cluster_definition_array = [],
  # Servercluster property defaults
  $ensure                = 'present', # Desired state of resource
  $alert_on_connectivity = true, # Boolean
  $alert_on_partial_connectivity   = true, # Boolean
  $notes                 = '', # String
  $operating_system      = '', # ScServerOperatingSystem InstanceName
  $folder_name           = '', # ScServerFolder InstanceName
  $storage_center, # StorageCenter InstanceId
  # Variables
  $num_clusters          = 0, # The number of server clusters to create with the properties defined
  $cluster_name          = '', # The name to use when creating server clusters
  $do_not_number         = false, # Do not number server clusters created singly
  $tear_down             = false, # Delete all server clusters defined
  ) {
  include stdlib

  # Create a hash of default properties to allow merge
  $default_server_cluster_properties = {
    ensure           => $ensure,
    alert_on_connectivity        => $alert_on_connectivity,
    alert_on_partialconnectivity => $alert_on_partial_connectivity,
    notes            => $notes,
    operating_system => $operating_system,
    folder_name      => $folder_name,
    storage_center   => $storage_center,
    num_clusters     => $num_clusters,
    cluster_name     => $cluster_name,
    do_not_number    => $do_not_number,
  }

  # Repeats on each definition in the array
  $server_cluster_definition_array.each |$property_hash| {
    validate_hash($property_hash)

    # Fill in missing key/value pairs with default values
    # Merge gives priority to rightmost argument
    $complete_property_hash = merge($default_server_cluster_properties, $property_hash)

    # Error message for empty title string
    if $complete_property_hash['cluster_name'] == '' {
      fail "Must provide name for Server Cluster."
    }

    # Teardown override
    if $tear_down == true {
      $ensure_hash = {
        'ensure' => 'absent'
      }
      # Overrides the ensure setting
      $server_cluster_hash = merge($complete_property_hash, $ensure_hash)
    } else {
      $server_cluster_hash = $complete_property_hash
    }

    # Naming
    if $server_cluster_hash['cluster_name'] . is_array == true {
      validate_array($server_cluster_hash['cluster_name'])
      $name_array = $server_cluster_hash['cluster_name']
    } else {
      if $server_cluster_hash['num_clusters'] == 1 {
        if $server_cluster_hash['do_not_number'] == true {
          # Leave name unnumbered
          $name_array = $server_cluster_hash['cluster_name']
        }
      } else {
        # Create an array of numbered clusters
        if $server_cluster_hash['num_clusters'] < 10 {
          # Add leading zero
          $num = "0${server_cluster_hash['num_clusters']}"
        } else {
          $num = "${server_cluster_hash['num_clusters']}"
        }

        # Array of numbered clusters from 01 to num_clusters
        $name_array = range("${server_cluster_hash['cluster_name']}01", "${server_cluster_hash['cluster_name']}${num}")
      }
    }

    # Resource Type definition for Server Cluster
    # Creates the number of serverclusters specified in the property hash
    # Creates the servercluster using the properties specified in the complete property hash.
    dellstorageprovisioning_servercluster { $name_array:
      ensure              => $server_cluster_hash['ensure'],
      alertonconnectivity => $server_cluster_hash['alert_on_connectivity'],
      alertonpartialconnectivity => $server_cluster_hash['alert_on_partial_connectivity'],
      notes               => $server_cluster_hash['notes'],
      operatingsystem     => $server_cluster_hash['operating_system'],
      serverfolder        => $server_cluster_hash['folder_name'],
      storagecenter       => $server_cluster_hash['storage_center'],
    }
  }
}