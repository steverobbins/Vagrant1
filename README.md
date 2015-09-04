Vagrant Box 1
===

* IP Address: 192.168.50.101
* Hostname:   192.168.50.101.xip.io

This box uses rewrites to dynamically serve the document root.  I.e:

* foo.192.168.50.101.xip.io -> /var/www/html/foo
* bar.192.168.50.101.xip.io -> /var/www/html/bar

etc.  No additional configurations or service restarts needed.

# What you get

* Ubuntu 14.04.2
* Nginx 1.4.6
* MySQL 5.6.19
* PHP 5.5.9
  * ionCube Loader 4.7.5
  * Xdebug 2.2.3
* Redis 2.4.10

# Installation

```
mkdir ~/Project
git clone https://github.com/steverobbins/Vagrant1.git ~/Project/Vagrant1
cd ~/Project/Vagrant1
vagrant up
```