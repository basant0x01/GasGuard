echo -e "\n\n\e[32mGAS: USE ++i AND --i INSTEAD OF OTHER INC/DEC\e[0m"
grep -nE '[[:alnum:]_]+\+\+|[[:alnum:]_]+--|i\+\+|i--' "$input_file" | while IFS= read -r line; do        echo "-----------------------------------------------------------------------------"
        echo "LINE: ${line/        /}"  # Remove 8 spaces before "for"
        echo "-----------------------------------------------------------------------------"
done
echo -e "\nRECOMMENDATION: ++i costs less gas than i++, especially when it's used\nin for-loops (--i/i-- too)"
echo -e "\nMODIFY CODE: 
for (uint i; i<10; ++i/--i)
"