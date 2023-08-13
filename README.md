# Gas Guard v0.2
![image](https://github.com/basant0x01/GasGuard/assets/123530150/a8c74a21-8d45-45a7-a2a5-57cda5c624aa)

Gas Guard is a straightforward bash script that identifies susceptible gas leak-vulnerable code using grep regex within smart contracts.

## Usage
For a single input, use the -i flag
```
./gasGuard.sh -i contract.sol
```
And for multiple inputs, use the -mi flag
```
./gasGuard.sh -mi contract.sol another-contract.sol
```

## Gas Optimization Issues
gasGuard is able to find vulnerable code related to the list below

1. DEFAULT INITIALIZATION ISSUE
2. CACHE ARRAY LENGTH OUTSIDE OF LOOP
3. GREATER THAN 0 COMPARISON
4. USE CUSTOM ERROR FOR OUTPUT
6. USE ++i AND --i INSTEAD OF OTHER INC/DEC
7. USE SHIFT Right/Left INSTEAD OF DIVISION/MULTIPLICATION
8. USE CALLDATA INSTEAD OF MEMORY FOR FUNCTIONS
9. USE ASSEMBLY TO CHECK FOR ADDRESS(0)

More are coming soon..

## Demo Output
![image](https://github.com/basant0x01/GasGuard/assets/123530150/e95a1b94-57ae-4cfd-835b-89b85d24e125)



