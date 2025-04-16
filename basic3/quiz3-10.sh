#!/bin/sh
F_c=0
D_c=0
for item in *
do
	if [ -d  "$item" ]
	then
		D_c=$((D_c+1))
	elif [ -f "$item" ]
	then
		F_c=$((F_c+1))
	else
		echo "$item x"
	fi
done
echo "파일 수 : $F_c"
echo "디렉토리 수 : $D_c"
exit 0
