resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# EC2 instance
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  associate_public_ip_address = true
  key_name               = aws_key_pair.app_key.key_name
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = merge(
    {
      Name = "${var.project_name}-ec2"
    },
    var.tags
  )

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.ssh_key.private_key_pem
    }

    inline = [
      "sleep 10",
      "sudo yum update -y",
      "sudo yum install -y docker git",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '\"' -f 4)/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "git clone https://github.com/Yura11/scylladb_simple_app.git",
      "cd scylladb_simple_app",
      "sudo docker-compose up -d"
    ]
  }
}

# Security group
resource "aws_security_group" "app" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 4173
    to_port     = 4173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = merge(
    {
      Name = "${var.project_name}-sg"
    },
    var.tags
  )
}
