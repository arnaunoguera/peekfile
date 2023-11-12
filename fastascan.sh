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

# Calculating the number of files:
# Echoing $files in quotes separates each result into a newline again
Nfiles=$(echo "$files" | wc -l)

# It also makes Nfiles = 1 if it's actually 0, so I have to consider this case. 
if [[ $(echo $files | wc -w) -eq 0 ]]
then
    echo There are no .fasta or .fa files in the folder $folder or subfolders.
    echo
    exit 1 #I stop the program if there are no fasta/fa files
fi

# Calculating the amount of unique IDs
NIDs=$( 
(echo "$files" | while read i
    do
    if [[ -r $i ]]; then #if the file is readable
        cat "$i" #cat the file, to then extract the IDs
    else
        echo $i >&2 #echoing non-readable files into the stderr channel so I can access them later
    fi
done) 2> non-readable_files.txt | awk '/^>/{print $1}' | sort | uniq | wc -l) 
# Only the string from '>' until the first space is considered the ID
NoReadFiles=$(cat non-readable_files.txt | wc -l) #A counter of files that are non-readable

# Printing the folder summary
echo '##############################  FOLDER SUMMARY  ###############################'
echo
if [[ $Nfiles -eq 1 ]]; then echo There is 1 fasta/fa file in the directory: $files.
else echo There are $Nfiles fasta/fa files in the directory.
fi
if [[ $NoReadFiles -eq 1 ]]; then
echo However, 1 file is not readable: $(cat non-readable_files.txt).
elif [[ $NoReadFiles -gt 1 ]]; then
echo However, $NoReadFiles of these files are not readable.
fi
echo 
echo The files contain $NIDs unique fasta IDs. 
echo 
echo

# Per file report
echo '###############################  FILE REPORTS  ################################'
# Iterating every file
echo "$files" | while read file
do
    echo
    echo ' ################' $(basename "$file") '################'
    echo
    if [[ -h "$file" ]]; then
        echo "  File: $file (symbolic link)"
    else
        echo "  File: $file (regular file)"
    fi
    echo
    if [[ ! -r "$file" ]]; then
        echo "  This file is not readable."
        echo
        continue #If the file it not readable, I skip to the next file
    fi
    Nseq=$(egrep -c '^>' "$file")
    echo "  Number of fasta sequences: $Nseq"
    echo
    if [[ Nseq -eq 0 ]]; then
        continue #If the file contains no sequences, skip to the next
    fi
    # Counting characters. I replace gaps and spaces with gsub and eliminate newlines setting the ORS in awk to nothing
    Nchar=$(cat "$file" | awk 'BEGIN {ORS=""} !/^>/{gsub("-","",$0); gsub(" ","",$0); print $0}' | wc -m)
    echo "  Total sequence length: $Nchar"
    echo
    # To determine whether it contains amino acid or nucleotide sequences, I count how many characters match [ACGTUN] (all possibilities for nucleotides
    Nnuc=$(egrep -v '^>' "$file" | grep -o "[ACGTUNactgun]" | wc -l)
    if [[ $Nnuc -ge $Nchar ]]; then #To be nucleotides, there should be as many ACTGNU as total sequence characters
        echo "  Sequence type: nucleotides"
    else #Otherwise, it is assumed to be proteins
        echo "  Sequence type: amino acids" 
    fi
    echo
done
