#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
mv /tmp/build_3/* /var/www/html/
sudo systemctl restart httpd
