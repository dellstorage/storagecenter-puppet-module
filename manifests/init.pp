class storagemanager (
  # Parameters required for login
  $ip_address, # DNS Host Name or IP Address of the API server
  $username, # DSM User to log in as
  $password, # Password of DSM User

  # Parameters for volumes
  $volume_definition_array         = [],
  # parameters for servers
  $server_definition_array         = [],
  # Parameters for mapping
  $mapping_definition_array        = [],
  # Parameters for server clusters
  $server_cluster_definition_array = [],
  # Parameters for folders
  $volume_folder_definition_array  = [],
  $server_folder_definition_array  = [],
  # Parameters for HBA
  $hba_definition_array            = [],
  # Toggles
  $tear_down = false,
  $default_storage_center          = 66090,) {
  # login to the dsm
  storagemanager_login { "$ip_address":
    username => "$username",
    password => "$password",
    ensure   => present,
  }

  if $tear_down == true {
    # Deletion must be done from child up to parent
    class { 'storagemanager::volume':
      volume_definition_array => $volume_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::volume_folder':
      folder_definition_array => $volume_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::server':
      server_definition_array => $server_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::server_cluster':
      server_cluster_definition_array => $server_cluster_definition_array,
      tear_down      => $tear_down,
      storage_center => $default_storage_center,
    }

    class { 'storagemanager::server_folder':
      folder_definition_array => $server_folder_definition_array,
      tear_down               => $tear_down,
      storage_center          => $default_storage_center,
    }

  } else {
    # Creation must be done from parent down to child
    class { 'storagemanager::server_folder':
      folder_definition_array => $server_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::server_cluster':
      server_cluster_definition_array => $server_cluster_definition_array,
      storage_center                  => $default_storage_center,
    }

    class { 'storagemanager::server':
      server_definition_array => $server_definition_array,
      storage_center          => $default_storage_center,
    }

    unless $hba_definition_array == [] {
      class { 'storagemanager::hba':
        hba_definition_array => $hba_definition_array,
        storage_center       => $default_storage_center,
      }
    }

    class { 'storagemanager::volume_folder':
      folder_definition_array => $volume_folder_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::volume':
      volume_definition_array => $volume_definition_array,
      storage_center          => $default_storage_center,
    }

    class { 'storagemanager::mapping':
      mapping_definition_array => $mapping_definition_array,
      storage_center           => $default_storage_center,
    }
  }
}