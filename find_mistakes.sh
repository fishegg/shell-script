#!/bin/sh
#$1=english $2=others $3=output
date +%F" "%T"--------------------start---------------------" >> $3
timestamp=`date +%s`
en_tmp_file=${1%.*}.$timestamp.txt
others_tmp_file=${2%.*}.$timestamp.txt
cp "$1" "$en_tmp_file"
cp "$2" "$others_tmp_file"
en_row_number=0
others_row_number=0
int_command="echo&&echo 中断后请自行清理临时文件&&exit"
#int_command="rm $en_tmp_file&&rm $others_tmp_file&&exit"
cat $en_tmp_file|while read row
do
	trap "$int_command" INT
	let en_row_number+=1
	#echo $row
	#row_number=`echo $row|awk '{print NR}'`
	#en_key=`echo $row|awk -F "<it|em>|=\"|\">|</" '{print $2}'`
	#en_text=`echo $row|awk -F "<it|em>|=\"|\">|</" '{print $3}'`
	en_key=`echo $row|awk -F ",," '{print $1}'`
	en_text=`echo $row|awk -F ",," '{print $2}'`
	if [[ $row = "" ]]; then
		continue
	fi
	if [[ $en_key = "" ]]; then
		continue
	fi
	#echo $row_number $en_key $en_text
	printf "\r%s:%s:%-25s" "$en_row_number" "$en_key" "${en_text:0:25}"
	en_count_placeholder=`echo $en_text|awk -F "%[.\ddsf]" '{print NF-1}'`
	#right_count_object=`echo $right|awk -F "%@" '{print NF-1}'`
	#left_count_digit=`echo $left|awk -F "%d" '{print NF-1}'`
	#right_count_digit=`echo $right|awk -F "%d" '{print NF-1}'`
	#echo $en_count_placeholder
	cat $others_tmp_file|while read row_others
	do
		let others_row_number+=1
		#others_key=`echo $row_others|awk -F "<it|em>|=\"|\">|</" '{print $2}'`
		others_key=`echo $row_others|awk -F ",," '{print $1}'`
		if [[ $row_others = "" ]]; then
			continue
		fi
		if [[ $others_key = "" ]]; then
			continue
		fi
		if [[ $others_key = $en_key ]]; then
			#others_text=`echo $row_others|awk -F "<it|em>|=\"|\">|</" '{print $3}'`
			others_text=`echo $row_others|awk -F ",," '{print $2}'`
			#echo $others_key $others_text
			others_count_placeholder=`echo $others_text|awk -F "%[.\ddsf]" '{print NF-1}'`
			if [[ $en_count_placeholder != $others_count_placeholder ]]; then
				echo ...................................
				echo $row
				echo $row_others
				echo $en_count_placeholder:$others_count_placeholder
				echo ...................................
				if [[ $3 ]]; then
					echo $row >> $3
					echo $row_others >> $3
					echo $en_count_placeholder:$others_count_placeholder >> $3
				fi
			fi
			#sed -i "" ${en_row_number}d $en_tmp_file
			sed -i "" ${others_row_number}d $others_tmp_file
			break
		fi
	done
done
echo
rm $en_tmp_file
rm $others_tmp_file
date +%F" "%T"--------------------finish---------------------" >> $3
echo >> $3
