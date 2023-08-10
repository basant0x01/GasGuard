#!/bin/bash

clear
figlet -c Gas Guard
echo "                     Scripted by basant0x01 | Initial v0.1"

# Function to check for default initialization issue
function defaultInitilizationIssue_loop() {
    source default_Initilization_Loop.sh
    cacheArrayLengthIssue_loop
}

# Function to check for caching array length issue
function cacheArrayLengthIssue_loop() {
    echo -e "*****************************************************************************"
    source cache_Array_Length_Loop.sh
    greaterthan0comperision
}

function greaterthan0comperision() {
    echo -e "*****************************************************************************"
    source greater_than_0_comperision.sh
    useCustomError
}

function useCustomError() {
    echo -e "*****************************************************************************"
    source use_custom_error.sh
    increamentAndDecrement
}

function increamentAndDecrement() {
    echo -e "*****************************************************************************"
    source increament_and_decrement.sh
    bitShiftingForDivisionAndMultiplication
}

function bitShiftingForDivisionAndMultiplication() {
    echo -e "*****************************************************************************"
    source bit_shifting_division_multiplication.sh
    calldataInsteadOfMemory
}

function calldataInsteadOfMemory() {
    echo -e "*****************************************************************************"
    source calldata_instead_memory_in_function.sh
    assembly_for_address0
}

function assembly_for_address0() {
    echo -e "*****************************************************************************"
    source assembly_for_address0.sh
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
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$input_file" ]; then
    echo "Usage: $0 -i input_file"
    exit 1
fi

# Check for loop issues
defaultInitilizationIssue_loop
