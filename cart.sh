#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

PD=$(pwd)

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
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
VALIDATE $? "Downloading cart code"
cd /app
VALIDATE $? "REdirected to app directory"
unzip -o /tmp/cart.zip
VALIDATE $? "Unzip cart code"
npm install 
VALIDATE $? "Install npm"
cp $PD/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying cart service"
systemctl daemon-reload
VALIDATE $? "Daemon reload"
systemctl enable cart
VALIDATE $? "Enable cart service"
systemctl start cart
VALIDATE $? "Start cart service"