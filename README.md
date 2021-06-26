# aws3tier
This terraform root module creates a tier infrastructure in the AWS Provider.
1.  main.tf - is a monolithic file for creating vpc, 2 public subnets, a private subnet and a load balancer.
2.outputs.tf - is used to pass the alb ip address.
3.  providers.tf - is used to declare the AWS Provider.
4. variables.tf - is used to declare the various variables instead of hardcording. 
5. apachehttp.sh - bash script that used to bootstrap Apache HTTP Web Server.
6.  nginx.sh - bash script that is used to bootstrap nginx Web Server. 