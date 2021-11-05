#!/bin/sh

# Store the basename of the script being executed
BASENAME_SCRIPT=$(basename $0)

HTML_FLAG="--html"
PDF_FLAG="--pdf"

# file type for output file, either pdf or html
OUTPUT_FILE_TYPE=""

# Declare function to print usage
print_usage () {
echo " 
usage: ${BASENAME_SCRIPT} ${HTML_FLAG} | ${PDF_FLAG} <input Markdown file name>
	${HTML_FLAG} : Convert input Markdown file to HTML
	${PDF_FLAG} : Convert input Markdown file to pdf
";
exit 1;

}

determine_flags() {
# Flag is html, change variable and return
[ "$1" = "${HTML_FLAG}" ] && { OUTPUT_FILE_TYPE="html"; return 0; }
# Flag is pdf, change variable and return
[ "$1" = "${PDF_FLAG}" ] && { OUTPUT_FILE_TYPE="pdf"; return 0; }
# The flags were not correct, print_usage and exit
print_usage
}

# Get the first argument, it could either be: --html, --pdf or the input file name
# Check if first positional parameter is not empty, if empty -> print_usage
[ -z "$1" ] && print_usage

determine_flags $@ # pass all positional parameters from file to function

# Get the first argument, which should be the file to convert
FILE_TO_CONVERT=$2

# Check if user specified a file to convert
# -z is true if the next string is empty
[ -z ${FILE_TO_CONVERT} ] && print_usage

# Check if file specified exists and is a regular file (-f option)
[ -f ${FILE_TO_CONVERT} ] || { echo "Error: The file to convert either does not exist or is not a regular file." 1>&2; print_usage; }

# Use cut to only get the file name without the file type
# '.' is the delimiter (-d), use the first element (-f 1)
FILE_BASENAME=$(echo "${FILE_TO_CONVERT}" | cut -f 1 -d '.')

# Create the file output name with the .pdf file type
FILE_OUTPUT_NAME=$(echo "${FILE_BASENAME}.${OUTPUT_FILE_TYPE}")

# Check if pandoc is installed
# if pandoc is not installed, exit status of which pandoc is 1
# redirect output of which pandoc to /dev/null (to not see anything in the prompt)
which pandoc 1>/dev/null  || { echo "Pandoc is not installed." 1>&2; exit 1; }

echo "Converting ${FILE_TO_CONVERT} from Markdown to ${OUTPUT_FILE_TYPE}..."

pandoc -o ${FILE_OUTPUT_NAME} ${FILE_TO_CONVERT} || { echo "Pandoc file conversion failed!" 1>&2; exit 1; }

echo "${FILE_OUTPUT_NAME} was successfully created!"

OS=Darwin
# Check if OS is Mac OS X (Darwin)
# uname == Darwin
# test expression, compare string of command evaluation
# if test expression is true, then exit with 0
# iff Mac OS is being used, run 'open' to open the newly created pdf
# this makes the script portable across UNIX systems
[ $(uname) = "${OS}" ] && { echo "Open newly created ${OUTPUT_FILE_TYPE} file."; open ${FILE_OUTPUT_NAME}; }

exit 0
