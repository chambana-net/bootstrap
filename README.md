Techops
=======

The various bits and pieces for instantiating [Chambana.net](https://chambana.net). This repository contains all the files necessary to instantiate a single Chambana.net server. **_THIS AND OTHER ASSOCIATED REPOSITORIES ARE AN EFFORT TO DOCUMENT AND STANDARDIZE A LONG-RUNNING HOSTING PROJECT, AND IS PROVIDED AS-IS. IT MAY LOCK YOU OUT OF YOUR BOX AND/OR LIGHT IT ON FIRE._**

Services
--------
* FreeIPA
* Postfix
* Dovecot
* Amavis
* Prosody
* Automatic Nginx/Letsencrypt Proxy
* Several websites

Overview
--------
This repository assumes a single Debian server, operating on the *chambana.net* domain. As of the time of writing, it includes instances of the services above. With the contents of this repository, one can use Saltstack to setup a number of defaults settings. Then, docker-compose can be used to setup the services above. Named persistent volumes for data will be created in ``/var/lib/docker/volumes`` with names prefixed 'chambana_'. Letsencrypt certificates will be automatically generated for all externally facing services, with those certificates being stored in /etc/letsencrypt on the root server. A docker-gen template for nginx is used to automatically configure nginx as a proxy for services running on ports 80 and 443; that template is located in /etc/docker-gen/templates on the root server.

Todo
----
* Webmail
* Monitoring/alerting
* Backups
* Additional documentation

Instructions
------------
1. Install salt-minion on the server. If you're using Debian Jessie, you'll need to add the testing repository in order to get salt-minion 2015.8 or above. It is *highly* recommended that you appropriately pin the testing repository and use ``apt-get install salt-minion/testing`` rather than using the ``-t testing`` option, in order to pull in as few testing dependencies as possible.
2. Copy the files in `files.example/etc/salt` and `files.example/srv/salt` into their corresponding directories on the host.
3. Copy the files in `files.example/srv/pillar` to `/srv/pillar` on the host. Edit `/srv/pillar/cluster.sls` to your liking. Where indicated, you can add SSH keys to login as root, and optionally the login credentials to an external mail relay for system mail.
4. Install ``python-gitfs2`` using the same method as in #1. This is needed for salt-minion to pull directly from github.
5. Edit ``/etc/salt/minion``. Uncomment the line that says ``file_client:`` and change it to ``file_client: local``, which will tell salt-minion to look at local files rather than try and connect to a salt-master.
6. Run ``salt-call state.highstate`` to configure the server using salt. This will take a while to run. If necessary, fix any problems encountered until subsequent runs return that all tasks have been completed successfully.
7. Copy `files.example/etc/chambana` to `/etc/chambana` in order to configure docker-compose. Docker-compose is a developer-oriented tool and so is designed to run out of your current working directory. It also uses the working directory name as the name of your project for the purposes of setting up things like persistant volumes, thus the directory being named 'chambana' in this case.
8. Rename `/etc/chambana/example.env` to `/etc/chambana/.env` and edit it. This contains key=value pairs for different environment variables. This is where you will enter the passwords and other configuration information not contained in this public repository.
9. Run ``docker-compose up -d`` to create and run all defined services. Note that if you haven't run docker previously, it will have to download all necessary docker image layers. Also, some containers may take a while to finish initializing. In particular, freeipa has a lengthy install process, and dovecot can take a long while to generate ssl-parameters before it begins to work the first time.
10. Prosody and Postfix both need to bind to FreeIPA in order to do lookups. Take a look at http://www.freeipa.org/page/EJabberd_Integration_with_FreeIPA_using_LDAP_Group_memberships to see how to do that (that tutorial is for ejabberd, but the process for creating system accounts is the same).
11. One of the containers has the ability to provide SSH logins and userdir-style (i.e., `http://example.com/~user/`) web directories for your top-level site (in this configuration, http://chambana.net). If you wish to make use of this functionality, add users and SSH keys to the YAML file in `/etc/chambana/users.yml`.
11. Enjoy!

Tips & Tricks
-------------
* You'll have to comment the line from ``docker-compose.yml`` for dovecot where the ssl-parameters.dat file is mounted into the container for first start-up, otherwise dovecot will not run. After first start-up, use ``docker cp`` to copy the ``/var/lib/dovcot/ssl-parameters.dat`` file to ``/etc/dovecot/ssl-parameters.dat`` on the host and uncomment that line. In subsequent start-ups, it will re-use the parameters and avoid the lengthy initialization process.
* You can enter a container with ``docker exec -it <container name> bash``, but keep in mind that many tools may not be available and changes made to files not mounted as volumes will not persist past the life of the container.
* A properly configured container with persistent volumes can be both stopped and removed, then recreated with docker-compose, without losing any data. Containers should be stateless, or only use external state in the form of volumes.
* Docker does not do its own garbage collection. If space starts filling up, you'll need to remove dangling images. This can be done with the command ``docker rmi $(docker images -f "dangling=true" -q)``, but be careful. A similar operation may be needed for dangling volumes, but be careful not to remove named volumes!
* Named volumes should be the only thing that really needs to be saved and backed up. You can find them in ``/var/lib/docker/volumes``, and they are prefixed with the name of the project (in this case, 'chambana.net').
