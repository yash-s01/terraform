######### add key-pair file #############

resource "aws_key_pair" "awskey" {
  key_name = "awskey"
  public_key = file("awskey.pub")
}

########update instance info#########

resource "aws_instance" "tf" {
  ami = "ami-06b72b3b2a773be2b"
  instance_type = var.inst_type
  security_groups = var.sg_inst
  key_name = aws_key_pair.awskey.key_name
  connection { ####### add connection to instance
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

############## echo the public ip of the instance######

  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }
}
