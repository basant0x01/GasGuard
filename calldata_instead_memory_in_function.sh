echo -e "\n\n\e[32mTITLE: USE CALLDATA INSTEAD OF MEMORY FOR FUNCTIONS\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE 'function[[:space:]]+[a-zA-Z0-9_]+\([^)]*memory[[:space:]]+[a-zA-Z0-9_]+[^)]*\)' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: Mark data types as calldata instead of memory where possible.\nThis makes it so that the data is not automatically loaded into memory.\nIf the data passed into the function does not need to be changed\n(like updating values in an array), it can be passed in as calldata.\nThe one exception is if the argument must later be passed into another function,\nwhich takes an argument that specifies memory storage."
echo -e "\nMODIFY CODE: 
function foo(uint256 calldata _age) public return(uint256)
"