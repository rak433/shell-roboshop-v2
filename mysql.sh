#!/bin/bash

source ./common.sh
check_user

#installing mysql

dnf module enable mysql:8.4 -y &>> $logs_file
validate $? "enabiling mysql"

dnf install mysql-server -y &>> $logs_file
validate $? "installing mysql-server"

systemctl enable mysqld &>> $logs_file
validate $? "enable mysqld"

systemctl start mysqld &>> $logs_file
validate $? "starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logs_file
validate $? "setup mysql root password"

total_time