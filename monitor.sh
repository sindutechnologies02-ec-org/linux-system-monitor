#!/bin/bash

# Thresholds
CPU_THRESHOLD=75
MEM_THRESHOLD=80

LOGFILE="system_report.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
TOP_PROCESSES=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6)
echo "Script ran at $(date)" >> /home/ec2-user/monitor.log

echo "----- $DATE -----" >> $LOGFILE
echo "CPU Usage: $CPU_USAGE%" >> $LOGFILE
echo "Memory Usage: $MEM_USAGE%" >> $LOGFILE
echo "Disk Usage (root): $DISK_USAGE" >> $LOGFILE
echo -e "\nTop 5 Memory-consuming Processes:" >> $LOGFILE
echo "$TOP_PROCESSES" >> $LOGFILE
echo "----------------------------" >> $LOGFILE
echo "" >> $LOGFILE

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )) || (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
    ALERT_MSG="⚠️ High Resource Usage on $(hostname)
    CPU: $CPU_USAGE%
    Memory: $MEM_USAGE%
    Time: $DATE"
    
    echo "$ALERT_MSG" | mail -s "System Alert" your-email@example.com
fi
