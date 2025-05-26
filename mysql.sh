#!bin/bash

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

dnf install mysql-server -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Enabling MySQL Service"

systemctl start mysqld &>> $LOG_FILE_NAME
VALIDATE $? "Starting MySQL Service"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Securing MySQL Installation"

