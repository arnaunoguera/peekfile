# Initialization: obtaining the arguments or setting defaults
if [[ $# -eq 0 ]]
then
    folder='./'
    N=0
elif [[ $# -eq 1 ]]
then
    folder=$1
    N=0
else
    folder=$1
    N=$2
fi

# Printing a header
echo
echo '###############################################################################'
echo '###############################  FASTASCAN.SH  ################################'
echo '###############################################################################'
echo Scanning fasta files in folder $folder and subfolders...
echo
echo

# Obtaining the list of fasta / fa files (including symbolic links: -l)
files=$(find $folder -type f -name "*.fa" -or -type l -name "*.fa" -or -type f -name "*.fasta" -or -type l -name "*.fasta")

# Calculating the number of files
Nfiles=$(echo "$files" | wc -l)
# Echoing $files quoted separates each result into a newline again

# Calculating the amount of unique IDs 
NIDs=$( (echo "$files" | while read i; do cat "$i"; done) | awk '/^>/{print $1}' | sort | uniq | wc -l)
# Only the string from '>' until the first space is considered the ID

#Printing the folder summary
echo '##################################  SUMMARY  ##################################'
echo
echo There are $Nfiles fasta/fa files in the folder and its subfolders.
echo These files contain $NIDs unique fasta IDs. 
echo

