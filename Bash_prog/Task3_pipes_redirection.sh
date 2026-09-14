#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title Task3_pipes_redirection.sh
# @author Damte Hackman Darko
# @index 7356123
# @school Kwame Nkrumah University of Science and Technology (KNUST)
# @description Generates sample logs and demonstrates pipes, redirection and text processing
# @date 11 September 2026
# -----------------------------------------------------------------

usage() {
    echo "Usage: $0"
    echo "Generates sample log data and produces a text-processing summary."
    exit 1
}

# Show help or reject unexpected arguments.
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 0 ]]; then
    usage
fi

LOG_FILE="sample_logs.txt"
RESULTS_FILE="results.txt"
ERROR_FILE="errors.log"

# Generate at least 50 lines of sample log data.
if cat > "$LOG_FILE" <<'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:05 INFO 192.168.1.11 User login successful
2026-09-11 10:00:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:15 ERROR 192.168.1.12 Connection timeout
2026-09-11 10:00:20 INFO 192.168.1.10 File uploaded
2026-09-11 10:00:25 INFO 192.168.1.13 User login successful
2026-09-11 10:00:30 WARN 192.168.1.11 High memory usage
2026-09-11 10:00:35 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:00:40 INFO 192.168.1.10 User logout successful
2026-09-11 10:00:45 INFO 192.168.1.14 File downloaded
2026-09-11 10:00:50 WARN 192.168.1.10 CPU usage above 80%
2026-09-11 10:00:55 ERROR 192.168.1.15 Authentication failed
2026-09-11 10:01:00 INFO 192.168.1.11 User login successful
2026-09-11 10:01:05 INFO 192.168.1.10 File uploaded
2026-09-11 10:01:10 WARN 192.168.1.13 Disk usage above 80%
2026-09-11 10:01:15 ERROR 192.168.1.12 Connection timeout
2026-09-11 10:01:20 INFO 192.168.1.10 User logout successful
2026-09-11 10:01:25 INFO 192.168.1.11 File downloaded
2026-09-11 10:01:30 WARN 192.168.1.10 High memory usage
2026-09-11 10:01:35 ERROR 192.168.1.15 Service unavailable
2026-09-11 10:01:40 INFO 192.168.1.13 User login successful
2026-09-11 10:01:45 INFO 192.168.1.10 File uploaded
2026-09-11 10:01:50 WARN 192.168.1.11 CPU usage above 80%
2026-09-11 10:01:55 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:02:00 INFO 192.168.1.10 User logout successful
2026-09-11 10:02:05 INFO 192.168.1.14 File downloaded
2026-09-11 10:02:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:02:15 ERROR 192.168.1.15 Authentication failed
2026-09-11 10:02:20 INFO 192.168.1.11 User login successful
2026-09-11 10:02:25 INFO 192.168.1.10 File uploaded
2026-09-11 10:02:30 WARN 192.168.1.13 High memory usage
2026-09-11 10:02:35 ERROR 192.168.1.12 Connection timeout
2026-09-11 10:02:40 INFO 192.168.1.10 User logout successful
2026-09-11 10:02:45 INFO 192.168.1.11 File downloaded
2026-09-11 10:02:50 WARN 192.168.1.10 CPU usage above 80%
2026-09-11 10:02:55 ERROR 192.168.1.15 Service unavailable
2026-09-11 10:03:00 INFO 192.168.1.13 User login successful
2026-09-11 10:03:05 INFO 192.168.1.10 File uploaded
2026-09-11 10:03:10 WARN 192.168.1.11 Disk usage above 80%
2026-09-11 10:03:15 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:03:20 INFO 192.168.1.10 User logout successful
2026-09-11 10:03:25 INFO 192.168.1.14 File downloaded
2026-09-11 10:03:30 WARN 192.168.1.10 High memory usage
2026-09-11 10:03:35 ERROR 192.168.1.15 Authentication failed
2026-09-11 10:03:40 INFO 192.168.1.11 User login successful
2026-09-11 10:03:45 INFO 192.168.1.10 File uploaded
2026-09-11 10:03:50 WARN 192.168.1.13 CPU usage above 80%
2026-09-11 10:03:55 ERROR 192.168.1.12 Connection timeout
2026-09-11 10:04:00 INFO 192.168.1.10 User logout successful
2026-09-11 10:04:05 INFO 192.168.1.11 File downloaded
2026-09-11 10:04:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:04:15 ERROR 192.168.1.15 Service unavailable
EOF
then
    echo "Sample log data created: $LOG_FILE"
else
    echo "Error: Could not create sample log data." >&2
    exit 1
fi

# Start a fresh results file.
if : > "$RESULTS_FILE"; then
    echo "Results file prepared: $RESULTS_FILE"
else
    echo "Error: Could not create results file." >&2
    exit 1
fi

# Start a fresh error log.
if : > "$ERROR_FILE"; then
    echo "Error log prepared: $ERROR_FILE"
else
    echo "Error: Could not create error log." >&2
    exit 1
fi

{
    echo "===== LOG ANALYSIS REPORT ====="
    echo

    echo "1. Total number of log lines:"
    wc -l < "$LOG_FILE"

    echo
    echo "2. Count of lines per log level:"
    echo "INFO:"
    grep " INFO " "$LOG_FILE" | wc -l
    echo "WARN:"
    grep " WARN " "$LOG_FILE" | wc -l
    echo "ERROR:"
    grep " ERROR " "$LOG_FILE" | wc -l

    echo
    echo "3. Top 3 most frequent IP addresses:"
    awk '{print $4}' "$LOG_FILE" |
        sort |
        uniq -c |
        sort -nr |
        head -n 3

    echo
    echo "4. ERROR lines:"
    grep " ERROR " "$LOG_FILE"

} > "$RESULTS_FILE" 2> "$ERROR_FILE"

# Check whether the analysis block succeeded.
if [[ $? -eq 0 ]]; then
    echo "Log analysis completed successfully."
else
    echo "Error: Log analysis failed. Check $ERROR_FILE for details." >&2
    exit 1
fi

echo
echo "===== RESULTS ====="
cat "$RESULTS_FILE"

echo
echo "Task 3 completed successfully."
exit 0
