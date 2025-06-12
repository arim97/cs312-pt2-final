provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_vpc" "minecraft" {
  cidr_block = "10.0.0.0/16"
  
}



resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.minecraft.id]

user_data = <<-EOF
              #!/bin/bash
              # Install Java
              sudo yum install -y java-17-amazon-corretto-headless
              
              # Set Java PATH
              echo 'export PATH=$PATH:/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin' | sudo tee -a /home/ec2-user/.bashrc
              source /home/ec2-user/.bashrc

              # Create and configure directory
              sudo mkdir -p /opt/minecraft
              # 1. Set ownership recursively
              sudo chown -R ec2-user:ec2-user /opt/minecraft/

              # 2. Set directory permissions (rwx for owner, r-x for group/others)
              sudo find /opt/minecraft/ -type d -exec chmod 755 {} \;

              # 3. Set file permissions (rw for owner, r for group/others)
              sudo find /opt/minecraft/ -type f -exec chmod 644 {} \;

              cd /opt/minecraft

              # Download server
              wget https://piston-data.mojang.com/v1/objects/84194a2f286ef7c14ed7ce0090dba59902951553/server.jar

              # Create EULA file
              cat > eula.txt <<EOL
              #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
              #$(date)
              eula=true
              EOL

              # First run to generate configs (background process)
              java -Xms1024M -Xmx2048M -jar server.jar nogui &
              SERVER_PID=$!
              sleep 20
              kill $SERVER_PID

              # Systemd service
              sudo tee /etc/systemd/system/minecraft.service >/dev/null <<SERVICE
              [Unit]
              Description=Minecraft Server
              After=network.target

              [Service]
              Type=simple
              User=ec2-user
              WorkingDirectory=/opt/minecraft
              ExecStart=/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java -Xms1024M -Xmx2048M -jar /opt/minecraft/server.jar nogui
              ExecStop=/bin/bash -c "screen -S minecraft -p 0 -X stuff 'stop\\n'"
              Restart=always
              RestartSec=5
              SuccessExitStatus=143

              [Install]
              WantedBy=multi-user.target
              SERVICE

              # Enable service
              sudo systemctl daemon-reload
              sudo systemctl enable minecraft
              sudo systemctl start minecraft
              EOF

  tags = {
    Name = "minecraft-server"
  }
}

resource "aws_security_group" "minecraft" {
  name = "minecraft-sg"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from any IP
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.minecraft.public_ip
}