#!/bin/bash

# Simple script to convert all files in input folder, including subfolders, to 
# JPEG format and save them in output folder. Keeping the same folder structure.
# It uses jpegli to convert the images and ExifTool to copy the metadata.

# Optionaly you can use the -q flag to set the quality of the output images.
# Default quality is 78.

# Usage: ./jpeg-convert.sh [-q QUALITY] input_folder output_folder
print_usage() {
  echo "Usage: $0 [-q QUALITY] input_folder output_folder"
  echo "Convert images to JPEG format and save them in output folder."
  echo "Options:"
  echo "  -q QUALITY   Set the quality of the output images (1-100). Default is 78."
  echo "  -h           Show this help message."
  echo "Example: $0 -q 90 /path/to/input /path/to/output"

  exit $1
}

failure() {
  echo "Error: $1"
  exit 1
}

# Check if required binaries are available
if ! command -v cjpegli &> /dev/null; then
  echo "cjpegli is not installed or not in PATH"
  echo "You can build it from sources https://github.com/google/jpegli"
  echo "Or install it using your package manager, for example:"
  echo "  apt install libjpegli-tools (Ubuntu 24.10)"
  exit 1
fi

if ! command -v exiftool &> /dev/null; then
  echo "exiftool is not installed or not in PATH"
  echo "You can install it using your package manager, for example:"
  echo "  apt install libimage-exiftool-perl"
  echo "Or download it from git"
  echo "  git clone https://github.com/exiftool/exiftool.git"
  exit 1
fi

# Extract parameters and chek if they are valid
while getopts ":q:h" opt; do
  case ${opt} in
    q)
      quality=$OPTARG
      # Check if the quality is a number between 1 and 100
      if ! [[ $quality =~ ^[0-9]+$ ]] || [ $quality -lt 1 ] || [ $quality -gt 100 ]; then
        failure "Invalid quality value: $quality. It must be a number between 1 and 100"
      fi
      ;;
    h)
      print_usage 0
      ;;
    \?)
      echo "Invalid option: $OPTARG"
      print_usage 1
      ;;
    :)
      failure "Invalid value: $OPTARG requires an argument"
      print_usage 1
      ;;
  esac
done

shift $(($OPTIND-1));

input_folder=$1
output_folder=$2

# Check if input and output folders are provided
if [ -z "$input_folder" ] || [ -z "$output_folder" ]; then
  failure "Input and output folders are required"
  print_usage 1
fi

# If quality is not set, use the default value
if [ -z "$quality" ]; then
  quality=78
fi

echo "Converting images from $input_folder to JPEG format and saving them in $output_folder with quality $quality"

# Check if the input folder exists
if [ ! -d "$input_folder" ]; then
  failure "Input folder $input_folder does not exist"
fi

# If output folder does not exist, create it
if [ ! -d "$output_folder" ]; then
  echo "Output folder $output_folder does not exist. Creating it..."
  mkdir -p $output_folder
fi

# Find all files in the input folder and subfolders
find "$input_folder" -type f | while read input_file; do
  # Get the relative path of the file
  echo "Converting $input_file"
  relative_input_path=${input_file#"$input_folder/"}
  
  # Get the output file path
  output_file="$output_folder/$relative_input_path"

  output_dir=$(dirname "$output_file")
  
  # Create the output folder
  mkdir -p "$output_dir"

  # Convert the image to JPEG
  # Add the --chroma_subsampling 422 flag to use 4:2:2 chroma subsampling
  # it creates smaller files with no visible quality loss to me
  cjpegli --chroma_subsampling 422 -q $quality "$input_file" "$output_file"

  # Copy the metadata
  # We need to add back the embedded color profile, because cjpegli seems to
  # remove it, with no way of keeping it, so it will render the colors wrong
  exiftool -overwrite_original -TagsFromFile "$input_file" -preserve -all -icc_profile "$output_file"
done
