#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
domain_name="testdevops.sbs"
script_dir=$(dirname "$(realpath "$0")")

echo "script execution started at $(date +"%F %T")"

check_user(){
    if [ $user_id -ne 0 ]; then
    echo "user $USER is not having sudo access"
    fi
}
mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then
       echo -e "$2..${R}FAILED${N}" | tee -a $logs_file
    else
       echo -e "$2..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

app_setup(){
    id roboshop &>> $logs_file
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
    else
    echo -e "system user is already added ${Y}SKIPPING${N}"
    fi

    rm -rf /app &>> $logs_file
    validate $? "removing files under app directory"

    mkdir -p /app &>> $logs_file
    validate $? "creating app directorey"

    curl -L -o /tmp/$app_name.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip &>>logs_folder
    validate $? "downloading $app_name"

    cd /app
    unzip /tmp/$app_name.zip &>> $logs_file
    validate $? "unzipping $app_name"
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $logs_file
    validate $? "disabiling nodejs"

    dnf module enable nodejs:24 -y &>> $logs_file
    validate $? "enable nodejs"

    dnf install nodejs -y &>> $logs_file
    validate $? "installing nodejs"

    npm install &>> $logs_file
    validate $? "installing dependencies"
}

java_setup(){
    
    dnf module enable maven:3.9 -y &>> $logs_file
    validate $? "enable maven 3.9"

    dnf install maven java-25-openjdk-devel -y &>> $logs_file
    validate $? "install java 25"

    alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
    validate $? "Setting Java 25 as default Java version"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "Setting JAVA_HOME for maven"

    mvn clean package &>> $logs_file
    validate $? "installing dependencies"

    mv target/shipping.jar shipping.jar
    validate $? "moving shipping.jar file"
}

python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $logs_file
    validate $? "installing python 3.14"

    python3.14 -m venv /app/.venv &>> $logs_file
    validate $? "creating virtual environment"

    /app/.venv/bin/pip install -r requirements.txt &>> $logs_file
    validate $? "isnatlling dependencies"
}

systemd_setup(){
    sed -i "s/DOMAIN_NAME/$app_name/g" "$script_dir/$app_name.service"
    cp "$script_dir/$app_name.service" /etc/systemd/system/$app_name.service

    systemctl daemon-reload &>> $logs_file
    validate $? "reloading demon"

    systemctl enable $app_name &>> $logs_file
    validate $? "enable $app_name"

    systemctl start $app_name &>> $logs_file
    validate $? "starting $app_name"
}

restart(){
    systemctl restart $app_name &>> $logs_file
    validate $? "restarting $app_name"
}

total_time(){
    echo "$(timestamp) [INFO]=====Toatal seconds taken by script $SECONDS=====" | tee -a $logs_file
    echo "$(timestamp) [INFO]=====Script execution completed=====" | tee -a $logs_file
}