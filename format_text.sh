#!/bin/bash

#vars
M0="named_attribute: sasl_username="
DATE="Date:"
FROM="From:"
TO="To:"
SUBJECT="Subject:"

#bodystart="<body"
bodyend="/body>"
body=""
bod=""
#delete="&nbsp; &copy;"

# Check to see if a pipe exists on stdin.
if [ -p /dev/stdin ]; then

        #echo "Data was piped to this script!"
        # If we want to read the input line by line
        while IFS= read line; do
		
		if [[ $line == "$M0"* ]]; then
			echo "sasl" $'\t\t' $(echo ${line} | cut -d'=' -f2)
        fi
		if [[ $line == "$DATE"* ]]; then
			echo $DATE $'\t\t' $(echo ${line} | cut -d',' -f2)
        fi
		if [[ $line == "$FROM"* ]]; then
			echo $FROM $'\t\t' $(echo ${line} | cut -d'<' -f2 | cut -d'>' -f1)
        fi
		if [[ $line == "$TO"* ]]; then
			echo $TO $'\t\t' $(echo "$line" | cut -d'<' -f2 | cut -d'>' -f1)
		fi
		if [[ $line == "$SUBJECT"* ]]; then
			echo $SUBJECT $'\t' $(echo "$line" | cut -d':' -f2)
		fi
		
		body+="$line"
		
		if [[ $line == *"$bodyend"* ]]; then
			
			bod=$(awk '{ sub(/.*<body([^<]+)>/, ""); sub(/<\/body>.*/, ""); print }' <<< "$body")
			bod=$(echo $bod | perl -pe 's{\n}{ }g' | perl -pe 's{>}{>\n}g' | perl -pe 's{<}{\n<}g' | grep -v '<' | grep -v '^\s*$')
			echo $bod
			
			#perl -e 'print $ARGV[0];' "test"
			#perl -e 'my $input1 = $ARGV[0];my @removes = qw(&nbsp; &copy;);my $remove;foreach $remove (@removes){$input1 =~ s/$remove//g;}print($input1."\n");' "$bod" "$delete"
			#echo "Body:" $'\t' $(echo "$BODY")
		fi
        
	done
else
        echo "No input was found on stdin, skipping!"
fi
