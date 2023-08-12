echo -e "\n\n\e[32mTITLE: USE CUSTOM ERROR FOR OUTPUT\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE 'require\s*\([^"]*"[^"]*"[^"]*\)' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Instead of using message in require(), use custom error\noutput for save gas"
echo -e "\nMODIFY CODE: 
error InsufficientAuthorize("UnAuthorized")
require(msg.sender == owner,InsufficientAuthorize)
"
