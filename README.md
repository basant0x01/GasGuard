# Gas Guard
![image](https://github.com/basant0x01/GasGuard/assets/123530150/de9b25a2-8f2b-4424-9f0b-92317b2b04cf)

Gas Guard is a straightforward bash script that identifies susceptible gas leak-vulnerable code using grep regex within smart contracts.

## Usage
```
./gasGuard.sh -i contract.sol
```

## Gas Optimization Issues
gasGuard is able to find vulnerable code related to the list below

1. DEFAULT INITIALIZATION ISSUE
2. CACHE ARRAY LENGTH OUTSIDE OF LOOP
3. GREATER THAN 0 COMPARISON
4. USE CUSTOM ERROR FOR OUTPUT
5. USE CUSTOM ERROR FOR OUTPUT
6. USE ++i AND --i INSTEAD OF OTHER INC/DEC
7. USE SHIFT Right/Left INSTEAD OF DIVISION/MULTIPLICATION
8. USE CALLDATA INSTEAD OF MEMORY FOR FUNCTIONS
9. USE ASSEMBLY TO CHECK FOR ADDRESS(0)

More are comming soon

## Demo Output
![image](https://github.com/basant0x01/GasGuard/assets/123530150/d3a62495-2bea-4361-a79c-41a7377a8aa4)


