echo -e "\n\n\e[32mTITLE: USE SHIFT Right/Left INSTEAD OF DIVISION/MULTIPLICATION\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE '\/|\*' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Use shift Right/Left instead of division/multiplication\nif possible."
echo -e "\nMODIFY CODE: 
uint256 division = (10 >> 2)
uint256 multiplication = (10 << 2)
"