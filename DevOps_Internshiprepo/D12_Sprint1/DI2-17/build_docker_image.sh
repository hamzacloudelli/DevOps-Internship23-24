#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo docker build -t di217 .
cat ~/password.txt | sudo docker login --username hamzakhan1o1 --password-stdin
sudo docker tag di217 hamzakhan1o1/di2-17
sudo docker push hamzakhan1o1/di2-17
sudo docker run -dp 80:80 hamzakhan1o1/di2-17