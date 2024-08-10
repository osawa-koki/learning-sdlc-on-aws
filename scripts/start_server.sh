#!/bin/bash

cd /home/ec2-user/app
pip3 install -r requirements.txt
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 &
