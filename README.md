# Installing TWiki in a Docker Container with Existing Data
If you have existing TWiki data on your host that you want to use in the Docker container, here's how to set it up:

## Prerequisites

Docker installed on your system
Existing TWiki data on your host
Terminal/command line access

# Step-by-Step Installation

Create a project directory
mkdir twiki-docker
cd twiki-docker

## Organize your existing TWiki data
Make sure your existing TWiki data is organized in a structure like this on your host:
/path/to/your/twiki-data/
├── data/
├── pub/
├── templates/ (optional)
└── working/ (optional)

# If you are starting fresh twiki, then start from here


## Modify this file `twiki.conf` with Apache configuration for any customization 
```
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
```

# Build the Docker image
```
docker build -t twiki-docker .
```

# Run the container with mounted volumes
Replace /path/to/your/twiki-data with the actual path to your TWiki data directories:
```
docker run -d -p 80:80 \
  -v /path/to/your/twiki-data/data:/var/www/twiki/data \
  -v /path/to/your/twiki-data/pub:/var/www/twiki/pub \
  -v /path/to/your/twiki-data/templates:/var/www/twiki/templates \
  -v /path/to/your/twiki-data/working:/var/www/twiki/working \
  --name twiki-instance twiki-docker
```
If you only have specific directories to mount, you can adjust the command accordingly, for example:
```
docker run -d -p 80:80 \
  -v /path/to/your/twiki-data/data:/var/www/twiki/data \
  -v /path/to/your/twiki-data/pub:/var/www/twiki/pub \
  --name twiki-instance twiki-docker
```

# Access TWiki setup
---------
If you're using existing data, the configuration should already be set up

Open your web browser and navigate to `http://localhost/bin/view`

----------
Else, 
Open your web browser and navigate to `http://localhost/bin/configure`.

You'll be prompted to create the `LocalSite.cfg` file. Follow the on-screen instructions.
```
Set an admin password when prompted.


Complete the configuration

Configure email settings, user authentication, and other options as needed

Save your configuration
```

## Verify the installation

Navigate to `http://localhost/bin/view`
You should see the TWiki welcome page





## Troubleshooting
Making Sure Your Existing Data Works

Check and fix file permissions if needed
```
docker exec -it twiki-instance bash
ls -la /var/www/twiki/data
ls -la /var/www/twiki/pub
```
If you encounter permission issues
```
docker exec -it twiki-instance bash
chown -R www-data:www-data /var/www/twiki/data
chown -R www-data:www-data /var/www/twiki/pub
```

### Check LocalSite.cfg
Make sure your existing configuration file is properly mounted:
```
docker exec -it twiki-instance bash
cat /var/www/twiki/lib/LocalSite.cfg
```
### Review Apache logs for errors
```docker exec -it twiki-instance bash
cat /var/log/apache2/error.log
```
