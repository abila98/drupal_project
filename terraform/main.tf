resource "aws_vpc" "aws_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "aws_vpc"
  }
}

resource "aws_subnet" "aws_subnet" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    name = "aws_subnet"
  }
}

resource "aws_internet_gateway" "aws_ig" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    name = "aws_ig"
  }
}

resource "aws_route_table" "aws_route_table" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_ig.id
  }
  tags = {
    name = "aws_route_table"
  }
}

resource "aws_route_table_association" "aws_route_table_assoc" {
  subnet_id      = aws_subnet.aws_subnet.id
  route_table_id = aws_route_table.aws_route_table.id
}

resource "aws_security_group" "aws_secuirity_group" {
  name        = "secuity_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "aws_secuirity_group"
  }
}

resource "aws_network_interface" "aws_ni" {
  subnet_id       = aws_subnet.aws_subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.aws_secuirity_group.id]
}



resource "aws_eip" "aws_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.aws_ni.id
  associate_with_private_ip = "10.0.1.10"
  depends_on                = [aws_internet_gateway.aws_ig]
}


resource "aws_instance" "workspace" {
  ami = "ami-04505e74c0741db8d"
  # subnet_id = aws_subnet.subnet-1.id
  key_name      = "aws-vscode-key"
  instance_type = "t2.micro"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.aws_ni.id
  }

  # OS amazon linux 
  # user_data = <<-EOF
  #               #!/bin/bash
  #               yum update -y
  #               yum install polkit* -y
  #               yum install git -y
  #               yum install ant -y
  #               amazon-linux-extras install ansible2 -y
  #               yum install docker -y
  #               systemctl enable docker.service
  #               mkdir -p /nps/apps
  #               chown -R ec2-user:ec2-user /nps
  #               EOF


user_data = <<-EOF
#!/bin/bash
apt-get update -y

apt-get install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install jenkins

apt install git -y
systemctl start jenkins
systemctl enable jenkins

apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

EOF

  tags = {
    Name = "workspace"
  }
}