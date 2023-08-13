#!/bin/bash

clear
figlet -c Gas Guard
echo "                     Scripted by basant0x01 | Initial v0.1"

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

    for tmp in "${vulnTemplates[@]}"; do
        source "$tmp"
        echo "*****************************************************************************"
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -i|--input)
            input_file="$2"
            shift
            shift
            ;;
        *)
            echo "UNKNOWN OPTION: $1"
            exit 1
            ;;
    esac
done

if [ -z "$input_file" ]; then
    echo "Usage: $0 -i input_file"
    exit 1
fi

# Check for loop issues
engine
