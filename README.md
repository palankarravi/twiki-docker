Installing TWiki in a Docker Container with Existing Data
If you have existing TWiki data on your host that you want to use in the Docker container, here's how to set it up:

Prerequisites

Docker installed on your system
Existing TWiki data on your host
Terminal/command line access

Step-by-Step Installation

Create a project directory
mkdir twiki-docker
cd twiki-docker

Organize your existing TWiki data
Make sure your existing TWiki data is organized in a structure like this on your host:
/path/to/your/twiki-data/
├── data/
├── pub/
├── templates/ (optional)
└── working/ (optional)

If you are starting fresh twiki, then start from here

Create a Dockerfile
Create a file named Dockerfile with the following content:
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    perl \
    perl-modules \
    libcgi-pm-perl \
    libalgorithm-diff-perl \
    libarchive-tar-perl \
    libauthen-sasl-perl \
    libencode-perl \
    liberror-perl \
    libfile-copy-recursive-perl \
    libhtml-parser-perl \
    libhtml-tree-perl \
    libio-socket-ssl-perl \
    libnet-smtp-ssl-perl \
    libtext-diff-perl \
    liburi-perl \
    libgd-perl \
    wget \
    unzip

# Enable CGI module
RUN a2enmod cgi

# Download TWiki
WORKDIR /tmp
RUN wget https://sourceforge.net/projects/twiki/files/TWiki%20for%20all%20Platforms/TWiki-6.1.0/TWiki-6.1.0.tgz/download -O twiki.tgz
RUN tar -xzf twiki.tgz

# Move TWiki to web root
RUN mv twiki /var/www/

# Create directories for mounting points (if they don't exist in the base installation)
RUN mkdir -p /var/www/twiki/data
RUN mkdir -p /var/www/twiki/pub
RUN mkdir -p /var/www/twiki/templates
RUN mkdir -p /var/www/twiki/working

# Set permissions (will be overridden by mounted volumes, but good for defaults)
RUN chown -R www-data:www-data /var/www/twiki
RUN chmod -R 755 /var/www/twiki/bin
RUN chmod -R 755 /var/www/twiki/lib
RUN chmod -R 777 /var/www/twiki/data
RUN chmod -R 777 /var/www/twiki/pub
RUN chmod -R 777 /var/www/twiki/templates
RUN chmod -R 777 /var/www/twiki/working

# Configure Apache
COPY twiki.conf /etc/apache2/sites-available/
RUN a2ensite twiki
RUN a2dissite 000-default

# Script to fix permissions on startup
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Start Apache with our custom script
CMD ["/start.sh"]

Create start script to fix permissions
Create a file named start.sh with the following content:
bash#!/bin/bash

# Fix permissions for mounted volumes
chown -R www-data:www-data /var/www/twiki/data
chown -R www-data:www-data /var/www/twiki/pub
chown -R www-data:www-data /var/www/twiki/templates
chown -R www-data:www-data /var/www/twiki/working

# Start Apache
apache2ctl -D FOREGROUND

Create Apache configuration file
Create a file named twiki.conf with the following content:
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/twiki

    ScriptAlias /bin/ "/var/www/twiki/bin/"
    Alias /pub/ "/var/www/twiki/pub/"
    
    <Directory "/var/www/twiki/bin">
        AllowOverride None
        Options +ExecCGI
        Require all granted
        SetHandler cgi-script
    </Directory>

    <Directory "/var/www/twiki/pub">
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

Build the Docker image
docker build -t twiki-docker .

Run the container with mounted volumes
Replace /path/to/your/twiki-data with the actual path to your TWiki data directories:
docker run -d -p 80:80 \
  -v /path/to/your/twiki-data/data:/var/www/twiki/data \
  -v /path/to/your/twiki-data/pub:/var/www/twiki/pub \
  -v /path/to/your/twiki-data/templates:/var/www/twiki/templates \
  -v /path/to/your/twiki-data/working:/var/www/twiki/working \
  --name twiki-instance twiki-docker
If you only have specific directories to mount, you can adjust the command accordingly, for example:
docker run -d -p 80:80 \
  -v /path/to/your/twiki-data/data:/var/www/twiki/data \
  -v /path/to/your/twiki-data/pub:/var/www/twiki/pub \
  --name twiki-instance twiki-docker

Access TWiki

Open your web browser and navigate to http://localhost/bin/view
Since you're using existing data, the configuration should already be set up



Making Sure Your Existing Data Works

Check and fix file permissions if needed
docker exec -it twiki-instance bash
ls -la /var/www/twiki/data
ls -la /var/www/twiki/pub

If you encounter permission issues
docker exec -it twiki-instance bash
chown -R www-data:www-data /var/www/twiki/data
chown -R www-data:www-data /var/www/twiki/pub

Check LocalSite.cfg
Make sure your existing configuration file is properly mounted:
docker exec -it twiki-instance bash
cat /var/www/twiki/lib/LocalSite.cfg

Review Apache logs for errors
docker exec -it twiki-instance bash
cat /var/log/apache2/error.log
