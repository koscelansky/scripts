# Simple script to convert all files in input folder, including subfolders, to 
# JPEG format and save them in output folder. Keeping the same folder structure.
# It uses jpegli to convert the images and ExifTool to copy the metadata.

# Optionaly you can use the -q flag to set the quality of the output images.
# Default quality is 78.

# Usage: ./jpeg-convert.sh [-q QUALITY] input_folder output_folder

# Extract the quality flag if it is set and the folders into variables

# funtion to print error, usage and exit
failure() {
  echo $1 1>&2
  echo "Usage: $0 [-q QUALITY] input_folder output_folder" 1>&2
  exit 1
}

while getopts ":q:" opt; do
  case ${opt} in
    q)
      quality=$OPTARG
      # Check if the quality is a number between 1 and 100
      if ! [[ $quality =~ ^[0-9]+$ ]] || [ $quality -lt 1 ] || [ $quality -gt 100 ]; then
        failure "Invalid quality value: $quality. It must be a number between 1 and 100"
      fi
      ;;
    \?)
      failure "Invalid option: $OPTARG"
      ;;
    :)
      failure "Invalid option: $OPTARG requires an argument"
      ;;
  esac
done

shift $(($OPTIND-1));

# If quality is not set, use the default value
if [ -z "$quality" ]; then
  quality=78
fi

input_folder=$1
output_folder=$2

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
  relative_input_path=$(realpath --relative-to="$input_folder" "$input_file")
  
  # Get the output file path
  output_file=$output_folder/$relative_input_path
  # Create the output folder
  mkdir -p $(dirname "$output_file")

  # Convert the image to JPEG
  # Add the --chroma_subsampling 422 flag to use 4:2:2 chroma subsampling
  # it creates smaller files with no visible quality loss me
  cjpegli --chroma_subsampling 422 -q $quality "$input_file" "$output_file"

  # Copy the metadata
  # We need to add back the embedded color profile, because cjpegli seems to
  # removes it, with no way of keeping it, so it will render the colors wrong
  exiftool -overwrite_original -TagsFromFile "$input_file" -preserve -all -icc_profile "$output_file"
done
