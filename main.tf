
#Create Custom VPC
resource "aws_vpc" "tvpc" {
  cidr_block       = var.vpccb
  instance_tenancy = "default"
  tags = {
    Name = "Tutorial VPC"
  }
}

#Create Public Subnet 1 for Availability Zone 1
resource "aws_subnet" "tsnwebsrv" {
  vpc_id            = aws_vpc.tvpc.id
  availability_zone = var.az1
  cidr_block        = var.pubsubnetcbaz1
  tags = {
    Name = "Tutorial Public Subnet 1"
  }
}

#Create Public Subnet  for Availability Zone 2
resource "aws_subnet" "tsnappsrv" {
  vpc_id            = aws_vpc.tvpc.id
  availability_zone = var.az2
  cidr_block        = var.pubsubnetcbaz2
  tags = {
    Name = "Tutorial Public Subnet 2"
  }
}
#Create RDS MYSQL requires 2 Private Subnets.  Create for az 1&2
resource "aws_subnet" "tsnrdsmysql1" {
  vpc_id            = aws_vpc.tvpc.id
  availability_zone = var.az1
  cidr_block        = var.privsubnetcbaz1
  tags = {
    Name = "Tutorial Private Subnet 3"
  }
}
resource "aws_subnet" "tsnrdsmysql2" {
  vpc_id            = aws_vpc.tvpc.id
  availability_zone = var.az2
  cidr_block        = var.privsubnetcbaz2
  tags = {
    Name = "Tutorial Private Subnet 4"
  }
}

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.tvpc.id
  tags = {
    Name = "Tutorial Internet Gateway"
  }
}

#Creating Public Route Table
resource "aws_route_table" "trtpub" {
  vpc_id = aws_vpc.tvpc.id

  route {
    cidr_block = var.pubroutertblecb
    gateway_id = aws_internet_gateway.tigw.id
  }

  tags = {
    Name = "tpubrt"
  }
}

#Associating public route table to public subnets
resource "aws_route_table_association" "tarta1" {
  subnet_id      = aws_subnet.tsnwebsrv.id
  route_table_id = aws_route_table.trtpub.id
}

resource "aws_route_table_association" "tarta2" {
  subnet_id      = aws_subnet.tsnappsrv.id
  route_table_id = aws_route_table.trtpub.id
}

#Create Security Group for Web Server
resource "aws_security_group" "tsgwebsrv" {
  name        = "tsgWebSrv"
  description = "Inbound/Outbound HTTP"
  vpc_id      = aws_vpc.tvpc.id

  ingress {
    description = "Inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tsgWebSrv"
  }
}

#Create Security Group for Application Server
resource "aws_security_group" "tsgappsrv" {
  name        = "tsgAppSrv"
  description = "Inbound/Outbound Web Server"
  vpc_id      = aws_vpc.tvpc.id

  ingress {
    description = "Inbound Web Server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Outbound Web Server"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tsgAppSrv"
  }
}
#Create Security Group for RDS MYSQL
resource "aws_security_group" "tsgrdsmysql" {
  name        = "tsgRDSMYSQL"
  description = "Inbound/Outbound AppSrv"
  vpc_id      = aws_vpc.tvpc.id

  ingress {
    description = "Inbound AppSrv"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Outbound AppSrv"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tsgRDSMYSQL"
  }
}

#Create Key Pair for Web Server
resource "tls_private_key" "tWebSrvprivkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tWebSrvkp" {
  key_name   = var.key_name_websrv
  public_key = tls_private_key.tWebSrvprivkey.public_key_openssh

  provisioner "local-exec" { # Create a "myWebsrvKey.pem" to your computer!!
    command = "echo '${tls_private_key.tWebSrvprivkey.private_key_pem}' > ./mywebsrvKey.pem"
  }
}

#Create WebSrv EC2 instance
resource "aws_instance" "tWebSrv" {
  count                       = var.counter
  ami                         = var.ami_id_ubuntu
  instance_type               = var.inst_type
  availability_zone           = var.az1
  vpc_security_group_ids      = [aws_security_group.tsgwebsrv.id]
  subnet_id                   = aws_subnet.tsnwebsrv.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tWebSrvkp.key_name
  user_data                   = file("ubuntu.sh")

  tags = {
    Name = "tWebSrv${count.index}"
  }
}

#Create Key Pair for Web Server
resource "tls_private_key" "tAppSrvprivkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tAppSrvkp" {
  key_name   = var.key_name_appsrv
  public_key = tls_private_key.tAppSrvprivkey.public_key_openssh

  provisioner "local-exec" { # Create a "myappsrv.pem" to your computer!!
    command = "echo '${tls_private_key.tAppSrvprivkey.private_key_pem}' > ./myappsrvKey.pem"
  }
}

#Create AppSrv EC2 instance
resource "aws_instance" "tAppSrv" {
  count                       = var.counter
  ami                         = var.ami_id_amzl
  instance_type               = var.inst_type
  availability_zone           = var.az2
  vpc_security_group_ids      = [aws_security_group.tsgappsrv.id]
  subnet_id                   = aws_subnet.tsnappsrv.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tAppSrvkp.key_name
  user_data                   = file("amzl.sh")

  tags = {
    Name = "tAppSrv${count.index}"
  }
}

#Create Application Load Balancer
resource "aws_lb" "talb" {
  name               = "talb"
  internal           = "false"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tsgwebsrv.id]
  subnets            = [aws_subnet.tsnwebsrv.id, aws_subnet.tsnappsrv.id]

  tags = {
    Name = "t-alb"
  }
}

#Create alb target group
resource "aws_lb_target_group" "ttgalb" {
  name     = "ttgalb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tvpc.id
}

#Attach Web Server Target Group to ALB
resource "aws_lb_target_group_attachment" "ttgattachalbwebsrv" {
  count            = var.counter
  target_group_arn = aws_lb_target_group.ttgalb.arn
  target_id        = aws_instance.tWebSrv[count.index].id
  port             = 80

  depends_on = [
    aws_instance.tWebSrv[1]
  ]
}

#Attach Application Server Target Group to ALB
resource "aws_lb_target_group_attachment" "ttgattachalbappsrv" {
  count            = var.counter
  target_group_arn = aws_lb_target_group.ttgalb.arn
  target_id        = aws_instance.tAppSrv[count.index].id
  port             = 80

  depends_on = [
    aws_instance.tAppSrv[1]
  ]
}

#Create ALB Listener
resource "aws_lb_listener" "tlalb" {
  load_balancer_arn = aws_lb.talb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ttgalb.arn
  }
}

#Create RDS MYSQL
resource "aws_db_instance" "tinstrdsmysql" {
  allocated_storage      = var.trdsmysql_instance.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.trdsmysqlsng.id
  engine                 = var.trdsmysql_instance.engine
  engine_version         = var.trdsmysql_instance.engine_version
  instance_class         = var.trdsmysql_instance.instance_class
  name                   = var.trdsmysql_instance.name
  username               = var.trdsmysqluser_information.username
  password               = var.trdsmysqluser_information.password
  skip_final_snapshot    = var.trdsmysql_instance.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.tsgrdsmysql.id]
}

resource "aws_db_subnet_group" "trdsmysqlsng" {
  name       = "main"
  subnet_ids = [aws_subnet.tsnrdsmysql1.id, aws_subnet.tsnrdsmysql2.id]

  tags = {
    Name = "T RDS MY SQL subnet group"
  }
}
