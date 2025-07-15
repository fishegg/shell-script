#!/bin/sh

row_number=0
cat $1|while read row
do
	let row_number+=1
	running_output="${row_number}:${row}"
	printf "\r%-80s" "${running_output:0:80}"
	#echo $row
	#row_number=`echo $row|awk '{print NR}'`
	left=`echo $row|awk -F "=" '{print $1}'`
	right=`echo $row|awk -F "=" '{print $2}'`
	if [[ $right = "" ]]; then
		continue
	fi
	#echo $left $right
	left_count_object=`echo $left|awk -F "%@" '{print NF-1}'`
	right_count_object=`echo $right|awk -F "%@" '{print NF-1}'`
	left_count_digit=`echo $left|awk -F "%d" '{print NF-1}'`
	right_count_digit=`echo $right|awk -F "%d" '{print NF-1}'`
	if [[ $left_count_object != $right_count_object || $left_count_digit != $right_count_digit ]]; then
		echo
		echo $row
		echo %@$left_count_object:$right_count_object %d$left_count_digit:$right_count_digit
		if [[ $2 ]]; then
			echo $row >> $2
			date +%F" "%T"-----------------------------------------" >> $2
		fi
	fi
done
