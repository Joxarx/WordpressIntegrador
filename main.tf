terraform { 
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.55.0" }
  } 
}

# Define the local variables for the root module
locals {
  ami_id = "ami-08fdec01f5df9998f"
  vpc_id = "vpc-0d57729ffaed6d58b"
  ssh_user = "ubuntu"
  key_name = "wpserver"
  private_key_path = "${path.module}/wpserver.pem"
}

# Uses the AWS provider to setup access
provider "aws" {
  access_key = "ASIAYS2NVGISKL62MF4N"
  secret_key = "yubAAHtJ/PtIC8aagRUieyrogLlX0GfQkXqFoNcZ"
  token = "IQoJb3JpZ2luX2VjEEoaCXVzLXdlc3QtMiJIMEYCIQDSUHnkY8h0xgrKkAL10Jh3SqtUrxQBvE0SsNXZnzuRPgIhAKx/zIX8I5moFgwQoYYBvRN8vFdSot12Tm9+y450Ul/XKq8CCLP//////////wEQABoMNTkwMTg0MDAyMDg0Igz2VQEqxhEc8u1Kpd8qgwIvhoo0eGnyjFH7PTPy8uS4R4wRSR6O8kZe544vrQgYJ5ujUNCvJIMEpsxNGqNES1WaPTB161DQHIgOzN0Fi2u8YFKFEDmXiBWKwjIqTuohlaD4L/ZF6hd3p0NxKNTo8ahD5ueo+J9ykH/r60OD0gk9GC68YmF5dguksMA2N2NCyr7oNV7F4gk2coSpRY745y3QRlm4RT/3AfOYfq0J4/fzaocloNGeZeIYEZ3bOQwdvh2BM9Npi5zX3KVVBcOoQL3oajtHGlljjBzt9qlfK46dgBEhpBTCzLp9W0FaeoCza2evIACiZF1o2vwGE1nBa5He834z7FNdmf3AtCYWy05RqnbEMIfTlbIGOpwBwkWObDu9lUyUKTtKDYva/714jhBm5WwVtkE0NRkBrgmXSvo8Az9wJ1zBW9laT+4k14fBKXVIC8XIZWKMnUqA0LaTG9LV9FmEw300JFy/cKRH2OWknKw4z0px9kjhuvZ97lrgjrZfNq3GB3Nql08Vrp+aYO0PLN+MJhza7TDNE08cOJXc49uuK1cXOsRCHjBQ4yL7SSNI830G9siH"
  region = "us-east-1"
}

# Creates the EC2 Security Group with Inbound and Outbound rules.
resource "aws_security_group" "wpserversg" {
  name = "wpserversg"
  vpc_id = local.vpc_id
	
	# This will allow us to access the HTTP server on Port 80, where our WP will be accessible.
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

	# This will allow us to SSH into the instance for Ansible to do it's magic.
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This creates the EC2 instance and makes an initial SSH connection.
resource "aws_instance" "ec2wpserver" {
  ami = local.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.wpserversg.id]
  key_name = local.key_name

  tags = {
    Name = "WordPress Server"
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = local.ssh_user
    private_key = file(local.private_key_path)
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/demo-file-from-terraform.txt"
    ]
  }
}

# Creating a local hosts file for Ansible to use
resource "local_file" "hosts" {
  content = templatefile("${path.module}/templates/hosts",
    {
      public_ipaddr = aws_instance.ec2wpserver.public_ip
      key_path = local.private_key_path
      ansible_user = local.ssh_user
    }
  )
  filename = "${path.module}/hosts"
}

# We will use a null resource to execute the playbook with a local-exec provisioner.

resource "null_resource" "run_playbook" {
  depends_on = [

    # Running of the playbook depends on the successfull creation of the EC2
    # instance and the local inventory file.

    aws_instance.ec2wpserver,
    local_file.hosts,
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i hosts playbook.yml"
  }
}