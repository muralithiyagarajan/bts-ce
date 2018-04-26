#!/bin/bash
#
#

set -x

input_file_or_dir=$1
output_dir=$2 || $(pwd)


function unachive_file(){
	file_name=$1 
	output_dir=$2
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"Zip archive data"* ]] && unzip -n "$file_name" && rm -rf "$file_name"
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"RAR archive data"* ]] && unrar "$file_name"
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"gzip compressed data"* ]] && gunzip "$file_name"
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"7-zip archive data"* ]] && 7z e "$file_name" && rm -rf "$file_name"
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"tar archive"* ]] && tar -xf "$file_name" && rm -rf "$file_name"
	[ -f "$file_name" ] && [[ $(file "$file_name") = *"bzip2 compressed data"* ]] && bzip2 -d "$file_name" 

}


function unachive_folder(){
    folder_name=$1 
	output_dir=$2
    for f in $(find $folder_name -type f)
	do 
	    echo "$f"
	    # if [[ $(file "$f") = *"ASCII text"* ]]
		if [[ $(file "$f") = *"text"* ]]
		then 
			f2=${f#\./} # Remove leading point and forward slash e.g. ./path/to/file
			f2=${f2#\/} # Remove leading forward slash e.g /path/to/file
			new_name=${f2//\//_} 
			mv -f $f $new_name
		fi 
        
		# Check if file is compressed
		# Applying file to 7zip, zip, tar and rar files returns something with "archive data"
		# While applying file to bzip2, gz returns something with "compressed data"
		if [[ $(file "$f") = *"archive"* || $(file "$f") = *"compressed"* ]]
		then 
			# parent_dir=$(dirname $(readlink -f "$f"))
			parent_dir=$(dirname "$f")
			unachive_file $f $output_dir
			# [ $? -ne 0 ] && echo "Failed to uncompress $f" && exit 1
			unachive_folder $parent_dir $output_dir
			
		fi
	done
}

unachive_folder "$input_file_or_dir" "$output_dir"

#Delete folder 
[ -d "$input_file_or_dir" ] && rm -rf "$input_file_or_dir"