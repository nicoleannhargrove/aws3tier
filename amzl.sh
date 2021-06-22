#!/bin/bash

#!/bin/bash

sudo yum update -y
sudo yum install -y httpd.x86_64
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo echo -e '<html>\n<html>\n\t<body>\n\t\t<h1>Congratulations!  This is coming from amazon linux 2:</h1>\n\t</body>\n</html>'$(hostname -f) > /var/www/html/index.html
