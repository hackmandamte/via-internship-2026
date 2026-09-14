#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title Task4_return_codes_error_handling.sh
# @author Damte Hackman Darko
# @index 7356123
# @school Kwame Nkrumah University of Science and Technology (KNUST)
# @description Performs system checks and demonstrates return codes and error handling
# @date 11 September 2026
#
# Exit code scheme:
# 0 = All checks passed
# 1 = Missing or invalid argument
# 2 = Host unreachable
# 3 = Insufficient disk space
# 4 = Required file missing or unreadable
# 5 = Required command not found
# -----------------------------------------------------------------

usage() {
    echo "Usage: $0 <hostname>"
    echo "Checks host reachability, disk space, required file, and required command."
    exit 1
}

# Show usage for help or incorrect arguments.
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

HOST="$1"
TEMP_FILE=$(mktemp)

# Remove temporary files whenever the script exits.
cleanup() {
    rm -f "$TEMP_FILE"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Report the result of each check and exit with its documented code on failure.
check_status() {
    local status="$1"
    local message="$2"
    local exit_code="$3"

    if [[ "$status" -eq 0 ]]; then
        echo "PASS: $message"
    else
        echo "FAIL: $message" >&2
        exit "$exit_code"
    fi
}

echo "===== TASK 4 SYSTEM CHECKS ====="
echo "Target host: $HOST"
echo

# ---------------------------------------------------------------
# CHECK 1: Host reachability
# ---------------------------------------------------------------

ping -c 1 -W 2 "$HOST" >/dev/null 2>&1
STATUS=$?

check_status "$STATUS" "Host $HOST is reachable." 2

# ---------------------------------------------------------------
# CHECK 2: Available disk space
# Requirement: at least 1 GB free on the root filesystem.
# ---------------------------------------------------------------

AVAILABLE_KB=$(df -Pk / 2>/dev/null | awk 'NR==2 {print $4}')
STATUS=$?

if [[ "$AVAILABLE_KB" =~ ^[0-9]+$ ]] && (( AVAILABLE_KB >= 1048576 )); then
    STATUS=0
else
    STATUS=1
fi

check_status "$STATUS" "At least 1 GB of free disk space is available." 3

# ---------------------------------------------------------------
# CHECK 3: Required configuration/data file
# ---------------------------------------------------------------

[[ -r /etc/hosts ]]
STATUS=$?

check_status "$STATUS" "Required file /etc/hosts exists and is readable." 4

# ---------------------------------------------------------------
# CHECK 4: Required command/tool
# ---------------------------------------------------------------

command -v awk >/dev/null 2>&1
STATUS=$?

check_status "$STATUS" "Required command 'awk' is installed." 5

# Write a small value to the temporary file so the trap has
# something to clean up when the script exits.
if echo "Task 4 temporary data" > "$TEMP_FILE"; then
    echo "PASS: Temporary file created successfully."
else
    echo "FAIL: Could not create temporary file." >&2
    exit 1
fi

echo
echo "All checks passed successfully."
echo "Task 4 completed successfully."

exit 0
