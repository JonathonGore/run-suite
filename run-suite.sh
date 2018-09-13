#!/bin/bash

# Test Suit for testing programs.

usage() {
	echo -e "Usage: $0 <suite-file> <program>\nThe argument suite-file is the name of a file containing a list of filename stems, and the argument program is the name of the program to be run." >&2
}

# Checks to see if the program was ran with 2 arguments.
if [ $# -ne 2 ]; then 
	usage
	exit 1
fi

for test in $(cat $1); do 
	for s in 'in' 'out'; do 
		ls -p | egrep  "^${test}\.${s}$" > /dev/null
		if [ $? -ne 0 ]; then
			echo "Missing ${test}.${s} file." >&2
			exit 1
		fi
		ls -l ${test}.${s} | egrep "^.r" > /dev/null
		if [ $? -ne 0 ]; then
                        echo "${test}.${s} file not readable by user $(whoami)." >&2
                        exit 1
                fi
	done

	d1=$(mktemp)
	
	ls -p | egrep "^${test}\.args$" > /dev/null
        if [ $? -eq 0 ]; then
                cat ${test}.in | ${2} $(cat ${test}.args) > ${d1}	
        else
                cat ${test}.in | ${2} > ${d1}
        fi	
	
	cmp -s ${d1} ${test}.out > /dev/null
	
	if [ $? -ne 0 ]; then 
		echo "Test failed: ${test}"
		echo "Input:"
		cat ${test}.in
		echo "Expected:"
		cat ${test}.out
		echo "Actual:"
		cat ${d1}
	else
		echo "Test Passed: ${test}"
	fi
	rm ${d1}	
	
done

