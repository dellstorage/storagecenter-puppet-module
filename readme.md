# Dell Storage Puppet Module

## About

This module uses Puppet's Custom Resource Types to allow the user to provision a setup on the Storage Center, ensure that it is maintained, and tear it down.

The module is run by either a main manifest, a puppet master, or an ENC, that calls the main dellstorageprovisioning class (`manifests/init.pp`) with parameters defining the desired setup of the Storage Center(s).

This module will create a 'Puppet' folder on the Storage Center and will only create or destroy Storage Center objects within that folder. This is to protect the users' data as this module uses the object's name as an unique identifier, while the Storage Center allows multiple objects with the same name. 

## Setup

The dellstorageprovisioning module requires a Puppet version of 3.8.4 or later. Earlier versions of Puppet use an outdated version of OpenSSL which the DSM API will not allow to connect to the Storage Center.

This module requires the Puppet [stdlib module] (https://forge.puppet.com/puppetlabs/stdlib/3.2.1). If using an ENC, the stdlib class must be assigned to the same node as the dellstorageprovisioning module.

The dellstorageprovisioning module has been designed to work with Puppet Enterprise, Puppet Apply, Puppet Agent, and Foreman.

## Usage

Unlike most Puppet Modules, the dellstorageprovisioning module does not affect the Server on which it is run. The Server the module runs on is used to send REST calls to the DSM Data Collector or Dell Storage Center. It possible but not necessary to have this module running on multiple Servers, as long as the objects they are managing do not interfere with one another.

### Puppet Apply

[Puppet Apply] (https://docs.puppet.com/puppet/latest/reference/man/apply.html) is the client-only application of a local manifest. The user should ensure that the dellstorageprovisioning module is located within an [environment] (https://docs.puppet.com/puppet/4.6/reference/environments.html) on Puppet's [environmentpath] (https://docs.puppet.com/puppet/4.6/reference/environments_configuring.html#environmentpath). The environmentpath can be set in puppet.conf, which is found in the [$confdir] (https://docs.puppet.com/puppet/4.6/reference/dirs_confdir.html). Examples of a local manifest to be used with Puppet Apply can be found in the `examples` folder. The user will need to provide a full path to the manifest on the command line.

### Puppet Agent

[Puppet Agent] (https://docs.puppet.com/puppet/latest/reference/man/agent.html) retrieves a catalog from the remote server and applies it on the local system. Both the dellstorageprovisioning module and the stdlib module must be assigned to the local system. Puppet Agent will require a manifest on the master server. Examples of a manifest to be used with Puppet Agent can be found in the `examples` folder.

### Foreman/Puppet Enterprise

To use [Foreman] (https://theforeman.org) or [Puppet Enterprise] (https://puppet.com/product) the `dellstorageprovisioning` class must be assigned to the host from which the program will send the REST calls. Defaults can either be set within the code of the subclasses (select `Use Puppet Default` in Foreman to use these values as the default), or through Foreman/Puppet Enterprise. The definition arrays are intended to be overridden within the main `dellstorageprovisioning` class, and the default values in the subclasses will fill in missing information.

Note: It is only necessary to assign the main dellstorageprovisioning class to the host in Foreman/Puppet Enterprise, as all the subclasses are called by the main class.

Helpful Links: [Puppet Architecture] (https://docs.puppet.com/puppet/4.6/reference/architecture.html)

## Testing

### Example Manifests

Two example manifests are included in the `examples` folder. These can be used as a reference for writing manifests or filling in parameters in Foreman. They can also be run via Puppet Apply as tests to ensure full functionality, as they utilize every method of creating each object with different properties.

The state of the Storage Center after running `examples/VolumeExamples.pp` should be:

**Volumes**

* Puppet
	* 1-ArrayFolder
	* 2-ArrayFolder
	* 3-ArrayFolder
	* SingleFolder
		* SeriesFolder01
			* SeriesVolume01
			* SeriesVolume02
			* SeriesVolume03
			* SeriesVolume04
			* SeriesVolume05
		* SeriesFolder02
		* SeriesFolder03
	* 1-ArrayVolume
	* 2-ArrayVolume
	* 3-ArrayVolume
	* SingleVolume

**Servers**

* Puppet
	* MappingServer
	
All of the Volumes should be mapped to `MappingServer`.

The state of the Storage Center after running `examples/ServerExamples.pp` should be:

**Servers**

* Puppet
	* 1-ArrayFolder
		* 1-ArrayCluster
			* 1-ArrayServer
			* 2-ArrayServer
		* 2-ArrayCluster
	* 2-ArrayFolder
	* 3-ArrayFolder
	* SingleFolder
		* SeriesFolder01
			* SeriesCluster01
			* SeriesCluster02
			* SeriesServer01
			* SeriesServer02
			* SeriesServer03
			* SeriesServer04
			* SeriesServer05
		* SeriesFolder02
		* SeriesFolder03
	* ClusterServer
	* SingleCluster
	* SingleServer

## Resource Types

### Login

A user can log into the DSM by providing the `ip_address` of the DSM and their username and password to the dellstorageprovisioning class. In Foreman the user can use the `Hidden Value` option to hide sensitive information from other Foreman users in your organization. If the user is using Puppet Apply or Puppet Agent, they will need to store the ip address, username, and password in the main manifest.

### Server Folders

Server Folders can be created or destroyed by providing a Server Folder definition to the dellstorageprovisioning class. Default values for Server Folder properties can be set in the `dellstorageprovisioning::server_folder` subclass. Multiple Server Folders can be created in the same definition with the same properties by either providing multiple folder names in an array, or by specifying a number of folders to be created in a series. Multiple Server Folder definitions can be provided within the `server_folder_definition_array` that is passed to the `dellstorageprovisioning` class. All Server Folders must have unique names. Server Folders and Volume Folders MAY have the same names.
The `dellstorageprovisioning` class will create Server Folders before creating Servers, (and delete them after), so there are no dependency issues. However, parent folders must be defined before their children.
Servers can be added to folders by listing the `folder_name` in the Server definiton.

Example parameter for `dellstorageprovisioning` class:

```rb
server_folder_definition_array => [{  
	folder_name => ['Parent Folder', 'Other Folder']  
}, {  
	folder_name => 'Folder',  
	num_folders => 5,  
	parent_name => 'Parent Folder',  
}]  
```

This example will create the following directory structure:

* puppet  
	* Parent Folder  
		* Folder01  
		* Folder02  
		* Folder03  
		* Folder04  
		* Folder05  
	* Other Folder  

### Server Clusters

Server Clusters can be created or destroyed by providing a Server Cluster definition to the `dellstorageprovisioning` class. Default values for cluster properties can be set in the `dellstorageprovisioning::server_cluster` subclass. Multiple clusters can be created in the same definition with the same properties by either providing multiple cluster names in the array, or by specifying a number of clusters to be created in a series. Multiple cluster definitions can be provided within the `server_cluster_definition_array` that is passed to the `dellstorageprovisioning` class. All Server Clusters must have unique names. Servers and Server Clusters cannot have the same names. Server Clusters defined in the `server_cluster_definition_array` will always be created before Servers defined in the `server_definition_array`, and deleted after, so there are no dependency issues.

Example paramater for `dellstorageprovisioning` class:

```rb
server_cluster_definition_array => [{  
	num_clusters => 1,  
	cluster_name => 'Cluster',  
	operating_system => 'operating-system-name',  
}]  
```

This `server_cluster_definition_array` will create one Server Cluster named 'Cluster01'.

### Servers

Servers can be created or destroyed by providing a Server definition to the `dellstorageprovisioning` class. Default values for Server properties can be set in the `dellstorageprovisioning::server` subclass. Multiple Server definitions can be provided within the `server_definition_array` that is passed to the `dellstorageprovisioning` class. All Servers must have unique names. Servers and Server Clusters cannot have the same names.
Server Clusters can be created within the `server_definition_array` by setting the `is_server_cluster` parameter to *true*. If there are dependencies between Servers and Server Clusters, the Server Cluster must be defined in the `server_definition_array` before the Server.
HBAs can be added to Servers by either providing values to the `wwn_or_iscsi_name` and `port_type` parameters, or by using the `hba_definition_array`. If creating multiple Servers in one definition, the WWN or iSCSI names must be in an array with one WWN or iSCSI name per Server being created, listed in the same order as the Servers they are to be assigned to.

Example Paramager for `dellstorageprovisioning` class:

```rb
server_definition_array => [{
	num_servers => 1,
	do_not_number => true,
	server_name => 'Cluster',
	is_server_cluster => true,
	operating_system => 'operating-system-name',
}, {
	num_servers => 5,
	server_name => 'Server',
	parent => 'Cluster',
	wwn_or_iscsi_name['1','2','3','4','5'],
	port_type => 'Iscsi',
	operating_system => 'operating-system-name',
}]
```

This `server_definition_array` will create one Server Cluster named 'Cluster' and 5 Servers named 'Server01'-'Server05' with HBAs 1-5. Servers 'Server01'-'Server05' will all be added to the 'Cluster' Server Cluster.

### HBAs

HBAs can be added to or removed from Servers by providing an HBA definition to the `dellstorageprovisioning` class. To remove an HBA, set the `ensure` property to 'absent'. Each definition should include the name of one Server and one WWN or iSCSI name, and the port type. Default values for HBA properties can be set in the `dellstorageprovisioning::hba` subclass. The `dellstorageprovisioning` class will create Servers before attempting to add HBAs, so there are no dependency issues.
HBAs can also be added to Servers by listing the WWN or iSCSI name and port type in the `server_definition_array`.

Example Parameter for `dellstorageprovisioning` class:

```rb
hba_definition_array => [{
	port_type => 'Iscsi',
	wwn_or_iscsi_name => 'iscsi_name',
	server_name => 'Server01',
}, {
	port_type => 'Fiberchannel',
	wwn_or_iscsi_name => 'wwn',
	server_name => 'Server02',
}]
```

This example will add HBAs to both Server01 and Server02.

### Volume Folders

Volume Folders can be created or destroyed by providing a Volume Folder definition to the `dellstorageprovisioning` class. Default values for Volume Folder properties can be set in the `dellstorageprovisioning::volume_folder` subclass. Multiple Volume Folders can be created in the same definition with the same properties by either providing multiple folder names in an array, or by specifying a number of folders to be created in a series. Multiple Volume Folder definitions can be provided within the `volume_folder_definition_array` that is passed to the dellstorageprovisioning class. All Volume Folders must have unique names. Server Folders and Volume Folders MAY have the same names.
The `dellstorageprovisioning` class will create Volume Folders before creating Volumes, and delete them after, so there are no dependency issues. However, parent folders must be defined before their children.
Volumes can be added to folders by listing the `folder_name` in the `volume_definition_array`.

Example parameter for `dellstorageprovisioning` class:

```rb
volume_folder_definition_array => [{
	folder_name => ['Parent Folder', 'Other Folder']
}, {
	folder_name => 'Folder',
	num_folders => 5,
	parent_name => 'Parent Folder',
}]
```

This example will create the following directory structure:

* puppet
	* Parent Folder
		* Folder01
		* Folder02
		* Folder03
		* Folder04
		* Folder05
	* Other Folder

### Volumes

Volumes can be created or destroyed by providing a volume definition to the `dellstorageprovisioning` class. Default values for Volume properties can be set in the `dellstorageprovisioning::volume` subclass. Multiple Volumes can be created in the same definition with the same properties by either providing multiple Volume names in an array or specifying a number of Volumes to be created in a series. Multiple volume definitions can be provided within the `volume_definition_array` that is passed to the `dellstorageprovisioning` class. All Volumes must have unique names.
Volumes can be mapped to Servers at any point by specifying a `server_name` in the `volume_definition_array`, or by using the `mapping_definition_array`.

Example paramater for `dellstorageprovisioning` class:

```rb
volume_definition_array => [{
	num_volumes => 25,
	volume_name => 'Volume',
	server_name => 'Server01',
	size => 100GB,
}]
```

This definition array would create 25 Volumes named 'Volume01'-'Volume25' of size 100GB and map them to 'Server01'.

### Mapping

Volumes can be mapped to (or unmapped from) Servers by providing a mapping definition to the `dellstorageprovisioning` class. To unmap a Volume, set the `ensure` property to 'absent'. Default values for mapping properties can be set in the `dellstorageprovisioning::mapping` subclass. Multiple Volumes can be mapped to the same Server by listing multiple Volume names in the `volume_name_array`. If the Volumes to be mapped are in a numbered series, only the lowest and hightest numbered Volumes need to be listed if `volume_name_array_is_range` is set to *true*. The `dellstorageprovisioning::mapping` subclass will autogenerate the name of each Volume in the specified range.
Volumes can also be mapped to Servers by listing a Server name in the Volume definition.

Example parameter for `dellstorageprovisioning` class:

```rb
mapping_definition_array => [{
	volume_name_array => ["OneVolume", "AnotherVolume", "ThirdVolume"],
	server_name => Server02,
}, {
	volume_name_array => ["ExampleVolume01", "ExampleVolume25"],
	server_name => Server02,
	volume_name_array_is_range => true,
}]
```

This example would map Volumes 'OneVolume', 'AnotherVolume', 'ThirdVolume', and 'ExampleVolume01'-'ExampleVolume25' to 'Server02'.

## Limitations

Puppet works by allowing the user to define a system, and then ensuring that the system exists as defined. Puppet is not designed to work with dynamic data. Because the user cannot define the ID of Storage Center objects before they have been created, Puppet cannot use the ID of a Storage Center object as a unique identifier. For example, the user can indicate that they want their system to include a Volume with instance ID 1, but if such a Volume does not exist it is not possible for Puppet to create it. The user could instead indicate that they want their system to include a Volume with name 'Vol', which would cause Puppet to use the name of the object as a unique identifier instead of the instance ID. Since the Storage Center supports having multiple Storage Center objects of the same type with identical names, this could cause issues and in some cases could lead to the wrong object being deleted.
This module creates a Volume Folder and Server Folder on each Storage Center named 'puppet' in which it creates and destroys all Storage Center objects. This allows Puppet to use the Storage Center object's name as a unique identifier, without risking accidental deletion of the wrong objects.

## Getting Help

For specific issues with the Dell Storage Puppet Module, file a [GitHub Issue](https://github.com/dellstorage/storagecenter-puppet-module/issues).

If you have any suggestions for an improvements, please feel free create a fork in your repository, make any changes, and submit a pull request to have the changes considered for merging. Community collaboration is welcome!

**As a community project, no warranties are provided for the use of this code.**

## License
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
