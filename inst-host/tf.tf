resource "aws_key_pair" "awskey" {
  key_name = "awskey"
  public_key = file("awskey.pub")
}
resource "aws_instance" "tf" {
  ami = "ami-06b72b3b2a773be2b"
  instance_type = var.inst_type
  security_groups = var.sg_inst
  key_name = aws_key_pair.awskey.key_name
  connection {
    type = "ssh"
    user = "ec2-user"
    host = self.public_ip
    private_key = file("awskey")
  }
  provisioner "file" {
    source = "./web.sh"
    destination = "/tmp/web.sh"
  }
  provisioner "file" {
    source = "/Users/yashwant/Downloads/build_3"
    destination = "/tmp/build_3"  
  }
   provisioner "remote-exec" {
     inline = [ 
       "sudo chmod +x /tmp/web.sh",
       "sudo /tmp/web.sh"
      ]
   }
  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }
}
