# Nextcloud 26 on Ubuntu 22.04 - setup

## Contents

[Introduction](#Introduction)

[Hardware](#Hardware)

[General idea](#General-idea)

[Ubuntu OS installation](#Ubuntu-OS-installation)

[Ubuntu post-install](#Ubuntu-post-install)

[LAMP (AMP) stack installation](#LAMP-AMP-stack-installation)

[Database creation and setup](#Database-creation-and-setup)

[Optimizing if you have enough RAM](#Optimizing-if-you-have-enough-RAM)

[Nextcloud v26 download](#Nextcloud-v26-download)

[Nextcloud unpack](#Nextcloud-unpack)

[Apache modules and config](#Apache-modules-and-config)

[Check ports](#Check-ports)

[Attach big HDD (8TB) for Data folder](#Attach-big-HDD-8TB-for-Data-folder)

[Nextcloud initial setup](#Nextcloud-initial-setup)

[Log file](#Log-file)

[Appdata](#Appdata)

[Enable metadata](#Enable-metadata)

[Create Nextcloud users](#Create-Nextcloud-users)

[WebDAV settings](#WebDAV-settings)

[Apps](#Apps)

[Embedded (included / built-in / pre-installed) apps](#Embedded-included---built-in---pre-installed-apps)

[Installing NC apps](#Installing-NC-apps)

[Easy installations](#Easy-installations)

[Maps](#Maps)

[MediaDC](#MediaDC)

[Memories](#Memories)

[Music](#Music)

[Preview Generator](#Preview-Generator)

[Recognize](#Recognize)

[TOTP (Two factor authentication)](#TOTP-Two-factor-authentication)

[PhoneTrack & GpxPod](#PhoneTrack-and-GpxPod)

[Mobile app installation](#Mobile-app-installation)

[Crontab setup](#Crontab-setup)

[Nextcloud jobs](#Nextcloud-jobs)

[Preview generate](#Preview-generate)

[DuckDNS and Let's Encrypt (SSL)](#DuckDNS-and-Lets-Encrypt-SSL)

[Memcache (OPcache, APCe, Redis), HTTP2, URL rewrites, etc.](#Memcache-OPcache-APCe-Redis-HTTP2-URL-rewrites-etc)

[BTRFS snapshots](#BTRFS-snapshots)

[MySQL backup](#MySQL-backup)

[Mount USB drive and copy from it](#Mount-USB-drive-and-copy-from-it)

[Copy timestamps](#Copy-timestamps)

[Fix permissions for files](#Fix-permissions-for-files)

[Scan files](#Scan-files)

[After copying new files (e.g. from USB) - the complete procedure!](#After-copying-new-files-eg-from-USB---the-complete-procedure)

[The end](#The-end)

[End notes](#End-notes)

[File versions](#File-versions)

## Introduction

Nextcloud is a solution I've picked for my home server, and mostly for my photo and video archives (90+% of files I store on my drives).

This guide will lead you through complete installation, setup, configuration and tweaking, including Nextcloud v26, database, apps, mobile (companion) apps, and so on.

In a way this is reminder to myself what I did and how I did it, but I've decided to pulish it online becase I've notified that information about Nextcloud is very scattered all around, parts are in official install guide, parts are in their respective app github repos and wikis, parts are in the forums, and so on and on. Hopefully, this is one place to have all in ONE place.

Keep in mind this was written mostly by me and for me, and "me" would be:
- home user
- personal server
- intended for a small household
- mostly used without publishing to web (but ready to do so by simply opening your ports and entering public IP in DNS)
- mostly for photos / videos, notes, and to-do's
- not used for mail/calendar/contacts (I'll keep using what I've used past 20 years)
- Android phone (no iOS guide for smartphone apps, sorry)

It also includes pretty specific hardware setup (nothing special, but still an x86 device, not RPi, no RAID, just 2 drives, SSD for "speed" and HDD for data). Please see next paragraph for more details.

Now when you know where I'm coming from, and what I'm looking for - please proceed! (or not, if you don't feel like it :) )

P.S. One warning though, this guide went from txt in Notepad++, to MS Office Word, to markdown in Nextcloud Notes, and finally to GitHub markdown in this document. While I did my best to make sure all commands were copied and formatted correctly, please double check them before executing. See [end notes](#End-notes) for details

## Hardware

- HP ProDesk 400 G4 SFF PC
- i5 6400 quad-core CPU
- 16GB RAM
- 256GB SATA SSD
- 8TB HDD

Note: I gave up on Raspberry Pi 3B due to 100Mbps ethernet port (big limitation for me).

## General idea

Install OS, latest current Nextcloud, with all prerequisites. Everything goes to SATA SSD for snappy booting, and user experience (not to mention silent execution). HDD device will hold all of the Nextcloud "data", but we will further tweak it to hold only raw files (large photo/video library), while all metadata, thumbnails, logs, app data, and similar will be on speedy and silent SSD. That means that in regular usage (browsing the website, searching for files, browsing photo galleries and similar) we would only be touching files on SSD. Data on HDD would only spin up if we load full-screen photos, start video playbacks, or file uploads/downloads.

## Ubuntu OS installation

Download Ubuntu server ISO from official site: <https://ubuntu.com/download/server>

Burn ISO to USB drive, and boot your new "server" PC from it.

Install Ubuntu 22.04 LTS

Minimal server installation is what we will start with, we will install packages that we need as we go.

We will install OS to the SATA SSD as planned. We want minimum partition of about 100GB.
(That means even a 128GB SATA or M.2 SSD would suffice.)

## Ubuntu post-install

Once OS is up and running, we need to install any updates, and setup static networking, if you haven't done so during installation. Likewise, we need to start installing some basic tools due to minimal server installation.

```
apt update && apt upgrade
apt install nano
apt install inetutils-ping

nano /etc/netplan/00-installer-config.yaml
```

Whole configuration file is available here: [00-installer-config.yaml](https://github.com/luxzg/Nextcloud-setup/blob/main/00-installer-config.yaml)

```
netplan apply

ip a
ping 8.8.4.4
ping www.google.hr

apt install net-tools
apt update && apt upgrade
```

## LAMP (AMP) stack installation

Now that we have working OS, we'll need to install rest of our LAMP stack (Linux - Apache - MySQL/MariaDB - PHP). To do that we execute the following command:

```
apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip
```

Output of that command will be showing you that we'll install many more packages with this one command, not just simply ones listed in command (due to package requirements).

```
The following NEW packages will be installed:

apache2 apache2-bin apache2-data apache2-utils bzip2 file fontconfig-config fonts-dejavu-core fonts-droid-fallback fonts-noto-mono fonts-urw-base35 galera-4 ghostscript gsfonts imagemagick-6-common libaom3
libapache2-mod-php libapache2-mod-php8.1 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libavahi-client3 libavahi-common-data libavahi-common3 libcgi-fast-perl libcgi-pm-perl libclone-perl
libconfig-inifiles-perl libcups2 libdav1d5 libdaxctl1 libdbd-mysql-perl libdbi-perl libde265-0 libdeflate0 libencode-locale-perl libfcgi-bin libfcgi-perl libfcgi0ldbl libfftw3-double3 libfontconfig1 libgd3
libgomp1 libgs9 libgs9-common libheif1 libhtml-parser-perl libhtml-tagset-perl libhtml-template-perl libhttp-date-perl libhttp-message-perl libidn12 libijs-0.35 libio-html-perl libjansson4 libjbig0
libjbig2dec0 libjpeg-turbo8 libjpeg8 liblcms2-2 liblqr-1-0 libltdl7 liblua5.3-0 liblwp-mediatypes-perl libmagic-mgc libmagic1 libmagickcore-6.q16-6 libmagickwand-6.q16-6 libmariadb3 libmysqlclient21 libndctl6
libnuma1 libonig5 libopenjp2-7 libpaper-utils libpaper1 libpmem1 libsnappy1v5 libsodium23 libtiff5 libtimedate-perl liburi-perl liburing2 libwebp7 libwebpdemux2 libwebpmux3 libx265-199 libxpm4 libxslt1.1
libzip4 lsof mailcap mariadb-client-10.6 mariadb-client-core-10.6 mariadb-common mariadb-server mariadb-server-10.6 mariadb-server-core-10.6 mime-support mysql-common php-bcmath php-common php-curl php-gd
php-gmp php-imagick php-intl php-mbstring php-mysql php-xml php-zip php8.1-bcmath php8.1-cli php8.1-common php8.1-curl php8.1-gd php8.1-gmp php8.1-imagick php8.1-intl php8.1-mbstring php8.1-mysql
php8.1-opcache php8.1-readline php8.1-xml php8.1-zip poppler-data psmisc rsync socat ssl-cert
```
Confirm with "y" to continue.

Additionally, we'll also install:

```
apt install php-fpm php-fileinfo php-bz2 php-exif imagemagick
```

It should reply something like:

```
The following NEW packages will be installed:

fontconfig hicolor-icon-theme imagemagick imagemagick-6.q16 libcairo2 libdatrie1 libdjvulibre-text libdjvulibre21 libfribidi0 libgraphite2-3 libharfbuzz0b libilmbase25 libjxr-tools libjxr0
libmagickcore-6.q16-6-extra libnetpbm10 libopenexr25 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libthai-data libthai0 libwmflite-0.2-7 libxcb-render0 libxcb-shm0 libxrender1 netpbm
php-bz2 php-fpm php8.1-bz2 php8.1-fpm
```

Confirm with "y" to continue.

## Database creation and setup

Now that we've got blank database installed (MariaDB) we need to create our database and the user that will have access to it, so that Nextcloud can use both as its database backend.
Note that you should change the password before running these commands, this is just an example password.

```
mysql

CREATE USER 'administrator'@'localhost' IDENTIFIED BY 'YourPa55w0rd';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'administrator'@'localhost';
FLUSH PRIVILEGES;

quit;
```

Make sure that database is holding its files on SSD partition.

```
cat /etc/my.cnf | grep datadir
```

### Optimizing if you have enough RAM

Here's some reading materials about Nextcloud databases, server tuning, and MariaDB recommendations:

<https://docs.nextcloud.com/server/20/admin_manual/installation/server_tuning.html>

<https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/linux_database_configuration.html>

*Your /etc/mysql/my.cnf could look like this:*

*...*

<https://mariadb.com/kb/en/mariadb-memory-allocation/>

*If only using InnoDB, set innodb_buffer_pool_size to 70% of available RAM. (Plus key_buffer_size = 10M, small, but not zero.)*

To get DB engine type run the following commands:

```
mysql

MariaDB [nextcloud]>

use nextcloud;
show table status from nextcloud;
```

Output should state in the column "Engine" that type used by MariaDB is "InnoDB". So, to tweak MySQL/MariaDB cache a little, we'll allow it to use as much RAM needed to fit whole database in RAM if necessary.

We will do this by editing the configuration file as suggested, but with bit higher values:

```
nano /etc/mysql/conf.d/mysql.cnf
```

Change these lines in the file:

```
[mysqld]
innodb_buffer_pool_size=3G
innodb_io_capacity=4000
key_buffer_size = 20M
```

Whole configuration file is available here: [mysql.cnf](https://github.com/luxzg/Nextcloud-setup/blob/main/mysql.cnf)

Restart MariaDB server:

```
systemctl restart mariadb
systemctl status mariadb
```

After restart service status should be OK, green, running. But there may still be some errors. To test for these errors, and to check current database size, we enter MySQL client again:

```
mysql

SELECT table_schema AS "Database",
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.TABLES
GROUP BY table_schema;

exit
```

Right now, database is mostly empty. After filling it up (when you're done copying files, indexing, scanning, and such), run this command block (above) again, check database size, then tweak configuration file again as needed. For 4TB of photo/video, fully indexed, with thumbnails, face recognition, and all possible metadata, I'm at about 2.5GB. So 3GB is a nice number, especially as you're unlikely to ever touch all the tables and all the data during normal usage. Remember to check the MySQL service status from time to time (or top), it should show how much memory it uses, if it's at the limit you've set, try giving it another 1GB and check in a few days. With that 2.5GB database, and 3GB limit, I'm still sitting at about 1.5GB used. Your mileage may vary.

## Nextcloud v26 download

Finally, we can get our Nextcloud files to the server! We'll download them, and check against hashes to confirm files aren't corrupted in some way.

```
wget https://download.nextcloud.com/server/releases/latest.tar.bz2

wget https://download.nextcloud.com/server/releases/latest.tar.bz2.sha256
sha256sum -c latest.tar.bz2.sha256 < latest.tar.bz2
wget https://download.nextcloud.com/server/releases/latest.tar.bz2.asc
wget https://nextcloud.com/nextcloud.asc
gpg --import nextcloud.asc
gpg --verify latest.tar.bz2.asc latest.tar.bz2
```

## Nextcloud unpack

Now we will unpack these files to web server's directory, and set permissions as required by Apache.

```
tar -xjvf latest.tar.bz2
cp -r nextcloud /var/www
chown -R www-data:www-data /var/www/nextcloud
```

## Apache modules and config

To make the website active we have to configure Apache server, and Nextcloud site. We will start with HTTP-only configuration, later we will add certificates and the rest.

```
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/nextcloud.conf
nano /etc/apache2/sites-available/nextcloud.conf
```
Edit config file by pointing it to your document root:
```
DocumentRoot /var/www/nextcloud/
```
Enable required site and modules, then restart Apache server:
```
a2dissite 000-default.conf
a2ensite nextcloud.conf
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
systemctl reload apache2
systemctl restart apache2
```

## Check ports

To check if website and database are listening to right ports, we will run the following:

```
apt install net-tools

netstat -ntulpe
```

You should see ports : 53 (DNS), 3306 (MySQL/MariaDB), 22 (SSH), 80 (HTTP).

## Attach big HDD (8TB) for Data folder

Nextcloud recommends against moving Data directory later, thus we need to setup our large "data" HDD and folders in advance.

To mount the drive:

```
fdisk -l
```
Note the ```sda``` or similar designation of your new data drive from ```fdisk``` output, and use that in the mount command below:
```
mkdir -p /mnt/purple
mount /dev/sda1 /mnt/purple/
```

To create the folders:

```
mkdir -p /mnt/purple/ncdata/data/
cd /mnt/purple/ncdata/data/
```

We've used BTRFS file system on this drive, but let's check it:

```
btrfs filesystem show /dev/sda1
```

If everything works, then we also want a permanent mount through fstab file:

```
nano /etc/fstab
```

Add these lines to the end of file:

```
# comment: WD Purple HDD
/dev/sda1 /mnt/purple btrfs defaults 0 0
```

Whole configuration file is available here: [fstab](https://github.com/luxzg/Nextcloud-setup/blob/main/fstab)

Reboot the server:

```
reboot
```

And after reboot check if you see new drive mounted at desired path:

```
df -h
```

## Nextcloud initial setup

To setup Nextcloud you have to access the installation webpage through browser, using static IP address of your server. If you've followed the guide, it should simply be on the address like this:

```
http://192.168.0.123/
```

Installer asks for basic data, administrator user, password (generate one yourself), database type, database user and password (one you've created earlier), database location (e.g. localhost), ports, etc.
Input as follows:

```
administrator
<your password>

/mnt/purple/ncdata/data

administrator
<your password>

nextcloud
localhost:3306
```

Click: Install

Once Nextcloud connects to database and is set up, it will take you through the welcome screens, and you're ready!

Do not install all recommended apps (from that list we only want Calendar, Contacts, Mail, Notes).
Alternative is to accept all recommended apps, then disable following: Nextcloud Office, Talk. (These apps require additional servers).

Nextcloud is now functional, but we have a lot to optimize, so that we use our SSD and available RAM to the fullest.

## Log file

We will move log file to SSD. Logs by default won't use more than 1GB in total, so we can place them on SSD.

Create new file and setup correct permissions for Apache:

```
touch /var/log/nextcloud.log
chown www-data:www-data /var/log/nextcloud.log
ll /var/log
```

Now point Nextcloud configuration to the new location, and restart Apache server:

```
nano /var/www/nextcloud/config/config.php
```

Add line:

```
'logfile' => '/var/log/nextcloud.log',
```

Whole configuration file is available here: [config.php](https://github.com/luxzg/Nextcloud-setup/blob/main/config.php)

Restart Apache server:

```
systemctl restart apache2
```

After using Nextcloud a little, remember to check if log is filling up correctly in the new location.

```
ll /var/log
tail /var/log/nextcloud.log
```

## Appdata

We will also move "appdata" folder from the HDD to SSD. Largest portion of this data will be thumbnails, I have about 64GB in "appdata" for about 4TB of files, and file count in "appdata" has crossed 1 million. That's 65KB per file, and classic HDD don't like reading randomly, so that's where SSD will help bigtime.

Stop the Apache (and thus Nextcloud):

```
systemctl stop apache2
```

Copy all data to new location, and check it's all there:

```
cp -a /mnt/purple/ncdata/data/appdata_<instanceid>/. /var/www/nextcloud/appdata
ll /mnt/purple/ncdata/data/appdata_<instanceid>/
ll /var/www/nextcloud/appdata/
```

If everything is in new location you can remove the data from HDD:

```
cd /mnt/purple/ncdata/data/appdata_<instanceid>/
rm -r *
ll
```

And mount the binding permanently through fstab, similar as before:

```
nano /etc/fstab
```

Add these lines to the end of file:

```
# permanent bind for appdata directory on SSD
/var/www/nextcloud/appdata /mnt/purple/ncdata/data/appdata_<instanceid> none bind 0 0
```

Save file, then use this to mount everything configured in fstab:

```
mount -a
```

Exit and re-enter directory `appdata_<instanceid>`, check it shows all data again, then reboot whole server just in case, to check it auto-mounts after reboot. After reboot check same directory again with something like:

```
ll /mnt/purple/ncdata/data/appdata_<instanceid>
```

## Enable metadata

We want to make sure that metadata is enabled in config.php

You may check official documentation if you'd like to enable anything else in the process: <https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html>

```
nano /var/www/nextcloud/config/config.php
```

Add line:

```
'enable_file_metadata' => true,
```

Whole configuration file is available here: [config.php](https://github.com/luxzg/Nextcloud-setup/blob/main/config.php)

## Create Nextcloud users

We also want to create some users which we can use to both test and setup everything. You can do this in this page:

```
http://192.168.0.123/index.php/settings/users
```

You need to enter username, name as will be shown to others, and email address (e.g., `myusername, xyz@gmail.com` )

## WebDAV settings

Once you have your user, you should login and go to Files app, and "Files settings", to get WebDAV URL:

```
http://192.168.0.123/remote.php/dav/files/myusername
```

You also want to click on the avatar of the user, then Settings, Security, scroll down to "Devices & sessions". Type in "App name" = "webdav", then click "Create new app password". Web page will show you username and password, such as:

```
myusername
aa234-bb456-cc789-dd123-ee345
```

Make sure to copy it to safe place, then click "Done" to save it. We will use it later for mobile app sync.

## Apps

### Embedded (included - built-in - pre-installed) apps

A wide range of apps are pre-installed with Nextcloud 26, and these include:

Auditing / Logging, Brute-force settings, Collaborative tags, Comments, Contacts Interaction, Default encryption module, Deleted files,External storage support, Federation, File sharing, First run wizard, LDAP user and group backend, Monitoring, Nextcloud announcements, Password policy, Privacy, Recommendations, Share by mail, Suspicious Login, Support, Update notification, Usage survey, User status, Versions, Weather status.

Some of these are disabled by default, and you may wish to check what they offer and enable them as needed.

Likewise, some of them are ENABLED by default, but they don't offer much in functionality and can be disabled. For example, as a home user, I've disabled Federation, Nextcloud announcements, Privacy, Recommendations, Share by mail, Support, Usage survey, User status.

I've also left Auditing, Encryption, External storage, and LDAP disabled.

### Installing NC apps

To install apps, which act as a sort of add-ons for Nextcloud, you should visit your local instance as administrator user (whichever username you've picked during Nextcloud installation), then click administrator's avatar at top-right, and pick link to "Apps", or simply go to URL like this (modify to your own IP):

```
http://192.168.0.123/index.php/settings/apps
```

All Nextcloud apps can also be browsed on their website:

<https://apps.nextcloud.com/>

Or sorted by names: <https://apps.nextcloud.com/?order_by=name&ordering=asc>

### Easy installations

These apps are simple click to install from Apps admin page, and no need to actually setup anything after it:

Activities for shared file downloads: <https://apps.nextcloud.com/apps/files_downloadactivity>

Activity: <https://github.com/nextcloud/activity/>

Audio Player: <https://apps.nextcloud.com/apps/audioplayer>

Calendar: <https://apps.nextcloud.com/apps/calendar>

Camera RAW Previews: <https://apps.nextcloud.com/apps/camerarawpreviews>

Checksum: <https://apps.nextcloud.com/apps/checksum>

Circles: <https://github.com/nextcloud/circles>

Contacts: <https://apps.nextcloud.com/apps/contacts>

Custom menu: <https://apps.nextcloud.com/apps/side_menu>

Dashboard: <https://github.com/nextcloud/dashboard>

Deck: <https://apps.nextcloud.com/apps/deck>

Group folders: <https://apps.nextcloud.com/apps/groupfolders>

Keeweb: <https://apps.nextcloud.com/apps/keeweb>

Link editor: <https://apps.nextcloud.com/apps/files_linkeditor>

Log Reader: <https://github.com/nextcloud/logreader>

Mail: <https://apps.nextcloud.com/apps/mail>

Metadata: <https://apps.nextcloud.com/apps/metadata>

Notes: <https://apps.nextcloud.com/apps/notes>

Notifications: <https://github.com/nextcloud/notifications>

PDF viewer: <https://github.com/nextcloud/files_pdfviewer>

Photo Sphere Viewer: <https://apps.nextcloud.com/apps/files_photospheres>

Photos: <https://github.com/nextcloud/photos>

README.md: <https://apps.nextcloud.com/apps/files_readmemd>

Related Resources: <https://github.com/nextcloud/related_resources/>

Right click: <https://github.com/nextcloud/files_rightclick>

Tasks: <https://apps.nextcloud.com/apps/tasks>

Text: <https://github.com/nextcloud/text>

Transfer: <https://apps.nextcloud.com/apps/transfer>

Zipper: <https://apps.nextcloud.com/apps/files_zip>

Next up are apps that require some additional post-install steps.

### Maps

<https://apps.nextcloud.com/apps/maps>

Once this app is installed it's recommended to run a file scan from the terminal:

```
sudo -u www-data php /var/www/nextcloud/occ maps:scan-photos
```

### MediaDC

<https://apps.nextcloud.com/apps/mediadc>

Prerequisite: <https://apps.nextcloud.com/apps/cloud_py_api>

App to find duplicate files. After installation and before creating and starting any jobs, go to administrator account, Settings, MediaDC, and set "Hashing algorithm" to "phash". I have similarity set to 90, hash size to 16, no exclude list, and maximum of 4 simultaneous tasks.

After that is set up, as your normal user you can point it to e.g., target directory "Photos" and Mime type "Photos" with 90% similarity, and let it run. Once done it will show you all the duplicates or possible duplicates, and you can go through them manually to delete what's not needed. Note: it will mark very similar photos together, e.g., burst shot where only small details change will be grouped together.

### Memories

<https://apps.nextcloud.com/apps/memories>

Once this app is installed it's recommended to run a file scan from the terminal:

```
sudo -u www-data php /var/www/nextcloud/occ memories:index
```

### Music

<https://apps.nextcloud.com/apps/music>

Once this app is installed it's recommended to register additional MIME types, and run a file scan from the terminal:

```
sudo -u www-data php /var/www/nextcloud/occ music:register-mime-types
sudo -u www-data php /var/www/nextcloud/occ music:scan --all
```

### Preview Generator

<https://apps.nextcloud.com/apps/previewgenerator>

After installing it you also need to add some settings in the configuration file:

```
nano /var/www/nextcloud/config/config.php
```

Add following block:

```
  'enable_previews' => true,
  'preview_concurrency_new' => 1,
  'preview_max_x' => 1440,
  'preview_max_y' => 1440,
  'preview_ffmpeg_path' => '/usr/bin/ffmpeg',
  'enabledPreviewProviders' =>
   array (
    0 => 'OC\\Preview\\TXT',
    1 => 'OC\\Preview\\MarkDown',
    2 => 'OC\\Preview\\OpenDocument',
    3 => 'OC\\Preview\\StarOffice',
    4 => 'OC\\Preview\\MSOffice2003',
    5 => 'OC\\Preview\\MSOffice2007',
    6 => 'OC\\Preview\\MSOfficeDoc',
    7 => 'OC\\Preview\\PDF',
    8 => 'OC\\Preview\\Postscript',
    9 => 'OC\\Preview\\Image',
   10 => 'OC\\Preview\\XBitmap',
   11 => 'OC\\Preview\\Photoshop',
   12 => 'OC\\Preview\\Illustrator',
   13 => 'OC\\Preview\\JPEG',
   14 => 'OC\\Preview\\PNG',
   15 => 'OC\\Preview\\BMP',
   16 => 'OC\\Preview\\GIF',
   17 => 'OC\\Preview\\SVG',
   18 => 'OC\\Preview\\TIFF',
   19 => 'OC\\Preview\\Movie',
   20 => 'OC\\Preview\\MP4',
   21 => 'OC\\Preview\\M4V',
   22 => 'OC\\Preview\\AVI',
   23 => 'OC\\Preview\\MOV',
   24 => 'OC\\Preview\\QT',
   25 => 'OC\\Preview\\MKV',
   26 => 'OC\\Preview\\MTS',
   27 => 'OC\\Preview\\M2TS',
   28 => 'OC\\Preview\\TS',
   29 => 'OC\\Preview\\HEIC',
   30 => 'OC\\Preview\\WMV',
   31 => 'OC\\Preview\\ASF',
   32 => 'OC\\Preview\\3GP',
   33 => 'OC\\Preview\\WEBM',
   34 => 'OC\\Preview\\VOB',
   35 => 'OC\\Preview\\MP3',
   36 => 'OC\\Preview\\EPS',
   37 => 'OC\\Preview\\ICO',
   38 => 'OC\\Preview\\PS',
   39 => 'OC\\Preview\\WMF',
   40 => 'OC\\Preview\\WEBP',
   41 => 'OC\\Preview\\FLV',
   42 => 'OC\\Preview\\RAW',
  ),
```

Whole configuration file is available here: [config.php](https://github.com/luxzg/Nextcloud-setup/blob/main/config.php)

Restart Apache server after configuration changes:

```
systemctl restart apache2
```

Now, your instance is still empty, so this should run pretty fast, but this scan will be quick.

```
sudo -u www-data php /var/www/nextcloud/occ preview:generate-all -vvv
```

But once you start adding files in large batches, make sure to index every folder as you finish copying. That will take a while, so you can limit the task to a single folder/path, such as:

```
sudo -u www-data php /var/www/nextcloud/occ preview:generate-all -vvv --path "/myusername/files/Photos/"
```

Later we will go through the whole process of indexing newly copied files.

### Recognize

<https://apps.nextcloud.com/apps/recognize>

There are quite a few options to set with this app after installation, but luckily defaults work as well. Once installed, again as administrator, go to administrator avatar, Settings, then under Administration go to Recognize.

In the list you can enable different scans, I've used only face recognition, no object, audio or video tagging.

At the bottom you can leave CPU cores at "0", and hopefully you will see green banner at Tensor WASM mode saying:

*Your machine supports native TensorFlow operation, you do not need WASM mode.* (So, leave WASM disabled.)

I had to force download of learning models:

```
sudo -u www-data php /var/www/nextcloud/occ recognize:download-models
```

And after that the settings page should show Status and Image tagging with green banners as well.

To start initial scan, run the following commands:

```
sudo -u www-data php /var/www/nextcloud/occ recognize:classify
sudo -u www-data php /var/www/nextcloud/occ recognize:cluster-faces
```

Again, as with preview generator, your instance should be empty, so scan should finish quickly. But as we fill up the data drive, we'll need to process data in one big scan, or simply wait for background jobs to slowly crawl everything. Unfortunately, there's no "path" option to scan single folders, so you may need to run the scan overnight.

### TOTP (Two factor authentication)

<https://apps.nextcloud.com/apps/twofactor_totp>

I simply love this app. If you're about to open up your server to the dangers of public Internet, you'd want to secure it. And having 2FA (two factor authentication) is one big step against brute forcing and script kiddies.

App is actually pre-installed, you just need to Enable it as administrator, then login as your user, go to your avatar at top-right, Settings, Security. In Two-Factor Authentication you should enable TOTP, which will show you QR code. Use any TOTP app, scan QR code, and - you're now secure! Just don't forget to generate and save your backup codes, in case that 2FA app fails on you. There is a whole list of free and proprietary TOTP mobile apps compatible with this app, and includes both free/open-source lesser known apps, and heavyweights like Google and Microsoft Authenticator.

### PhoneTrack and GpxPod

<https://apps.nextcloud.com/apps/phonetrack>

& <https://apps.nextcloud.com/apps/gpxpod>

These two apps, and the accompanying mobile app, allow you to fetch, log, and save your GPS tracking data, export (and auto-export) to GPX files, and show the saved GPX tracks on variety of maps.

To start tracking you first need a Nextcloud session, so go to PhoneTrack in Nextcloud web app, click "Create session", enter unique name as desired, and click OK. Then click the session in the list underneath, "link" icon for "Links for logging apps" and simply copy "Session token" so you can paste it into mobile app (described in Mobile app section). If you want to view data from this session (recommended to confirm it's working) enable (toggle) the "Watch this session" slider. When device starts logging it should appear in this same page inside session, and then you can also use "Toggle lines" and "Center map on device" icons to find it and see its tracking history.

In GpxPod you can use "Add directories" to add folder to which PhoneTrack auto-exports GPX files, then select the sessions, use "Zoom to boundaries" to get a fix on it on map, and so on.

## Mobile app installation

Official Nextcloud mobile app is available from the Play Store and F-Droid:

<https://play.google.com/store/apps/details?id=com.nextcloud.client&pli=1> or

<https://f-droid.org/en/packages/com.nextcloud.client/>

This is main official app, and other apps use its account management. So, when you login to Nextcloud app, other apps like Notes, Deck and PhoneTrack can use the same account.

But I've had issues with photo sync (maybe because I had 7k files to sync), so I've switched to WebDAV for syncing photos and videos:

<https://play.google.com/store/apps/details?id=de.maza.zpush>

In ZPush I've setup job like this:

```
Local directory to push: DCIM/Camera
Include Filter: *.jpg, *.mp4
Driver: WebDAV
Host ip or Hostname: 192.168.0.123:80
Username: <app username from WebDAV section>
Password: <app password from WebDAV section>
Target path: /remote.php/dav/files/myusername/InstantUpload/Camera
```

You get target path by looking at the WebDAV URL from "Files settings", and username and password we've created with "App password", all explained in WebDAV section. Rest of the URL after `myusername` is simply your subfolders of choice, I've actually used folders created by official Nextcloud mobile app, to make it easier to switch apps if needed.

Once we setup SSL remember to change the job settings to switch HTTP port :80 to HTTPS port :443 and enable SSL.

As mentioned earlier, I use few more apps for specific functions:

Notes & Deck, both for note taking, to-do tasks, planning, reminders and similar.

Nextcloud Notes: <https://f-droid.org/en/packages/it.niedermann.owncloud.notes/>

Nextcloud Deck: <https://f-droid.org/en/packages/it.niedermann.nextcloud.deck/>

If you have 2FA enabled you'll also want to install some authenticator app, like Google Authenticator or Microsoft Authenticator, or one of the apps hosted on F-Droid marketplace.

Finally, there's also GPS tracking app PhoneTrack that is needed to capture and sync GPS info from phone into its counterpart PhoneTrack Nextcloud app, from the same author:

<https://f-droid.org/en/packages/net.eneiluj.nextcloud.phonetrack/>

You will need to setup a session in Nextcloud, then replicate those settings in phone app as log job, e.g.:

```
Title: walk
Nextcloud address: [https://nextcloud.duckdns.org](https://nextcloud.duckdns.org/)
Session token: <from session settings in Nextcloud app>
Device name: My Phone
Preconfigured profiles: Walk profile
```

Then enable the job and let it gather info and sync.

## Crontab setup

Now when all apps are setup, we should enable cron for background jobs. We need to install it, and make an entry for the Apache (www-data) user as follows:

```
apt install cron
```

### Nextcloud jobs

We need to add a cron job that will be running every 5 minutes (default by Nextcloud docs), which will take care about all background jobs in your Nextcloud instance.

```
crontab -u www-data -e
```

Add line:

```
*/5  *  *  *  * php -f /var/www/nextcloud/cron.php
```

To check the changes run:

```
crontab -u www-data -l
```

### Preview generate

We need another crontab entry for generation of thumbnails / previews:

```
crontab -u www-data -e
```

Add line:

```
*/30  *  *  *  * php /var/www/nextcloud/occ preview:pre-generate
```

Confirm changes again:

```
crontab -u www-data -l
```

Whole configuration file is available here: [crontab-www-data](https://github.com/luxzg/Nextcloud-setup/blob/main/crontab-www-data)

## DuckDNS and Let's Encrypt (SSL)

To get started with HTTPS (SSL) we need a domain, and to get a free domain I've chosen DuckDNS. Choice wasn't random - they are well known, free, privacy conscious, easy to register, allow local Ips, no need to manually renew, offer 5 free domain names, and best of all - also offer automatization with Let's Encrypt DNS proof. Local IP and integration with Let's Encrypt for DNS proofs was must have, as I don't publish my Nextcloud online, yet I want SSL, and I want them automated.

As an example I'll use: *nextcloud.duckdns.org*

I also use another domain let's call it *public.duckdns.org* which is setup on my router and provides automatic updates to DuckDNS for that domain. At the same time, the *nextcloud.duckdns.org* domain is set to static local IP and is never updated.

When we have DuckDNS subdomain registered, we need to fetch few things:

- DuckDNS token from your DuckDNS account
- DuckDNS domain you've registered e.g., *nextcloud.duckdns.org*
- And a script that will help us setup certificate for free:

```
curl https://get.acme.sh | sh -s email=xyz@gmail.com

export DuckDNS_Token="1122aabb-1234-5678-abcd-123467890aabb"
acme.sh --insecure --issue --dns dns_duckdns -d nextcloud.duckdns.org
```

At this point just wait a few minutes. You will know it's finished when it tells you where your certificates are:

```
Your cert is in: /root/.acme.sh/nextcloud.duckdns.org_ecc/nextcloud.duckdns.org.cer
Your cert key is in: /root/.acme.sh/nextcloud.duckdns.org_ecc/nextcloud.duckdns.org.key
The intermediate CA cert is in: /root/.acme.sh/nextcloud.duckdns.org_ecc/ca.cer
And the full chain certs is there: /root/.acme.sh/nextcloud.duckdns.org_ecc/fullchain.cer
```

Now we need to attach those certificates to Apache site configuration:

```
cd /etc/apache2/sites-available/
nano nextcloud.conf
```

For example:

```
<VirtualHost *:443>
ServerName nextcloud.duckdns.org
SSLCertificateFile /etc/ssl/certs/nextcloud.duckdns.org.cer
SSLCertificateKeyFile /etc/ssl/private/nextcloud.duckdns.org.key
SSLCertificateChainFile /etc/apache2/ssl.crt/nextcloud.fullchain.cer
SSLCACertificateFile /etc/apache2/ssl.crt/nextcloud.ca.cer
```

Whole configuration file is available here: [nextcloud.conf](https://github.com/luxzg/Nextcloud-setup/blob/main/nextcloud.conf)

Soft-link (symlink) your original files to where Apache expects them, but don't copy/move them because on auto-renewal they will be recreated in the same ```root/.acme.sh``` path as before:

```
ln -s /root/.acme.sh/nextcloud.duckdns.org_ecc/nextcloud.duckdns.org.cer /etc/ssl/certs/nextcloud.duckdns.org.cer
ln -s /root/.acme.sh/nextcloud.duckdns.org_ecc/nextcloud.duckdns.org.key /etc/ssl/private/nextcloud.duckdns.org.key
mkdir /etc/apache2/ssl.crt/
ln -s /root/.acme.sh/nextcloud.duckdns.org_ecc/ca.cer /etc/apache2/ssl.crt/nextcloud.ca.cer
ln -s /root/.acme.sh/nextcloud.duckdns.org_ecc/fullchain.cer /etc/apache2/ssl.crt/nextcloud.fullchain.cer
ll /etc/apache2/ssl.crt/
```

Enable Apache SSL mod, disable HTTP site and enable HTTPS site:

```
a2enmod ssl
a2dissite 000-default.conf
a2dissite default-ssl.conf
```

Change (or add) a trusted domain with new DuckDNS domain name to Nextcloud configuration file:

```
nano /var/www/nextcloud/config/config.php
```

Change lines:

```
'trusted_domains' =>
array (
0 => '192.168.0.123',
1 => 'nextcloud.duckdns.org',
),
```

And restart Apache so it picks up the changes:

```
systemctl restart apache2
```

Now, you can see Chrome doing its usual DNS caching mumbo-jumbo, so you may need or want to erase its cache, disable its internal resolving, etc., so here's a handy Chrome internal URLs for that (works in Chromium and Edge too):

chrome://net-internals/#dns

chrome://flags/#enable-async-dns

I've also had to add my custom domains to DNS allow list of my spam filter, because this domain resolves to local IP which filters don't like. I use NextDNS for my filtering (highly recommended!) so I've added it to the page here:

```
https://my.nextdns.io/<your-id>/allowlist
```

One small but important thing to add for future auto-renewals, option for ACME.sh to restart your Apache.

Go here and edit the file:

```
cd /root/.acme.sh/nextcloud.duckdns.org_ecc
nano nextcloud.duckdns.org.conf
```

Add this line at the configuration file end:

```
Le_ReloadCmd=systemctl restart apache2
```

Whole configuration file is available here: [nextcloud.duckdns.org.conf](https://github.com/luxzg/Nextcloud-setup/blob/main/nextcloud.duckdns.org.conf)

Also, I advise you to check and confirm that crontab job was added for root user, with a line like this (note that time is random):

```
crontab -e
```

Check for line like:

```
36 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
```

Whole configuration file is available here: [crontab-root](https://github.com/luxzg/Nextcloud-setup/blob/main/crontab-root)

This forces ACME.sh script to run every day and renew your certificate if needed. When your cert with Let's Encrypt is close to expiration, script will run, see expiration date, talk to Let's Encrypt, get new tokens, arrange new proof of domain control/ownership via DNS through DuckDNS API, get the updated certificates, place them in your local directory, and Apache will pick these up and use on restart due to symlinks. No work from you, all in the script!

Moment of truth - your local domain should now work with HTTPS and valid SSL certificate!

<https://nextcloud.duckdns.org/>

Note: Chrome and other browsers might still warn you for some pages because this domain resolves to local IP!

## Memcache (OPcache, APCe, Redis), HTTP2, URL rewrites, etc.

Well, this is a large topic. And unfortunately, I lack experience in this field as well. I've mostly just followed instructions from the web, so I'll link the guides and documentation I've used:

Most steps were done based on this guide: <http://www.mailserverguru.com/install-nextcloud-on-ubuntu-22-04-lts/>

For more info you should also consult Nextcloud's official "server tuning" article (FPM, OPcache): <https://docs.nextcloud.com/server/20/admin_manual/installation/server_tuning.html>

Likewise, official Nextcloud article that mentions "Pretty URLs": <https://docs.nextcloud.com/server/20/admin_manual/installation/source_installation.html>

And another Nextcloud article for Redis and file locking: <https://docs.nextcloud.com/server/20/admin_manual/configuration_files/files_locking_transactional.html>

This one also mentions small fix needed when using APCu and OCC CLI commands: <https://github.com/nextcloud/server/issues/27781>

And here's some additional materials for debugging Redis if needed: <https://help.nextcloud.com/t/redis-unix-socket/129153/12>

And from experience, if you test redis with "redis-cli" it will default to TCP port that we will NOT be using, if you want it to target Unix socket you have to specify this with "-s ..." option, e.g.:

```
redis-cli -s /var/run/redis/redis-server.sock ping
```

Tutorial explaining how to enable HTTP2: <https://stegard.net/2022/02/enable-http-2-with-apachephp-on-ubuntu/>

Finally, here are the commands with as little comments as possible, about what you really need to do.

Create PHP info file (optional, this is just to confirm configuration changes):

```
cd /var/www/nextcloud
nano info.php
```

Contents of file:

```
<?php phpinfo(); ?>
```

Set ownership to www-data user and check it:

```
chown www-data:www-data info.php
ll
```

Now configure PHP.ini in all 3 .ini files because we'll be switching from Apache module to FPM + CLI, setting up OPcache, and turning on Redis and ACPu both for the server and the CLI!

```
nano /etc/php/8.1/apache2/php.ini
nano /etc/php/8.1/cli/php.ini
nano /etc/php/8.1/fpm/php.ini
```

Change or add these settings in all 3 .ini files to be the same!

```
	max_execution_time = 3600
	max_input_time = 3600
	memory_limit = 768M
	post_max_size = 10G
	upload_max_filesize = 10G
	
	; OPCACHE SECTION
	opcache.enable=1
	opcache.enable_cli=1
	opcache.memory_consumption=256
	opcache.interned_strings_buffer=16
	opcache.max_accelerated_files=10000
	opcache.revalidate_freq=1
	opcache.save_comments=1
	
	; REDIS SECTION (add at the end)
	redis.session.locking_enabled=1
	redis.session.lock_retries=-1
	redis.session.lock_wait_time=10000
	
	; APC fix for CLI (add at the end)
	apc.enable_cli=1
```

Whole configuration file is available here (just the changes): [php.ini](https://github.com/luxzg/Nextcloud-setup/blob/main/php.ini)

Restart Apache server (it will still not use FPM for now!)

```
systemctl restart apache2
```

Load your info.php page (with phpinfo() command) and confirm that "*opcache.revalidate_freq*" went from default "2" to "1", e.g. <https://nextcloud.duckdns.org/info.php>

Install APCu for PHP 8.1:

```
apt install php8.1-apcu
```

Change settings to enable Pretty URL rewrites, APCu & Redis in Nextcloud configuration file:

```
nano /var/www/nextcloud/config/config.php
```

Changes to config:

```
// settings for pretty URL
  'overwrite.cli.url' => 'https://nextcloud.duckdns.org/',
  'htaccess.RewriteBase' => '/',
// settings for region
  'default_phone_region' => 'HR',
// settings for APCu memcache
  'memcache.local' => '\\OC\\Memcache\\APCu',
// settings for Redis
  'filelocking.enabled' => 'true',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
       'host'     => '/var/run/redis/redis-server.sock',
       'port'     => 0,
       'dbindex'  => 0,
       'password' => '',
       'timeout'  => 0.5,
  ),
```

Save config.php, but don't restart server yet! We need to install Redis first:

```
apt-get install redis-server php-redis
```

Enable service

```
systemctl enable redis-server
```

Open the Redis configuration file:

```
nano /etc/redis/redis.conf
```

Change the following lines to disable TPC port and force using Unix socket (faster and more secure):

```
#port 6379
port 0
unixsocket /var/run/redis/redis-server.sock
unixsocketperm 770
```

Whole configuration file is available here (just the changes, file is really long otherwise): [redis.conf](https://github.com/luxzg/Nextcloud-setup/blob/main/redis.conf)

Make sure to add www-data user to "redis" group so it can communicate over redis socket:

```
usermod -a -G redis www-data
```

or

```
usermod -aG redis www-data
```

Check group membership:

```
grep redis /etc/group
groups www-data
```

(Re)start Redis server:

```
systemctl start redis-server
```

or

```
systemctl restart redis-server
```

Check the service status and that socket is open:

```
systemctl status redis-server
ps -aux | grep redis
ls -l /var/run/redis/redis-server.sock
```

Test socket communication as root and as "www-data" users:

```
sudo -u www-data redis-cli -s /var/run/redis/redis-server.sock ping
redis-cli -s /var/run/redis/redis-server.sock ping
```

Later when you restart Apache / Nextcloud then following command should start showing Redis activity:

```
redis-cli -s /var/run/redis/redis-server.sock MONITOR
```

Enable mod rewrite and env to enable pretty URLs:

```
a2enmod rewrite
a2enmod env
```

Enable automatic (re)write of .htaccess files with OCC command:

```
sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess
```

To enable HTTP2 we have to switch to PHP-FPM which requires going from MPM_PREFORK to MPM_EVENT:

Stop Apache server:

```
systemctl stop apache2
```

Install PHP FPM:

```
apt install php-fpm
```

Disable "Apache" PHP and enable FPM and its requirements:

```
a2dismod php8.1
a2enmod proxy_fcgi setenvif
a2enconf php8.1-fpm
```

Disable PREFORK and enable EVENT:

```
a2dismod mpm_prefork
a2enmod mpm_event
```

Enable HTTP2:

```
a2enmod http2
```

Check Apache configuration:

```
apache2ctl configtest
```

(Re)start Apache server:

```
systemctl start apache2
```

or

```
systemctl restart apache2
```

Restart PHP-FPM:

```
systemctl restart php8.1-fpm
```

Check that CURL had HTTP2 enabled during build (as we need it to test HTTP2 of server):

```
curl -V
```

Now test server with CURL:

```
curl -I --http2 -s https://nextcloud.duckdns.org/login | grep HTTP
```

You can now finally test in browser (Chrome) if Nextcloud website is working, is inspector showing "h2" in network tab (F2, Network, all, Protocol = h2), if URL rewrite is working (no "index.php" visible in the browser address bar), and while doing that check if redis MONITOR shows activity. Hopefully you'll also experience faster browsing as well, though real effects will show up when you server fills up.

# BTRFS snapshots

BTRFS (btrfs) is file system that allows taking snapshots, while not taking up much of your disk space to do it.

To enable the functionality, we'll use application "snapper".

You can read more about using snapper here (note its Arch wiki, not Ubuntu): <https://wiki.archlinux.org/title/snapper>

```
apt install snapper
```

Using snapper you will create configuration file for our large data HDD like this:

```
snapper -c ncdata create-config /mnt/purple
```

When configuration is created, you can (and should) tweak retention settings, defaults are 10-hourly + 10-days + 10-weeks, we want more!

```
nano /etc/snapper/configs/ncdata
```

Change this block; you get 25 hourly backups, 10 daily backups, 5 weeklies, etc.:

```
	# limits for timeline cleanup
	TIMELINE_MIN_AGE="1800"
	TIMELINE_LIMIT_HOURLY="25"
	TIMELINE_LIMIT_DAILY="10"
	TIMELINE_LIMIT_WEEKLY="5"
	TIMELINE_LIMIT_MONTHLY="12"
	TIMELINE_LIMIT_YEARLY="10"
```

Whole configuration file is available here: [snapper-ncdata](https://github.com/luxzg/Nextcloud-setup/blob/main/snapper-ncdata)

Check the list of btrfs volumes, it has to show that ".snapshots" sub-volume created by snapper:

```
btrfs subvolume list /mnt/purple
```

Check disk usage before creating any snapshots, it should stay same even after many snapshots:

```
df -h
```

Sample output:

```
Filesystem Size Used Avail Use% Mounted on
/dev/sda1 7.3T 3.9T 3.5T 53% /mnt/purple
```

Check that snapper services are running and enabled:

```
systemctl status snapper-timeline.timer
systemctl status snapper-cleanup.timer
```

List active snapper configs:

```
snapper list-configs
```

Create one initial permanent snapshot:

```
snapper -c ncdata create --description "First btrfs snapshot with NC26"
```

List snapshots through snapper, it should list your new snapshot:

```
snapper -c ncdata list
```

List snapshots on disk:

```
btrfs subvolume list -s /mnt/purple/
```

You will have to check the list of snapshots in a few hours to make sure they are running on schedule. If they are, with command "snapper -c ncdata list" you should see new "single" snapshot in column "Type" created on each full hour in the column "Date" by the "root" in the column "User", and "Cleanup" and "Description" columns should both say "timeline".

You should also still see that one manually created snapshot with your custom description.

## MySQL backup

While having a resilient file system is nice, we also want to keep a copy of database from SSD drive. So, we'll setup a simple "mysqldump" job in crontab to backup our database, and place a gzipped copy on our btrfs drive (where it will get snapshotted on the next hour).

Create a folder for backups:

```
mkdir /mnt/purple/ncdata/mysqldump
```

Edit crontab:

```
crontab -e
```

Add this to crontab:

```
# cron idea from mysqlbup.cron by josephdpurcell: https://gist.github.com/josephdpurcell/9114079
# mysql backup - rotating Monday-to-Saturday at 4AM - files: nextcloud-day-1.gz to nextcloud-day-6.gz
0 4 * * 1-6 mysqldump --all-databases | gzip > /mnt/purple/ncdata/mysqldump/nextcloud-day-$(date +\%w).gz
# mysql backup - rotating past 4 weeks at 4AM all Sundays except first of month - files: nextcloud-week-0.gz to nextcloud-week-5.gz
# minute=0 hour=3 day=8-31 month=any/all day=0/Sunday
0 4 8-31 * 0 mysqldump --all-databases | gzip > /mnt/purple/ncdata/mysqldump/nextcloud-week-$(expr $(date +\%U) \% 4).gz
# mysql backup - rotating 12 months of the year at 4AM only on first Sunday of the month - files: nextcloud-month-Jan.gz to nextcloud-month-Dec.gz
0 4 1-7 * 0 mysqldump --all-databases | gzip > /mnt/purple/ncdata/mysqldump/nextcloud-month-$(date +\%b).gz
```

Tomorrow you should be checking contents of zipped files, to confirm everything started fine, you can do it with:

```
gzip -l nextcloud-day-1.gz
less nextcloud-day-1.gz
```

Press `q` to quit `less`.

## Mount USB drive and copy from it

I believe it's finally time to fill up your drive with some actual data. If this is your first ever Nextcloud, and it probably is (or you wouldn't be here), then you need to transfer tons of existing data to the server. I suggest doing that by simply connecting USB drives to the server (you can also use USB caddies, or SCP, whichever is faster or more convenient in your situation).

To start create a mount, connect the drive, then check its device name, and mount it as follows:

```
mkdir /mnt/usbdisk
fdisk -l
mount -t ntfs-3g /dev/sdc1 /mnt/usbdisk/
```

Then start a copy that will transfer all your files from your USB drive to temporary folder (example):

```
rsync -rht --ignore-existing --info=progress2 --no-i-r "some folder source"/*  "/mnt/purple/ncdata/data/myusername/files/tmp/some folder destination"
```

Dismount USB drive when done, then disconnect it:

```
cd /mnt
umount /dev/sdc1
```

or

```
umount /mnt/usbdisk
```

### Copy timestamps

If you forgot, do it now!

I had to do some timestamps fixing because I did not copy them in first batch, so we can repeat the copy with extra flags, and don't fear, if data wasn't modified, you'll only see timestamps change, files shouldn't be copied again:

```
rsync -rht --existing --info=progress2 --no-i-r "some folder source"/*  "/mnt/purple/ncdata/data/myusername/files/tmp/some folder destination"
```

vs.

```
cp --preserve=timestamps "some folder source"/*  "/mnt/purple/ncdata/data/myusername/files/tmp/some folder destination"
```

## Fix permissions for files

Files copied as root from USB will probably have "root" as owner and possibly wrong permissions as well, so let's fix them! This seemed like an easy and "smart" way to do some ownership and permission fixing (still logged in as root):

```
chown -R www-data:www-data /mnt/purple/ncdata/data/myusername/files/tmp
find /mnt/purple/ncdata/data/myusername/files/tmp -type d -exec chmod 755 {} \;
find /mnt/purple/ncdata/data/myusername/files/tmp -type f -exec chmod 644 {} \;
```

## Scan files

Whenever you copy files directly from drive to drive, or via SCP, FTP and such, circumventing Nextcloud APIs, you need to make a scan using Nextcloud's OCC tool so it can pick up files and add them to the system.

To scan all files run this command:

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v --all
```

To scan files and metadata run the scan with following option:

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v --all --generate-metadata
```

To scan only single folder (eg. your temp folder with files you've just copied) use „-p" or "--path" option:

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v -p "myusername/files/tmp" --generate-metadata
```

I've encountered a bug that would fail with "generate-metadata", but would run fine if I'd first run the file scan on same folder without that option. It takes extra time to scan twice (without, then again with the option), but that's still better than leaving it in failed state. If you see failed scans that point to exact files, try to remove those files (at least for now), then re-run the scan.

## After copying new files (e.g. from USB) - the complete procedure!

Simply copying files, setting correct permissions, and scanning them is enough to start using them in Nextcloud. But we've installed several apps that do their own scans as well. We can let them do it slowly in the background, as most apps also use cron jobs through Nextcloud APIs to slowly index/crawl/enumerate their files and metadata, but most also have option to run OCC in terminal to speed it up (or force the run). Some also include "path" options, so it's recommended to do the scans while the new files are still in temporary "incoming" folder, then after you do all scans and indexing, move the files using Nextcloud web interface (easy, using Select all and Move actions). That allows you to save time by scanning just one folder (and not whole instance or whole user), yet keeps the gathered data even after moving the files (because we do it through Nextcloud web UI, so Nextcloud will re-link the data in database as needed).

Anyway, let's dig in one last time"

Fix ownership and permissions in folder e.g., "/tmp" (shouldn't last more than few minutes):

```
chown -R www-data:www-data /mnt/purple/ncdata/data/myusername/files/tmp
find /mnt/purple/ncdata/data/myusername/files/tmp -type d -exec chmod 755 {} \;
find /mnt/purple/ncdata/data/myusername/files/tmp -type f -exec chmod 644 {} \;
```

Scan everything (even if it scans everything it will go pretty fast, maybe 10 minutes for existing files, then new):

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v --all
```

As mentioned, we need to scan again for including metadata (this can take an hour or two, make sure to empty trashbin if you've been deleting files in the meantime to avoid re-indexing them in trashbin folder):

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v --all --generate-metadata
```

If you want to scan just a single folder, eg. photos/videos from smartphone synced with Zpush you can scan folder:

```
sudo -u www-data php /var/www/nextcloud/occ files:scan -n -v -p "myusername/files/InstantUpload/Camera" --generate-metadata
```

After `file:scan` ends, we need to scan into Memories app (takes only few minutes):

```
sudo -u www-data php /var/www/nextcloud/occ memories:index
```

Then we scan to Maps app:

```
sudo -u www-data php /var/www/nextcloud/occ maps:scan-photos
```

You could create and/or (re)start task in MediaDC to clean duplicates:

<https://nextcloud.duckdns.org/index.php/apps/mediadc/tasks/1>

Empty trashbin and versions to clear any duplicates you've deleted (really quick):

```
sudo -u www-data php /var/www/nextcloud/occ version:cleanup
sudo -u www-data php /var/www/nextcloud/occ trashbin:cleanup --all-users
```

Now you can generate new thumbnails (speed is about 1 file per second so it takes a lot of time):

```
sudo -u www-data php /var/www/nextcloud/occ preview:generate-all -vvv
```

And finally, the longest task, finding and classifying faces using Recognize app (AI), we do this last as it can take hours, whole night, sometimes whole day as well, depending on number of photos:

```
sudo -u www-data php /var/www/nextcloud/occ recognize:classify
```

When Recognize is done classifying, hopefully without errors, you need to let it group (cluster) the faces to "persons" (people). This can take 30 minutes or more for 100.000 photos:

```
sudo -u www-data php /var/www/nextcloud/occ recognize:cluster-faces
```

And now you're done! You can check new photos in Memories (under Persons, Places or Maps).

If you have used temporary folder for copy/upload, you will want to move the photos. But make sure to do it in Nextcloud web user interface! Otherwise, you'll need to do the whole scan / index / previews / face classify again!

## The end

Not really though. This is a living beast, and I'll probably have more to add over time. Make sure to check this place for updates. I haven't yet really done anything with other files (documents, music, and such), maybe I'll find something of a hidden gems that are worth adding to the guide.

I hope you've learned something new! 😊

## End notes

I did my best to copy/paste all commands, scripts and configs. But in the process of editing, moving to Word, then to markup format, then again to GitHub markup, it's possible I've made formatting mistakes. So please report if you find any!

To avoid any major mistakes I've also created files in this repository for all configuration files, crontab, fstab, and such. Please use those as ***the*** reference. You can find them all here:
<https://github.com/luxzg/Nextcloud-setup>
These were copied directly from the command-line session so they're certainly ok.

### File versions

- 2023-04-10 - First complete version in markup format
- 2023-04-11 - Fixes to adjust for Github markup and table of contents, expanded Introduction and End notes, added links to files in this github repository

