#!/bin/bash
set -ex
dnf install -y httpd --allowerasing
systemctl enable httpd

# Fetch Backend Data
BACKEND_URL="http://${backend_dns}"
RESPONSE="Backend unavailable (Timeout)"

echo "<h1>Frontend Server - $(hostname -f)</h1>" > /var/www/html/index.html
echo "<h2>Backend Response:</h2><pre>$RESPONSE</pre>" >> /var/www/html/index.html