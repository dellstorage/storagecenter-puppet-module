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
# Manages adding and removing HBAs from Servers
# Defaults can be set in this subclass
#
# Sample Usage:
#   class { 'dellstorageprovisioning::hba':
#     hba_definition_array => [{
#       port_type => 'Iscsi',
#       wwn_or_iscsi_name => 'iqn.yyyy-mm.naming-authority:unique.name',
#       server_name => 'Server01',
#       storage_center => 12345,
#     }]
#   }
# This sample parameter could also be passed to the main init.pp class with the same effect.
#
class dellstorageprovisioning::hba (
  $hba_definition_array = [],
  # HBA property defaults
  $ensure               = 'present', # Desired state of resource
  $allow_manual         = false, # Boolean
  $port_type            = '', # FrontEndTransportTypeEnum
  $storage_center, # StorageCenter InstanceId
  $wwn_or_iscsi_name    = '', # String or array of strings
  $server_name          = '', # ScServer InstanceName | String or array of strings
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

    # If the definition includes multiple servers and hbas
    if $complete_property_hash['server_name'] . is_array == true {
      if $complete_property_hash['wwn_or_iscsi_name'] . is_array == false {
        fail "Must provide one WWN or iSCSI name per Server."
      }
      # Resource Type definition for HBA via arrays
      $complete_property_hash['server_name'] . each |$index, $name| {
        dellstorageprovisioning_hba { $name:
          ensure        => $complete_property_hash['ensure'],
          allowmanual   => $complete_property_hash['allow_manual'],
          porttype      => $complete_property_hash['port_type'],
          storagecenter => $complete_property_hash['storage_center'],
          wwn           => $complete_property_hash['wwn_or_iscsi_name'][$index],
        }
      }
    } else {
      # Resource Type definition for single HBA
      dellstorageprovisioning_hba { $complete_property_hash['server_name']:
        ensure        => $complete_property_hash['ensure'],
        allowmanual   => $complete_property_hash['allow_manual'],
        porttype      => $complete_property_hash['port_type'],
        storagecenter => $complete_property_hash['storage_center'],
        wwn           => $complete_property_hash['wwn_or_iscsi_name'],
      }
    }
  }
}