#!/bin/bash

# option 1: search all the files in given directory 
# (ex: ./keyword_finder.sh 'C:/Users/User/Desktop/data-science/AI and Deep Learning')

# COLORS
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)


supported_file_formats=("docx" "pdf")

files=()
keywords=()
txt_files=()

# TODO: Replace path with relative path
docx_to_txt_converter='C:/Users/User/Desktop/keyword-finder/docx2txt-1.4/docx2txt.sh'
# docx_to_txt_converter='/docx2txt-1.4/docx2txt.sh'

function build_find_command() {
    local len=${#supported_file_formats[@]}
    command="find . -type f \(";
    for i in "${!supported_file_formats[@]}"; do 
        command="${command} -iname \*.${supported_file_formats[$i]}"
        local result=`expr $len - 1`
        if [[ $i -ne result ]];
        then
            command="${command} -o"
        fi
    done

    command="${command} \) -printf '%f\n'";
}

# read given directory path from user, then navigate to the path
directory_path=$1
cd "$directory_path"

# create export directory in given folder
txt_exports_dir_path="$directory_path/__txt_exports__"
if [[ ! -d $txt_exports_dir_path ]]; then
    eval $(mkdir '__txt_exports__')        
fi

build_find_command

function collect_given_directory_files() {    
    OIFS="$IFS"
    IFS=$'\n'
    for file in `eval $command`
    do
        files+=($file)
    done
    IFS="$OIFS"
}

collect_given_directory_files

function convert_docx_to_txt() {
    OIFS="$IFS"
    IFS=$'\n'
    docx_regex='\.docx$'
    for file in "${files[@]}"; do
        if [[ $file =~ $docx_regex ]]; then
            file_path="$directory_path/$file"
            sh "$docx_to_txt_converter" "$file_path"

            txt_file="${file//'.docx'/'.txt'}"           
            txt_file_path="$directory_path/$txt_file"
            export_path="$txt_exports_dir_path/$txt_file"
            
            if [[ -d $txt_exports_dir_path ]]; then
                eval $(mv "$txt_file_path" "$export_path")
            fi
            txt_files+=($export_path)
        fi
    done
    IFS="$OIFS"
}

convert_docx_to_txt


echo "$GREEN***Exported Files***$NORMAL"
for txt in "${txt_files[@]}"; do
    echo "  $CYAN==>$NORMAL $txt"
done

echo $'\n***************************************************************\n'

read -p "Enter your keywords and separate them with comma: $YELLOW" str_keywords
echo "$NORMAL Keywords: [$YELLOW $str_keywords $NORMAL]"
echo $'\n' 

IFS=',' read -r -a keywords_arr <<< "$str_keywords"

for i in "${!keywords_arr[@]}"; do 
    keyword="${keywords_arr[$i]}"
    trimmed_keyword="${keyword//' '/''}"
    keywords+=($trimmed_keyword)
done

for key in "${keywords[@]}"; do 
    echo "Keyword $YELLOW'$key'$NORMAL found in the following files:"
    for file in "${txt_files[@]}"; do
        if grep -w -q $key "$file"; then
            echo "  $CYAN==>$NORMAL $file"
        fi
    done
    echo $'\n\n\n'
done

