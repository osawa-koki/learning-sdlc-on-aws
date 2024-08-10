#!/bin/bash

cd /home/ec2-user/ec2-user
pip3 install -r requirements.txt
nohup uvicorn main:app --host 0.0.0.0 --port 80 &
