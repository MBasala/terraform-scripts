# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "example-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-gateway"
  }
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-route-table"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

# Create a security group
resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 8080 # Gerrit web UI
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 29418 # Gerrit SSH
    to_port     = 29418
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53 # DNS server
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # OpenIPA HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 # OpenIPA HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 389 # OpenIPA LDAP
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 636 # OpenIPA LDAPS
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000 # Git cluster
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c798c7" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "my_key_pair"

  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id              = aws_subnet.example.id

  tags = {
    Name = "example-instance"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/my_key_pair.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user",
    ]
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  acl    = "private"

  tags = {
    Name = "example-bucket"
  }
}

