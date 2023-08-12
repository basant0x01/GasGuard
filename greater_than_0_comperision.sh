echo -e "\n\n\e[32mTITLE: GREATER THAN 0 COMPERISION\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE '>[[:space:]]*0' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Use != 0 instead of > 0 for unsigned integer comparison"
echo -e "\nMODIFY CODE: 
(<anything> != 0)
"
