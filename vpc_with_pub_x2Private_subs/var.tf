
variable "accesskey" {
    type = "string"
  
}

variable "secretkey" {
    type = "string"
  
}


variable "imageid" {
    default = "ami-0fc20dd1da406780b"
    description = "ubuntu 18.04"

}

variable "key" {
  default = "jenkins"
}
variable "instancetype" {
    default = "t2.micro"
  
}
variable "region" {
    default = "us-east-2"
}
variable "vpcid" {
  default = "vpc-00a2a368"
}

