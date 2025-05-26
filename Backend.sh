#!/bin/bash

USERID=$(id -u)

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


# Create log directory if not exists
LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

# Validate Functions 
VALIDATE(){
   if [ $1 -ne 0 ]
    then 
        echo -e "$2.....$R Failure $N"
        exit 1
    else
        echo -e "$2.....$G Success $N"
    fi 
}


    
CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo "Error :: You Must be root user to run this script"
    exit 1 #other than 0
fi
}

echo "Script Started Executing at : $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT



sudo dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling NodeJS Module"

sudo dnf install nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"


# Create logs folder if not exists
id expense &>> $LOG_FILE_NAME
if [ $? -ne 0]
    then 
    useradd expense &>>LOG_FILE_NAME
    VALIDATE $? "Adding Expense User"
else
    echo -e "expense user already exist.......$Y SKIPPING $N"
fi
# Create logs folder if not exists -p
mkdir -p /app 


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading Backend Application"

cd /app

#old code delete -rf * = everything in app directory
rm -rf /app/* 


unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping Backend Application"
 


npm install &>> $LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/expense-shel/backend.service /etc/systemd/system/backend.service &>> $LOG_FILE_NAME

#prepare mysql schema



dnf install mysql -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.sai3.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE_NAME
VALIDATE $? "Creating MySQL Schema & Tables"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Reloading Systemd Daemon"


systemctl enable backend &>> $LOG_FILE_NAME
VALIDATE $? "Enabling Backend Service"

systemctl restart backend &>> $LOG_FILE_NAME
VALIDATE $? "Starting Backend Service"






