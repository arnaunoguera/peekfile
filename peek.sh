if [[ $# -eq 1 ]]
then
    lines=3
else
    lines=$2
fi
if [[ $(cat $1 | wc -l) -le $((2*$lines)) ]]
then 
    cat $1
else
    echo "Warning: the file is too long. Showing first and last $lines lines." >&2
    head -n $lines $1
    echo ...
    tail -n $lines $1
fi
