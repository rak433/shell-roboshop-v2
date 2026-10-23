#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_user(){
    if [ $user_id -ne 0 ]; then
    echo "user $USER is not having sudo access"
    fi
}
mkdir -p $logs_folder

validate(){
    if [ $1 -ne 0 ]; then
       echo -e "$2..${R}FAILED${N}" | tee -a $logs_file
    else
       echo -e "$2..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

echo "script execution started at $(date +"%F %T")"

total_time(){
    echo "$(timestamp) [INFO]=====Toatal seconds taken by script $SECONDS=====" | tee -a $logs_file
    echo "$(timestamp) [INFO]=====Script execution completed=====" | tee -a $logs_file
}