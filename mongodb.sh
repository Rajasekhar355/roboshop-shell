#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE
VALIDATE() {
    if [ $1 -ne 0 ] 
    then
        echo "Error:: $2 .... FAILED"
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

cp mongo.repo /etc/yum.repos.d/mongodb-org-4.2.repo &>> $LOGFILE
VALIDATE $? "Copying mongo file"
dnf install mongodb-org -y
VALIDATE $? "Installing MongoDB" &>> $LOGFILE
systemctl enable  &>> $LOGFILE
systemctl start mongod &>> $LOGFILE
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongodb.conf &>>LOGFILE
systemctl restart mongod &>> $LOGFILE
