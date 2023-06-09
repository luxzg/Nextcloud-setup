# Nextcloud-setup
Guides, scripts and configs to help install and setup Nextcloud 26.

Please see guide's [Introduction](https://github.com/luxzg/Nextcloud-setup/blob/main/%23guide.md#Introduction) for more details.

## Guide
Complete guide is now hosted [here](https://github.com/luxzg/Nextcloud-setup/blob/main/%23guide.md) in this very repository, as a markdown file.

## List of files
- #guide.md - the complete guide
- 00-installer-config.yaml - Netplan configuration with static IP
- config.php - Nextcloud config, for v26, with everything from the guide
- crontab-root - crontab contents of the "root" user
- crontab-www-data - crontab contents of the "www-data" user
- fstab - permanent mount for btrfs data drive, and bind for appdata
- mysql.cnf - mysql configuration for RAM utilization
- nextcloud.conf - Apache config for NExtcloud site (including HTTPS/SSL, HTTP2, HSTS, etc)
- nextcloud.duckdns.org.conf - ACME.sh configuration for Nextcloud site's certificate
- php.ini - changes to PHP.ini
- redis.conf - changes to Redis configuration
- snapper-ncdata - snapper config for ncdata btrfs volume
- suspend_until.sh - script ran by crontab to suspend server each night & wake it each morning
