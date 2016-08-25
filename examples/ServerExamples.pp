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
# This is an example manifest showing how to create Servers, Server Clusters, and Server Folders, and add HBAs.
# Remember to fill in your HBA information in addition to the information at the top of the file.
class { 'dellstorageprovisioning':
  ip_address => "YOUR DSM IP ADDRESS",
  password   => "YOUR PASSWORD",
  username   => "YOUR USERNAME",
  tear_down  => false, # Change to 'true' to remove set-up
  default_storage_center          => "YOUR SC ID",
  server_folder_definition_array  => [
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
      folder_name => [
        "1-ArrayFolder",
        "2-ArrayFolder",
        "3-ArrayFolder"],
    }
    ],
  server_cluster_definition_array => [
    {
      cluster_name     => [
        "1-ArrayCluster",
        "2-ArrayCluster"],
      operating_system => "Novell Suse Linux 10",
      folder_name      => "1-ArrayFolder",
    }
    ,
    {
      cluster_name     => "SingleCluster",
      num_clusters     => 1,
      operating_system => "Red Hat Linux 5.x",
      do_not_number    => true,
      notes            => "Example Notes",
      alert_on_partial_connectivity => false,
      alert_on_connectivity         => false,
    }
    ,
    {
      cluster_name     => "SeriesCluster",
      num_clusters     => 2,
      operating_system => "Windows 2012",
      folder_name      => "SeriesFolder01",
    }
    ],
  server_definition_array         => [
    {
      server_name   => "SingleServer",
      num_servers   => 1,
      do_not_number => true,
      alert_on_connectivity         => false,
      alert_on_partial_connectivity => false,
      notes         => "Example Notes",
      wwn_or_iscsi_name             => "YOUR ISCSI NAME",
      port_type     => "Iscsi",
    }
    ,
    {
      server_name => "SeriesServer",
      num_servers => 5,
      folder_name => "SeriesFolder01",
    }
    ,
    {
      server_name      => [
        "1-ArrayServer",
        "2-ArrayServer"],
      operating_system => "Novell Suse Linux 10",
      parent_name      => "1-ArrayCluster",
    }
    ,
    {
      server_name       => [
        "ClusterServer"],
      is_server_cluster => true,
      operating_system  => "Other Singlepath",
    }
    ,
    ],
  hba_definition_array            => [{
      server_name       => "SeriesServer01",
      port_type         => "Iscsi",
      wwn_or_iscsi_name => "YOUR OTHER ISCSI NAME",
    }
    ],
}