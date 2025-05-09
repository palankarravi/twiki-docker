FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Retry logic for apt-get
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80retries

# Update package lists with retry logic
RUN apt-get update || (sleep 10 && apt-get update) || (sleep 30 && apt-get update)

# Install packages with retries and fix-missing option
RUN apt-get install -y --fix-missing \
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
    wget \
    unzip \
    ca-certificates

# Try to install libgd-perl separately with retry logic
RUN apt-get install -y --fix-missing libgd-perl || \
    (apt-get update && apt-get install -y --fix-missing libgd-perl) || \
    (echo "Could not install libgd-perl, will continue without it")

# Enable CGI module
RUN a2enmod cgi

# Download TWiki with retry logic
WORKDIR /tmp
RUN wget --tries=5 --timeout=30 --retry-connrefused --waitretry=5 https://sourceforge.net/projects/twiki/files/TWiki%20for%20all%20Platforms/TWiki-6.1.0/TWiki-6.1.0.tgz/download -O twiki.tgz || \
    wget --tries=5 --timeout=30 --retry-connrefused --waitretry=10 https://sourceforge.net/projects/twiki/files/TWiki%20for%20all%20Platforms/TWiki-6.1.0/TWiki-6.1.0.tgz/download -O twiki.tgz

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
