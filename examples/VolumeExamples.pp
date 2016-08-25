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
# This is an example manifest showing how to create Volumes, Volume Folders, and mappings between Volumes and Servers.
# Fill in the information at the top of the file.
class { 'dellstorageprovisioning':
  # The IP address of the DSM Data Collector or Storage Center
  ip_address => "YOUR DSM IP ADDRESS",
  password   => "YOUR PASSWORD",
  username   => "YOUR USERNAME",
  # The 'tear_down' value overrides everything else and destroys your defined system.
  tear_down  => false, # Change to 'true' to remove set-up
  # The 'default_storage_center' value can be overwritten in any definition or subclass.
  default_storage_center         => "YOUR SC ID",
  # Creates a single server with default properties for mapping
  server_definition_array        => [{
      server_name => ["MappingServer"],
    }
    ],
  # The volume_folder_definition_array is used to create/destroy folders
  volume_folder_definition_array => [
    # Multiple definitions can be included in the same array
    {
      # If only creating one folder, it can be unnumbered if 'do_not_number' is set to true.
      num_folders   => 1,
      do_not_number => true,
      folder_name   => "SingleFolder",
    }
    ,
    {
      # If creating multiple folders, they'll be numbered (e.g. SeriesFolder01)
      # Always define parent folders before child folders
      num_folders => 3,
      folder_name => "SeriesFolder",
      notes       => "Example Notes",
      parent_name => "SingleFolder",
    }
    ,
    {
      # Multiple (unnumbered) folders can be created from an array
      folder_name => [
        "1-ArrayFolder",
        "2-ArrayFolder",
        "3-ArrayFolder"],

    }
    ],
  # The volume_definition_array is used to create/destroy volumes and map them to servers
  volume_definition_array        => [
    {
      # Map to a server by specifying a server name
      volume_name    => "SingleVolume",
      size           => "500GB",
      num_volumes    => 1,
      do_not_number  => true,
      read_cache     => false,
      write_cache    => false,
      data_page_size => "Mb2",
      server_name    => "MappingServer",
    }
    ,
    {
      # Any default values can be overridden
      volume_name => "SeriesVolume",
      num_volumes => 5,
      size        => "100GB",
      folder_name => "SeriesFolder01",
    }
    ,
    {
      volume_name => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      size        => "10GB",
    }
    ],
  # The mapping definition array is used to add/remove mappings
  mapping_definition_array       => [
    {
      # Provide an array of volume names to be mapped
      volume_name_array => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      server_name       => "MappingServer",
    }
    ,
    {
      # If the array contains only the first and last members of a series,
      # set 'volume_name_array_is_range' to true to map the entire series.
      volume_name_array          => [
        "SeriesVolume01",
        "SeriesVolume05"],
      volume_name_array_is_range => true,
      server_name                => "MappingServer",
    }
    # mappings can be removed by including 'ensure => absent' in the hash
    ],
}
