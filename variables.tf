variable "region" {
  type    = string
  default = "us-east-1"
}
variable "az1" {
  type    = string
  default = "us-east-1a"
}
variable "az2" {
  type    = string
  default = "us-east-1b"
}
variable "vpccb" {
  type    = string
  default = "10.0.0.0/16"
}
variable "pubsubnetcbaz1" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pubsubnetcbaz2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "privsubnetcbaz1" {
  type    = string
  default = "10.0.3.0/24"
}
variable "privsubnetcbaz2" {
  type    = string
  default = "10.0.4.0/24"
}

variable "pubroutertblecb" {
  type    = string
  default = "0.0.0.0/0"
}

variable "counter" {
  type    = number
  default = 1

}

variable "ami_id_ubuntu" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}

variable "ami_id_amzl" {
  type    = string
  default = "ami-0d5eff06f840b45e9"
}

variable "inst_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name_websrv" {
  type    = string
  default = "websrvkname"
}

variable "key_name_appsrv" {
  type    = string
  default = "appsrvkname"
}

#Create RDS MYSQL variables
variable "trdsmysql_instance" {
  type = map(any)
  default = {
    allocated_storage   = 10
    engine              = "mysql"
    engine_version      = "8.0.20"
    instance_class      = "db.t2.micro"
    name                = "mydb"
    skip_final_snapshot = true
  }
}

#Create RDS MYSQL sensitive variables
variable "trdsmysqluser_information" {
  type = map(any)
  default = {
    username = "rdsmysqladmin"
    password = "password"
  }
  sensitive = true
}



