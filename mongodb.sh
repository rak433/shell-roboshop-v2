#!/bin/bash

source ./common.sh
check_user

#installing mongodb

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "creating repo for mongodb"

dnf install mongodb-org -y &>> $logs_file
validate $? "installing mongodb"

systemctl enable mongod &>> $logs_file
validate $? "enable mongodb"

systemctl start mongod &>> $logs_file
validate $? "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "updating remote connections to mongodb"

systemctl restart mongod &>> $logs_file
validate $? "restarting mongodb"

total_time