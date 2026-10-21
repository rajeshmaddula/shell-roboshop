#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"


if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e " $2... $R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$2 ... $G SUCCESS $N" |tee -a $LOGS_FILE
fi
}

for package in $@
do 
  dnf list installed $package &>>$LOGS_FILE
  if [ $? -ne 0 ]; then
     echo "$package is not installed, installing now"
     dnf install $package -y &>> $LOGS_FILE
     VALIDATE $? "$package installation"
      
  else
     echo -e "$Y $package  already installed ,skipping $N"
  fi
done

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb server"

systemctl enable mongod 
VALIDATE $? "Enable mongod"

systemctl start mongod 
VALIDATE $? "Start mongod"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"