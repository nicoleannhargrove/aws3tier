#!/bin/bash

sudo apt update -y && apt upgrade -y
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo chattr -i /var/www
sudo rm -f /var/www/html/index.nginx-debian.html
sudo echo -e '<html>\n<html>\n\t<body>\n\t\t<h1>Congratulations!  This is coming from ubuntu:</h1>\n\t</body>\n</html>'$(hostname -f) > /var/www/html/index.html
