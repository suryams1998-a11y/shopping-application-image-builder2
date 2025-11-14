#!/bin/bash

yum install httpd php -y
systemctl restart httpd.service php-fpm.service
systemctl enable httpd.service php-fpm.service
cp -r /tmp/website/* /var/www/html/
chown -R apache:apache /var/www/html/
rm -rf /tmp/website

