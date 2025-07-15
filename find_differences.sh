#!/bin/sh

#$1=english $2,$3,$4=others $5=output
if [[ $3 = "" ]]; then
	arg_counts=2
elif [[ $4 = "" ]]; then
	arg_counts=3
else
	arg_counts=1
fi
row_number=0
cat $1|while read row
do
	let row_number+=1
	let pause_flag=$row_number%100
	test $pause_flag = 0 && sleep 1
	#echo $row
	if [[ $row = "" ]]; then
		continue
	fi
	#row_number=`echo $row|awk '{print NR}'`
	en_key=`echo $row|awk -F ",," '{print $1}'`
	if [[ $en_key = "" ]]; then
		continue
	fi
	#echo $row_number $en_key
	printf "\r%d,%-50s" $row_number $en_key
	flag2=-1
	flag3=-1
	flag4=-1
	for (( i = 0; i < $arg_counts; i++ )); do
		if [[ $i = 0 ]]; then
			cat_others=`cat $2`
			others_file=$2
			flag2=0
		elif [[ $i = 1 ]]; then
			cat_others=`cat $3`
			others_file=$3
			flag3=0
		elif [[ $i = 2 ]]; then
			cat_others=`cat $4`
			others_file=$4
			flag4=0
		fi
		echo "$cat_others"|while read row_others
		do
			if [[ $row_others = "" ]]; then
				continue
			fi
			others_key=`echo $row_others|awk -F ",," '{print $1}'`
			if [[ $others_key = "" ]]; then
				continue
			fi
			if [[ $others_key = $en_key ]]; then
				if [[ $i = 0 ]]; then
					flag2=1
					break
				elif [[ $i = 1 ]]; then
					flag3=1
					break
				elif [[ $i = 2 ]]; then
					flag4=1
					break
				fi
			fi
		done
		test $flag2 = 1 -o $flag3 = 1 -o $flag4 = 1 && echo $en_key
		test $flag2 = 1 && echo $2:different
		test $flag3 = 1 && echo $3:different
		test $flag4 = 1 && echo $4:different
	done
done
date +%F" "%T"-----------------------------------------"
#date +%F" "%T"-----------------------------------------" >> $3
#echo >> $3
