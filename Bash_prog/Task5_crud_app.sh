#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title Task5_crud_app.sh
# @author Damte Hackman Darko
# @index 7356123
# @school Kwame Nkrumah University of Science and Technology (KNUST)
# @description A command-line CRUD application for managing records
# @date 11 September 2026
# -----------------------------------------------------------------

DATA_FILE="crud_data.txt"

usage() {
    echo "Usage: $0"
    echo "Starts the command-line CRUD application."
    exit 1
}

# Handle help and incorrect arguments.
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ $# -ne 0 ]]; then
    echo "Error: This script does not accept arguments." >&2
    usage
fi

# Create the data file if it does not exist.
if [[ ! -f "$DATA_FILE" ]]; then
    if ! touch "$DATA_FILE"; then
        echo "Error: Could not create data file." >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------
# CREATE
# ---------------------------------------------------------------

create_record() {
    echo
    echo "===== CREATE RECORD ====="

    read -r -p "Enter ID: " id
    read -r -p "Enter name: " name
    read -r -p "Enter email: " email

    if [[ -z "$id" || -z "$name" || -z "$email" ]]; then
        echo "Error: All fields are required." >&2
        return 1
    fi

    if grep -q "^${id}|" "$DATA_FILE"; then
        echo "Error: A record with ID $id already exists." >&2
        return 1
    fi

    if echo "$id|$name|$email" >> "$DATA_FILE"; then
        echo "Record created successfully."
    else
        echo "Error: Could not save record." >&2
        return 1
    fi
}

# ---------------------------------------------------------------
# READ
# ---------------------------------------------------------------

read_records() {
    echo
    echo "===== ALL RECORDS ====="

    if [[ ! -s "$DATA_FILE" ]]; then
        echo "No records found."
        return 0
    fi

    printf "%-10s %-25s %-35s\n" "ID" "NAME" "EMAIL"
    printf '%s\n' "----------------------------------------------------------------------"

    if ! awk -F'|' '{printf "%-10s %-25s %-35s\n", $1, $2, $3}' "$DATA_FILE"; then
        echo "Error: Could not read records." >&2
        return 1
    fi
}

# ---------------------------------------------------------------
# UPDATE
# ---------------------------------------------------------------

update_record() {
    echo
    echo "===== UPDATE RECORD ====="

    read -r -p "Enter ID of record to update: " id

    if [[ -z "$id" ]]; then
        echo "Error: ID is required." >&2
        return 1
    fi

    if ! grep -q "^${id}|" "$DATA_FILE"; then
        echo "Error: Record with ID $id not found." >&2
        return 1
    fi

    read -r -p "Enter new name: " name
    read -r -p "Enter new email: " email

    if [[ -z "$name" || -z "$email" ]]; then
        echo "Error: Name and email are required." >&2
        return 1
    fi

    TEMP_FILE=$(mktemp)

    if ! awk -F'|' -v id="$id" -v name="$name" -v email="$email" '
        BEGIN { OFS="|" }
        $1 == id {
            $2 = name
            $3 = email
        }
        { print }
    ' "$DATA_FILE" > "$TEMP_FILE"; then
        rm -f "$TEMP_FILE"
        echo "Error: Could not update record." >&2
        return 1
    fi

    if mv "$TEMP_FILE" "$DATA_FILE"; then
        echo "Record updated successfully."
    else
        rm -f "$TEMP_FILE"
        echo "Error: Could not save updated record." >&2
        return 1
    fi
}

# ---------------------------------------------------------------
# DELETE
# ---------------------------------------------------------------

delete_record() {
    echo
    echo "===== DELETE RECORD ====="

    read -r -p "Enter ID of record to delete: " id

    if [[ -z "$id" ]]; then
        echo "Error: ID is required." >&2
        return 1
    fi

    if ! grep -q "^${id}|" "$DATA_FILE"; then
        echo "Error: Record with ID $id not found." >&2
        return 1
    fi

    TEMP_FILE=$(mktemp)

    # grep may return 1 when all records are removed.
    # That is still a successful deletion.
    grep -v "^${id}|" "$DATA_FILE" > "$TEMP_FILE"

    if mv "$TEMP_FILE" "$DATA_FILE"; then
        echo "Record deleted successfully."
    else
        rm -f "$TEMP_FILE"
        echo "Error: Could not save changes." >&2
        return 1
    fi
}

# ---------------------------------------------------------------
# MAIN MENU
# ---------------------------------------------------------------

while true; do
    echo
    echo "================================="
    echo "       CRUD RECORD MANAGER"
    echo "================================="
    echo "1. Create record"
    echo "2. Read records"
    echo "3. Update record"
    echo "4. Delete record"
    echo "5. Exit"
    echo "================================="

    read -r -p "Choose an option [1-5]: " choice

    case "$choice" in
        1)
            create_record
            ;;
        2)
            read_records
            ;;
        3)
            update_record
            ;;
        4)
            delete_record
            ;;
        5)
            echo "Exiting CRUD application."
            exit 0
            ;;
        *)
            echo "Error: Invalid option. Please choose 1-5." >&2
            ;;
    esac
done
