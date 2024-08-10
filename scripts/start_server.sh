#!/bin/bash

echo "cd to app directory" >> /home/ec2-user/server.log
cd /home/ec2-user/app

echo "installing requirements" >> /home/ec2-user/server.log
pip3 install -r requirements.txt

echo "starting server" >> /home/ec2-user/server.log
uvicorn app.main:app --host 0.0.0.0 --port 8000 >> /home/ec2-user/server.log 2>&1 &
