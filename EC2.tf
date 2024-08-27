# Define the security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Security group to allow SSH access"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows access from any IP address
  }
  ingress {
    description = "HTTP access"echo "# Terraform" >> README.md
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP from any IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-066784287e358dad1"
  instance_type = "t2.micro"
  key_name      = "testkey"
  
  # Associate the security group with the EC2 instance
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "myec2instance"
  }

  provisioner "remote-exec" {
     inline = [
      "sudo yum install -y nginx",  # Correct command to install nginx on Amazon Linux 2
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx" # Ensures nginx starts on boot
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Use the correct user for your AMI
    private_key = file("./testkey.pem")
    host        = self.public_ip
  }
}
