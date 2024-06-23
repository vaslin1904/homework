#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`
# Команда logger отправлāет лог в системнýй журнал
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi