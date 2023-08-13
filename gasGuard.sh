#!/bin/bash

clear
figlet -c "Gas Guard"
echo "                     Scripted by basant0x01 | Initial v0.2"

function engine() {
    vulnTemplates=(
        "default_Initilization_Loop.sh" 
        "cache_Array_Length_Loop.sh" 
        "greater_than_0_comperision.sh" 
        "use_custom_error.sh" 
        "increament_and_decrement.sh" 
        "bit_shifting_division_multiplication.sh" 
        "calldata_instead_memory_in_function.sh" 
        "assembly_for_address0.sh"
    )

    for template in "${vulnTemplates[@]}"; do
        output=$(source "$template" 2>&1)
        if echo "$output" | grep -q "LINE:"; then
            echo "$output"
            echo "*****************************************************************************"
        fi
    done
}

# Parse command line arguments
input_files=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            shift
            input_files+=("$1")
            ;;
        -mi|--multi-input)
            shift
            input_files+=("$@")
            break
            ;;
        *)
            echo "UNKNOWN OPTION: $1"
            exit 1
            ;;
    esac
    shift
done

if [ ${#input_files[@]} -eq 0 ]; then
    echo "Usage: $0 [-i input_file1 ...] [-mi input_file1 ...]"
    exit 1
fi

# Check for loop issues
for input_file in "${input_files[@]}"; do
    engine
done
