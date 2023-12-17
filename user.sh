#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
PD=$(pwd)
MONGO_HOST="3.85.51.213"

echo "Script Started.." &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo "Error:: $2 .... FAILED"
        exit 1
    else
        echo "$2 ... SUCCESS"
    fi
}

if [ $ID -ne 0 ]
then 
    echo "user is not root"
    exit 1
else
    echo "user is root"
fi

dnf module disable nodejs -y &>> $LOGFILE
dnf module enable nodejs:18 -y &>> $LOGFILE
dnf install nodejs -y &>> $LOGFILE

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo "user already added"
fi

mkdir /app
VALIDATE $? "creating app directory"
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "Downloading user code"
cd /app
VALIDATE $? "REdirected to app directory"
unzip -o /tmp/user.zip
VALIDATE $? "Unzip user code"
npm install 
VALIDATE $? "Install npm"
cp $PD/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user service"
systemctl daemon-reload
VALIDATE $? "Daemon reload"
systemctl enable user
VALIDATE $? "Enable user service"
systemctl start user
VALIDATE $? "Start user service"
cp mongo.repo /etc/yum.repos.d/mongodb-org-4.2.repo &>> $LOGFILE
VALIDATE $? "coying mongo repo file"
dnf install mongodb-org-shell -y
VALIDATE $? "ïnstall mongo shell"
mongo --host $MONGO_HOST </app/schema/user.js
