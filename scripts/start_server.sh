#!/bin/bash
echo "Starting Java app"
nohup java -jar /home/ubuntu/app/myapp.jar > /home/ubuntu/app/app.log 2>&1 &
