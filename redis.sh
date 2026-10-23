#/bin/bash

source ./common.sh
check_user

#starting redis installation

dnf module disable redis -y &>> $logs_file
validate $? "disabling redis"

dnf module enable redis:7 -y &>> $logs_file
validate $? "enable redis"

dnf install redis -y &>> $logs_file
validate $? "installing redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remote connections to redis"

systemctl enable redis &>> $logs_file
validate $? "enable redis"

systemctl start redis &>> $logs_file
validate $? "start redis"

total_time