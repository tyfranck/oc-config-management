## Quickstart

- Requires a recent version of Ansible
- Expects Debian 8, Ubuntu 16.04, or CentOS 7 or newer (depending on packaging)

These playbooks deploy a full Opencast cluster, from packages.  To use them, first edit the `hosts` inventory file
to contain the hostnames of the machines on which you want Opencast deployed, and edit `group\_vars/all.yml` to set any
parameters you might want.  Prior to running the playbook you need to install the dependency roles.  This can be done
with:

	ansible-galaxy install -r requirements.yml

Then run the playbook, like this:

	ansible-playbook -K -i hosts opencast.yml

When the playbook run completes, you should be able to see Opencast on port 80, on the target machines.

This playbook is *not* meant to deploy production machines as is, instead use it to form the basis of a playbook which
better matches your local needs and infrastructure.

## Detailed Docs

#### Hosts

To begin, we first must first change the hosts file to match our environment.  Each play (e.g: [fileserver]) can have
between zero and N hosts associated with it.  A given host can also be associated with multiple playbooks.  In the 
default file we see that the admin.example.org host will play the role of the fileserver, mysql server, and admin node.
We also see that the ingest playbook has no hosts associated - that means that it will not be used.  These scripts do
not have a way to define dependencies between playbooks, which means (as an example) that you can deploy a cluster
without an admin node.  Keep this in mind when defining your host environment!  At this point, please change the hosts
to match your environment.

Host list requirements:
 - `fileserver`: Exactly 1 host.  With 2 or more hosts only the first will be used, with 0 hosts you will encounter errors.
 - `mariadb`: Exactly 1 host.  With 2 or more hosts only the first will be used, with 0 hosts you will encounter errors.
 - `activemq`: Exactly 1 host.  With 2 or more hosts only the first will be used, with 0 hosts you will encounter errors.
 - `allinone`, `admin`, `adminworker`, `adminpresentation`: At most 1 host in all of these groups combined.  The admin 
   node used by the cluster is defined by the _first_ entry of the `admin_node` group.  This means that if you define an
   a host under `admin`, and a host under `adminworker` then the cluster will use the host under `admin`.
 - `allinone`, `presentation`, `adminpresentation`: At most 1 host in all of these groups combined.  The presentation
   node used by the cluster is defined by the __first__ entry of the `presentation_node` group.  This means that if you
   define a host under `presentation`, and a host under `adminpresentation` then the cluster will use the host under
   `presentation`.
 - `allinone`, `worker, `adminworker`: At least 1 host in at least one of these groups.  There are no outright errors if
   you deploy a cluster without any workers, but Opencast will be unable to process any recordings.  In general this is
   a useless configuration, unless you are strictly testing configuration files.

Configuration Hints:
 - The most common production configuration is a single admin, single presentation, and N workers.
 - Decide where you want your admin and presentation nodes first.  Once media has been processed, it's very difficult
   to change the admin and presentation hostnames.
 - Opencast uses the hostname as defined in the hosts file.  Use the externally resolvable name (ie, admin.example.org,
   rather than just admin), otherwise you will encounter problems in the future.

#### Variables

Most variables are exposed in the `group\_vars/all.yml` and `group\_vars/opencast.yml` files.  These should be well
documented, so please take a look.


#### Known issues for production use

 - These playbooks ship with the default upstream Opencast credentials.  These *must* be changed for production use.
 - ActiveMQ is left in a world-connectable state.  Setup a firewall between your ActiveMQ node and the untrusted network.
 - NFS is restricted to the hosts involved in the playbook, but does not have any other security in place and is running
   in versino 3.
 - HTTPS configuration is possible, however these playbooks do not cover setting up and issuing certificates.

### Ideas for Improvement

Here are some ideas for ways that these playbooks could be extended:

 - Enable Solr clustering for relevant services
 - Enable Elastic Search server clustering for relevant services
 - Add security to various installed services to prevent them from being world accessible (see above)
 - Multiple tenant support
 - Error checking for group settings.  You can define insane configurations such as multiple admin nodes, or clusters
   without ActiveMQ.

### Advanced Usage

The playbook contains tags, which cause Ansible to only execute part of the full playbook.  These tags are currently:

 - `config`, which updates all of the configuration files created by this playbook, then restarts Opencast.
 - `uninstall`, which removes the Opencast packages, but does not remove the data.
 - `reset`, which removes _all_ Opencast user data, but leaves the packages installed.  This is only useful for testing
   situations, and will happily wipe out your production data without further prompting.
