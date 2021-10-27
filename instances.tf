#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


#Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}


#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet_1.id
  provisioner "remote-exec" { #install apache, mysql client, php
    inline = [
      "sudo mkdir -p /var/www/html/",
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo service httpd start",
      "sudo usermod -a -G apache centos",
      "sudo chown -R centos:apache /var/www",
      "sudo yum install -y mysql php php-mysql",
      ]
  connection {
    type     = "ssh"
    user     = "ignat"
    host     = aws_instance.jenkins-master.public_ip
    private_key = "~/.ssh/id_rsa"
  }
     }
  provisioner "file" { #copy the index file form local to remote
    source      = "index.php"
    destination = "/tmp/index.php"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.php /var/www/html/index.php"
   ]
  }
  tags = {
    Name = "jenkins_master_tf"
  }
  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]
}


resource "aws_db_instance" "my_database_instance" {
    allocated_storage = 20
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    port = 3306
    #vpc_security_group_ids = [aws_security_group.jenkins-sg-oregon.id]
    name = "mydb"
    identifier = "mysqldb"
    username = "myuser"
    password = "mypassword"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot = true
    tags = {
        Name = "my_database_instance"
    }
}
