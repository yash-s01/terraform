######### add key-pair file #############

resource "aws_key_pair" "awskey" {
  key_name = "/Users/yashwant/terraform/inst-host/awskey"
  public_key = file("/Users/yashwant/terraform/inst-host/awskey.pub")
}

######### fetch the available zones in the region ###########

data "aws_availability_zones" "available" {}

######### fetch ip ranges of a region ##############

data "aws_ip_ranges" "iprange" {
  regions = ["ap-south-1"]
  services = ["ec2"]
}

########## make a custom security group ################

# resource "aws_security_group" "mysg" {
#   name = "mysg"
#   description = "this is my custome sg"
#   ingress = [{
#      description = "for http"
#      from_port = "80"
#      to_port =  "80"
#      protocol = "tcp"
#      cidr_blocks = data.aws_ip_ranges.iprange.cidr_blocks
#      security_groups = [] # Empty list since we're allowing traffic from CIDR blocks
#      self = false        # Whether to allow traffic from this security group itself
#      ipv6_cidr_blocks = [] # Empty list for IPv6 CIDR blocks
#      prefix_list_ids  = [] # Empty list for prefix list IDs
#   },
#   {
#     description = "for https"
#     from_port = "443"
#     to_port = "443"
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     security_groups = [] # Empty list since we're allowing traffic from CIDR blocks
#     self = false        # Whether to allow traffic from this security group itself
#     ipv6_cidr_blocks = [] # Empty list for IPv6 CIDR blocks
#     prefix_list_ids  = [] # Empty list for prefix list IDs
#   },
#   {
#     description = "for ssh"
#     from_port = "22"
#     to_port = "22"
#     protocol = "tcp"
#     cidr_blocks = ["115.246.90.76/32"]
#     security_groups = [] # Empty list since we're allowing traffic from CIDR blocks
#     self = false        # Whether to allow traffic from this security group itself
#     ipv6_cidr_blocks = [] # Empty list for IPv6 CIDR blocks
#     prefix_list_ids  = [] # Empty list for prefix list IDs
#   }]
#   # Outbound rule allowing all traffic to anywhere
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


########update instance info#########

resource "aws_instance" "tf" {
  ami = "ami-06b72b3b2a773be2b"
  instance_type = var.inst_type
  security_groups = var.sg_inst   ####### when you want to give a predefined sg
  //security_groups = ["mysg"]
  availability_zone = data.aws_availability_zones.available.names[1]  ####### specifieng the availability zone to use
  key_name = aws_key_pair.awskey.key_name
  connection {                  ####### add connection to instance
    type = "ssh"
    user = "ec2-user"
    host = self.public_ip
    private_key = file("awskey")
  }

###### add script from local which run after instance creation here for httpd#########

  provisioner "file" {
    source = "./web.sh"
    destination = "/tmp/web.sh"
  }

#######update build folder#########

  provisioner "file" {
    source = "/Users/yashwant/Downloads/build_3"
    destination = "/tmp/build_3"  
  }

########run the script###########

   provisioner "remote-exec" {
     inline = [ 
       "sudo chmod +x /tmp/web.sh",
       "sudo /tmp/web.sh"
      ]
   }

############## echo the public ip of the instance ######

  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }
}
