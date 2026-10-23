#!/bin/bash

source ./common.sh
check_user

#starting rabbitmq installation

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "adding rabbitmq to repo"

dnf install erlang rabbitmq-server -y &>> logs_file
validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> logs_file
validate $? "enabiling rabbitmq"

systemctl start rabbitmq-server &>> logs_file
validate $? "start rabbitmq"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
   rabbitmqctl add_user roboshop roboshop123 &>> logs_file
   validate $? "adding roboshop user"
else
   echo -e "rabbitmq user alerady exist ${Y}SKIPPING${N}"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> logs_file
validate $? "setting permission for roboshop user"

total_time