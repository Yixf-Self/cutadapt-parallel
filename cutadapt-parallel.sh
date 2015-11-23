#!/bin/bash
#
# Author CLint Paden  2015-11-09

ramdiskname="/ramdisk"

copts=" "
file1=""
file2=""
useramdisk=0

while [ "${1+x}" ]; do 
if [ "$1" == "--threads" ] ; then
	shift 
	threads=$1
	shift
elif [ "$1" == "--ramdisk" ]; then
	useramdisk=1
	shift
elif [ "$1" == "--ramdiskname" ]; then
	shift
	ramdiskname="$1"
	shift
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Usage: $0 --threads <#threads> [--ramdisk (use ramdisk--recommended) --ramdiskname (default /ramdisk)] <cutadapt arguments>"
	echo "Note: This tool requires pairs, please use the -o/-p usage for now"
	echo "For specific cutadapt help, type 'cutadapt --help'"
	exit 1
elif [[ "$1" == "-o" || "$1" == "--output" ]]; then
	shift;
	file1out="$1"
	shift
elif [[ "$1" == "-p" ]]; then
	shift
	file2out="$1"
	shift
elif [[ "$1" =~ ^- ]]; then 
	copts="$copts $1 "; shift; 
	copts="$copts $1 "; shift
elif [ $# -eq 1 ] ; then
	file2=$1
	shift
elif [ $# -eq 2 ]; then
	file1=$1
	shift
else 
	echo ERROR; exit 1
fi
done

file1lines=$(cat $file1|wc -l) 
#file2lines=$(cat $file2|wc -l)
wait

#if [ $file1lines -ne $file2lines ]; then echo "Unequal lines in file1 and file2"; exit 1; fi
if [[ $useramdisk -eq 1 && -d /ramdisk ]]; then
	tempdir1=$(mktemp -d /$ramdiskname/tmp.XXXXXX)
	tempdir2=$(mktemp -d /$ramdiskname/tmp.XXXXXX)
	tempdir3=$(mktemp -d /$ramdiskname/tmp.XXXXXX)
	tempdir4=$(mktemp -d /$ramdiskname/tmp.XXXXXX)
else
	tempdir1=$(mktemp -d)
	tempdir2=$(mktemp -d)
	tempdir3=$(mktemp -d)
	tempdir4=$(mktemp -d)
fi
splitlines=$(($file1lines/4/$threads))
splitlines=$((splitlines*4))
split -l $splitlines $file1 $tempdir1/file. &
split -l $splitlines $file2 $tempdir2/file.
wait

for i in $tempdir1/* ; do 
	k=${i##*/};
	j=$tempdir2/$k

	cutadapt $copts -o $tempdir3/$k -p $tempdir4/$k $i $j &

done
wait

cat $tempdir3/* > $file1out &
cat $tempdir4/* > $file2out

wait

rm -rf $tempdir1 $tempdir2 $tempdir3 $tempdir4



