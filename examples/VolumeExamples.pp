# This is an example manifest showing how to create Volumes, Volume Folders, and mappings between Volumes and Servers.
# Fill in the information at the top of the file.
class { 'dellstorageprovisioning':
  ip_address => "YOUR DSM IP ADDRESS",
  password   => "YOUR PASSWORD",
  username   => "YOUR USERNAME",
  tear_down  => false, # Change to 'true' to remove set-up
  default_storage_center         => "YOUR SC ID",
  server_definition_array        => [
    {
      server_name => [
        "MappingServer"],
    }
    ],
  volume_folder_definition_array => [
    {
      num_folders   => 1,
      do_not_number => true,
      folder_name   => "SingleFolder",
    }
    ,
    {
      num_folders => 3,
      folder_name => "SeriesFolder",
      notes       => "Example Notes",
      parent_name => "SingleFolder",
    }
    ,
    {
      folder_name    => [
        "1-ArrayFolder",
        "2-ArrayFolder",
        "3-ArrayFolder"],

    }
    ],
  volume_definition_array        => [
    {
      volume_name    => "SingleVolume",
      size           => "500GB",
      num_volumes    => 1,
      do_not_number  => true,
      read_cache     => false,
      write_cache    => false,
      data_page_size => "Mb2",
      server_name => "MappingServer",
    }
    ,
    {
      volume_name => "SeriesVolume",
      num_volumes => 5,
      size        => "100GB",
      folder_name => "SeriesFolder01",
    }
    ,
    {
      volume_name    => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      size           => "10GB",
    }
    ],
  mapping_definition_array       => [
    {
      volume_name_array => [
        "1-ArrayVolume",
        "2-ArrayVolume",
        "3-ArrayVolume"],
      server_name       => "MappingServer",
    }
    ,
    {
      volume_name_array          => [
        "SeriesVolume01",
        "SeriesVolume05"],
      volume_name_array_is_range => true,
      server_name                => "MappingServer",
    }
    ],
}
