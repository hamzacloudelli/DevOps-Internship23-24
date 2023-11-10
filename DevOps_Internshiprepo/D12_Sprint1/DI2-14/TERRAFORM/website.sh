    #!/bin/bash
    sudo yum update -y
    sudo yum install ec2-instance-connect
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker pull nginx
    sudo docker run -d -p 80:80 nginx