echo -e "\n\n\e[32mTITLE: CACHE ARRAY LENGTH OUTSIDE OF LOOP\e[0m"
echo -e "\e[32mFILE: $input_file\e[0m"
grep -nE 'for *\(.*\.length.*\)' "$input_file" | while IFS= read -r line; do
        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: In such for loops, the 'array.length' is read on every\niteration instead of caching it once in a local variable and reading it again \nusing the local variable."
echo -e "\nMODIFY CODE: 
uint cachedTokenAddress = <array>.length
for (uint256 t = 0; t < cachedTokenAddress; t++) {
"
