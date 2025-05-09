#!/bin/bash

# Fix permissions for mounted volumes
chown -R www-data:www-data /var/www/twiki/data
chown -R www-data:www-data /var/www/twiki/pub
chown -R www-data:www-data /var/www/twiki/templates
chown -R www-data:www-data /var/www/twiki/working

# Start Apache
apache2ctl -D FOREGROUND