#!/bin/sh

str="Hello"

if [ -n "$str" ]
then
	echo "문자열이 비어 있지 않습니다."
else
	echo "문자열이 비어 있습니다."
fi
exit 0
