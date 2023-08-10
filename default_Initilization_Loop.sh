 echo -e "\n\n\e[32mGAS: DEFAULT INITIALIZATION ISSUE\e[0m"
    grep -nE 'for *\(.*i *= *0.*;.*\)' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Instead of writing uint256 index = 0; as a uint256,\nit will be 0 by default so you can save some gas by avoiding initialization.\nDon't initialize variables with default value."
echo -e "\nMODIFY CODE: 
for (uint256 i;)"
echo -e "\n"