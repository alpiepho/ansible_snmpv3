#!/bin/bash
# ./querytrace.sh inventory 192.168.121.27 30 100 /tmp/querytrace.csv
echo $1
echo $2
echo $3
echo $4
echo $5
inventory=$1
client_filter=$2
runtime_sec=$3
packets_max=$4
resultname=$5

# run ansible
ansible-playbook -i $inventory querytrace.yml -e client_filter=$client_filter -e runtime_sec=$runtime_sec -e packets_max=$packets_max

# clear last result file
rm $resultname

FILES=/tmp/client_query_trace_*
for f in $FILES
do
  echo "Processing $f file..."
  cat $f | cut -d " " -f 1,2,8,9,10 | sed -e "s/ /,/g" | sed -e "s/,/_/" -e "s/\?,/,/" -e "s/\[/__flags__/" -e "s/\]//" >> $resultname
  # TODO: add host and client ip
  # TODO: adjust for __flags__
done

# sort results file
sort -o $resultname $resultname

# clean up trace files
rm -f /tmp/client_trace_*.txt

echo "Results in $resultname"

#DEBUG
cat $resultname

