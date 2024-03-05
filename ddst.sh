#!/bin/bash


# Check if 'aha' is installed, and if not, install it using pip
if ! command -v aha &> /dev/null; then
    echo "aha is not installed. Installing..."
    pip install aha
fi


# Function to search for a term in a file
search_term() {
    local term=$1
    local file=$2

    echo "Searching in $file..."
    grep -Hn --color=always "$term" "$file" | GREP_COLORS='mt=01;31' grep --color=always -E "$term|$"
}

# Function to print the banner
print_banner() {
    local banner_text="Dump Search Tool"

    local cols=$(tput cols)
    local banner_length=${#banner_text}
    local padding=$(( (cols - banner_length) / 2 ))

    local line=$(printf "%*s" "$cols" | tr ' ' '=')

    echo
    echo "$line"
    printf "%*s\n" $((padding + banner_length)) "$banner_text"
    echo "$line"
    echo
}

# Print welcome message
echo "Welcome to the search tool"

# Select file or folder using Zenity
selection=$(zenity --file-selection --filename="/path/to/folder" --title="Select File or Folder" --multiple --separator='|' --directory)

# Input search term using Zenity
search_term=$(zenity --entry --title="Enter Search Term" --text="Enter the search term:")

# Input output filename using Zenity
output_filename=$(zenity --file-selection --save --title="Save Output As" --confirm-overwrite)

# Main script
# Print banner
print_banner

# Iterate over selected files/folders
IFS='|' read -ra files <<< "$selection"
for item in "${files[@]}"; do
    if [ -f "$item" ]; then  # Check if the item is a file
        search_term "$search_term" "$item"
        echo "=============================="
    elif [ -d "$item" ]; then  # Check if the item is a folder
        search_folder="$item"
        for file in "$search_folder"/*; do
            if [ -f "$file" ]; then  # Check if the item is a file
                search_term "$search_term" "$file"
                echo "=============================="
            fi
        done
    fi
done | aha --black > "$output_filename"
