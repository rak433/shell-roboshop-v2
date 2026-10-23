#!/bin/bash
app_name=shipping

source ./common.sh
check_user
app_setup
java_setup

dnf install mysql -y &>> $logs_file
validate $? "installing mysql client"

count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
if [ -z "$count" ] || [ "$count" -ne 0 ]; then
   mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
   validate $? "Loading shipping data"
else
   echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi

mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating APP user"

systemd_setup

restart
total_time