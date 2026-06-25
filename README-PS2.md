# Problem Statement 2

## Objective 1: System Health Monitoring Script

This script monitors:

- CPU Usage
- Memory Usage
- Disk Usage
- Running Processes

If CPU, Memory, or Disk usage exceeds predefined thresholds, an alert is displayed on the console.

system_health_monitor.sh
```
#!/bin/bash

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

echo "===== $(date) ====="

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
PROCESS_COUNT=$(ps -e --no-headers | wc -l)

echo "CPU Usage: ${CPU_USAGE}%"
echo "Memory Usage: ${MEM_USAGE}%"
echo "Disk Usage: ${DISK_USAGE}%"
echo "Running Processes: ${PROCESS_COUNT}"

if (( ${CPU_USAGE%.*} > CPU_THRESHOLD )); then
    echo "ALERT: CPU usage exceeds ${CPU_THRESHOLD}%"
fi

if (( MEM_USAGE > MEM_THRESHOLD )); then
    echo "ALERT: Memory usage exceeds ${MEM_THRESHOLD}%"
fi

if (( DISK_USAGE > DISK_THRESHOLD )); then
    echo "ALERT: Disk usage exceeds ${DISK_THRESHOLD}%"
fi
```

### Usage

```bash
chmod +x system_health_monitor.sh
./system_health_monitor.sh
```

## Objective 2: Application Health Checker

This script checks the health of a web application by verifying its HTTP status code.

app_health_checker.sh
```
#!/bin/bash

URL=$1

if [ -z "$URL" ]; then
    echo "Usage: ./app_health_checker.sh <url>"
    exit 1
fi

STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS" -eq 200 ]; then
    echo "Application is UP (HTTP $STATUS)"
else
    echo "Application is DOWN (HTTP $STATUS)"
fi
```
Run:
```
chmod +x app_health_checker.sh

./app_health_checker.sh localhost:4499

```
