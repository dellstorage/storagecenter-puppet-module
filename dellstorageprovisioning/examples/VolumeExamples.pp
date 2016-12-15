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
# The objects are created using names that reflect the method used in their creation.
# This manifest performs creation in several different ways to illustrate the modules abilities and to provide testing.
# Fill in the information at the top of the file.
class { 'dellstorageprovisioning':
  # The IP address of the DSM Data Collector or Storage Center.
  ip_address => "YOUR DSM IP ADDRESS",
  password   => "YOUR PASSWORD",
  username   => "YOUR USERNAME",
  # The 'tear_down' value overrides everything else and destroys your defined system.
  tear_down  => false, # Change to 'true' to remove set-up.
  # The 'default_storage_center' value can be overwritten in any definition or subclass.
  default_storage_center         => "YOUR SC ID",
  # Creates a single server with default properties for mapping.
  server_definition_array        => [{
      server_name => ["MappingServer"],
    }
    ],
  # The volume_folder_definition_array is used to create/destroy folders
  volume_folder_definition_array => [
    # Multiple definitions can be included in the same array.
    # If only creating one folder, it can be unnumbered if 'do_not_number' is set to true.
    # This example creates one folder titled "SingleFolder" with default properties.
    {
      num_folders   => 1,
      do_not_number => true,
      folder_name   => "SingleFolder",
    }
    ,
    # If creating multiple folders, they'll be numbered (e.g. SeriesFolder01).
    # Always define parent folders before child folders.
    # This example creates three folders titled "SeriesFolder01"-"SeriesFolder03" within the "SingleFolder" folder and overrides some defaults.
    {
      num_folders => 3,
      folder_name => "SeriesFolder",
      notes       => "Example Notes",
      parent_name => "SingleFolder",
    }
    ,
    # Multiple (unnumbered) folders can be created from an array.
    # This example creates three folders with the names specified in the 'folder_name' array with default properties.
    {
      folder_name => [
        "1-ArrayFolder",
        "2-ArrayFolder",
        "3-ArrayFolder"],

    }
    ],
  # The volume_definition_array is used to create/destroy volumes and map them to servers.
  volume_definition_array        => [
    # Map to a server by specifying a server name.
    # This example creates a single 500GB Volume named "SingleVolume" and maps it to "MappingServer".
    # This example also overrides several default properties.
    {
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
    # This example creates five 100GB Volumes named "SeriesVolume01"-"SeriesVolume05" in the "SeriesFolder01" folder.
    {
      volume_name => "SeriesVolume",
      num_volumes => 5,
      size        => "100GB",
      folder_name => "SeriesFolder01",
    }
    ,
    # This example creates 3 10GB Volumes using the names specified in the 'volume_name' array.
    {
      volume_name => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      size        => "10GB",
    }
    ],
  # The mapping_definition_array is used to add/remove mappings.
  mapping_definition_array       => [
    # Provide an array of volume names to be mapped.
    # This example maps the volumes specified in the 'volume_name_array' to the "MappingServer" Server.
    {
      volume_name_array => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      server_name       => "MappingServer",
    }
    ,
    # If the array contains only the first and last members of a series,
    # set 'volume_name_array_is_range' to true to map the entire series.
    # This example maps the entire series of volumes named "SeriesVolume01" through "SeriesVolume05" to "MappingServer".
    {
      volume_name_array          => [
        "SeriesVolume01",
        "SeriesVolume05"],
      volume_name_array_is_range => true,
      server_name                => "MappingServer",
    }
    # mappings can be removed by including 'ensure => absent' in the hash.
    ],
}
