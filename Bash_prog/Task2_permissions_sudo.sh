#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title Task2_permissions_sudo.sh
# @author Damte Hackman Darko
# @index 7356123
# @school Kwame Nkrumah University of Science and Technology (KNUST)
# @description Reports and modifies file permissions and demonstrates sudo usage
# @date 11 September 2026
# -----------------------------------------------------------------

usage() {
    echo "Usage: $0 <file-path>"
    echo "Reports and changes file permissions and demonstrates sudo."
    exit 1
}

# Show help or reject an incorrect number of arguments.
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

FILE="$1"

# Validate that the supplied path is a regular file.
if [[ ! -f "$FILE" ]]; then
    echo "Error: File does not exist or is not a regular file: $FILE" >&2
    exit 1
fi

echo "===== BEFORE PERMISSION CHANGES ====="

# Display symbolic permissions.
echo "Symbolic permissions:"
if ! ls -l "$FILE"; then
    echo "Error: Could not read file permissions." >&2
    exit 1
fi

# Display numeric permissions.
echo "Numeric permissions:"
if ! stat -c "%a" "$FILE"; then
    echo "Error: Could not determine numeric permissions." >&2
    exit 1
fi

echo

# Demonstrate numeric chmod.
echo "Applying numeric chmod: 644"

if chmod 644 "$FILE"; then
    echo "Numeric chmod 644 applied successfully."
else
    echo "Error: Numeric chmod failed." >&2
    exit 1
fi

# Demonstrate symbolic chmod.
echo "Applying symbolic chmod: u+x"

if chmod u+x "$FILE"; then
    echo "Symbolic chmod u+x applied successfully."
else
    echo "Error: Symbolic chmod failed." >&2
    exit 1
fi

echo

# Check whether the script is running as root.
if [[ "$(id -u)" -eq 0 ]]; then
    echo "Running as root."

    # chown is attempted only when root privileges are available.
    if chown "$(id -un):$(id -gn)" "$FILE"; then
        echo "chown completed successfully."
    else
        echo "Error: chown failed." >&2
        exit 1
    fi
else
    echo "Not running as root."
    echo "Skipping chown because root privileges are required."
fi

echo
echo "===== AFTER PERMISSION CHANGES ====="

# Show the resulting permissions.
echo "Symbolic permissions:"
if ! ls -l "$FILE"; then
    echo "Error: Could not read final file permissions." >&2
    exit 1
fi

echo "Numeric permissions:"
if ! stat -c "%a" "$FILE"; then
    echo "Error: Could not determine final numeric permissions." >&2
    exit 1
fi

echo
echo "Task 2 completed successfully."
exit 0
