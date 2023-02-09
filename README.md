# lap-image
Dockerfile to build an image with Linux, Apache and PHP. Including most common optimizations like ModPagespeed, Modsecurity, Memcached, REDIS, Pecl, MSSQL support, and more

# Web Applications
Hosting prefix is /var/www/vhosts, everything goes to there, by security use this folder to place applications.

Define an application name to use, in this example lets use ***default*** as our application name.
 - place your webaplication at www/vhosts/***default***
 - Produce a virtual host configuration apache/vhosts/ORDER-***default***.conf
 - ORDER define how loads first, you are able to have +1
 - extension MUST BE .conf otherwise apache ignores the vhost file
 - You need centralize logs, solve that to troubleshooting and application monitor
 - remember that you application will be placed into the container at /var/www/vhosts/***default***

# Azure Pileline + Azure Container Registry
Remember to setup pipeline build variables:
 - ACR-SERVICE-CONNECTION: The name of the service connection to between your project and ACR you defined
 - ACR-REPOSITORY-NAME: Chose a name to your repository

After that you may access your images as:
`FROM my-acr/repository:branch-name`
