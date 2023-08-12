echo -e "\n\n\e[32mTITLE: USE ASSEMBLY TO CHECK FOR ADDRESS(0)\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE '==[[:space:]]*address\(0\)' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Using assembly to check for the zero address can result in significant\ngas savings compared to using a Solidity expression; especially\nif the check is performed frequently or in a loop. However, it’s important\nto note that using assembly can make the code less readable and harder to\nmaintain, so it should be used judiciously and with caution."
echo -e "\nMODIFY CODE: 

"