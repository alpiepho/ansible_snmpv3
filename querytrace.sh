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
  # get host name from file name
  host=$f
  host=${host/\/tmp\/client_query_trace_//}
  host=${host/\//}
  host=${host/.txt/}

  if grep -Fxq "[" $f
  then
    # ie.: 
    # 1          2               3  4                    5 6                   7  8     9  10
    # |          |                                                                      |  |
    # 2020-07-29 12:50:24.673603 IP 172.16.12.162.44580 > 172.16.12.52.53: 51581+ [1au] A? gamegogle.com. (54)
    cat $f | cut -d " " -f 1,2,9,10 | sed -e "s/ /,/g" | sed -e "s/,/_/" -e "s/\?,/,/" | sed -e "s/,/,$host,$client_filter,/" >> $resultname
  else
    # ie.:
    # 1          2               3  4                    5 6                   7    8  9
    # |          |                                                                  |  |
    # 2020-07-20 07:16:35.134816 IP 192.168.121.27.49077 > 192.168.121.101.53: 227+ A? microsoft. (27)
    cat $f | cut -d " " -f 1,2,8,9 | sed -e "s/ /,/g" | sed -e "s/,/_/" -e "s/\?,/,/" | sed -e "s/,/,$host,$client_filter,/" >> $resultname
  fi
done

# remove blank lines and sort results file
sed -i -e '/^$/d' $resultname
sort -o $resultname $resultname

# add header line 
echo "Timestamp,DNS Server,Client IP Address,QType,Domain Name" > $resultname.bak 
cat $resultname >> $resultname.bak
mv $resultname.bak $resultname

# conver to tabs
sed -i -e "s/,/	/g" $resultname

# clean up trace files
rm -f /tmp/client_query_*.txt

echo "Results in $resultname"

