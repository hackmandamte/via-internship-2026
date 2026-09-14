#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title Task1_file_handling.sh
# @author Damte Hackman Darko
# @index 7356123
# @school Kwame Nkrumah University of Science and Technology (KNUST)
# @description Creates a directory and performs basic file handling
# @date 11 September 2026
# -----------------------------------------------------------------

usage() {
    echo "Usage: $0 <target-directory>"
    echo "Creates a directory and demonstrates basic file handling."
    exit 1
}

# Check for help or incorrect number of arguments
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

TARGET_DIR="$1"
FILE="$TARGET_DIR/sample.txt"
BACKUP="$FILE.bak"

# Step 1: Create the target directory if it does not exist
if [[ -d "$TARGET_DIR" ]]; then
    echo "Directory already exists: $TARGET_DIR"
else
    if mkdir -p "$TARGET_DIR"; then
        echo "Directory created: $TARGET_DIR"
    else
        echo "Error: Could not create directory: $TARGET_DIR" >&2
        exit 1
    fi
fi

# Step 2: Create the file and write initial content
if echo "This is the initial content." > "$FILE"; then
    echo "File created and initial content written: $FILE"
else
    echo "Error: Could not create or write to $FILE" >&2
    exit 1
fi

# Step 3: Append additional content
if echo "This line was appended later." >> "$FILE"; then
    echo "Additional content appended successfully."
else
    echo "Error: Could not append content to $FILE" >&2
    exit 1
fi

# Step 4: Read and display the file
if [[ -r "$FILE" ]]; then
    echo
    echo "File contents:"
    cat "$FILE"

    if [[ $? -ne 0 ]]; then
        echo "Error: Could not read $FILE" >&2
        exit 1
    fi
else
    echo "Error: File does not exist or is not readable: $FILE" >&2
    exit 1
fi

# Step 5: Create a backup copy
if cp "$FILE" "$BACKUP"; then
    echo "Backup created: $BACKUP"
else
    echo "Error: Could not create backup file." >&2
    exit 1
fi

# Step 6: Check that the original exists before deleting
if [[ -f "$FILE" ]]; then
    echo
    read -r -p "Delete the original file $FILE? [y/N]: " CONFIRM

    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        if rm "$FILE"; then
            echo "Original file deleted successfully."
        else
            echo "Error: Could not delete $FILE" >&2
            exit 1
        fi
    else
        echo "Deletion cancelled. Original file kept."
    fi
else
    echo "Error: Original file does not exist, so it cannot be deleted." >&2
    exit 1
fi

echo
echo "Task 1 completed successfully."
exit 0
