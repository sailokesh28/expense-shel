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



dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling NodeJS Module"

dnf install nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing NodeJS"


useradd expense &>> $LOG_FILE_NAME
VALIDATE $? "Creating Expense User"

mkdir /app &>> $LOG_FILE_NAME
VALIDATE $? "Creating Application Directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading Backend Application"

cd /app

unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzipping Backend Application"



npm install &>> $LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/expese-shell/backend.service /etc/systemd/system/backend.service &>> $LOG_FILE_NAME

#prepare mysql schema



dnf install mysql -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.sai3.online -u root -pExpenseApp@1 < /app/schema.sql &>> $LOG_FILE_NAME
VALIDATE $? "Creating MySQL Schema & Tables"

systemctl daemon-reload &>> $LOG_FILE_NAME
VALIDATE $? "Reloading Systemd Daemon"

systemctl start backend &>> $LOG_FILE_NAME
VALIDATE $? "Starting Backend Service"

systemctl enable backend &>> $LOG_FILE_NAME
VALIDATE $? "Enabling Backend Service"




