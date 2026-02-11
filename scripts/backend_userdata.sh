#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "{\"status\": \"success\", \"backend\": \"$(hostname -f)\", \"timestamp\": \"$(date)\"}" > /var/www/html/index.html