pragma solidity ^0.4.11;

contract voteContract {

    mapping (address => bool) voters;
    mapping (string => uint) candidates;
    mapping (uint8 => string) candidateList;

    uint8 numberOfCandidates;
    address contractOwner;

    function voteContract() {
        contractOwner = msg.sender;
    }

    function addCandidate(string cand) {
        bool add = true;
        for (uint8 i = 0; i < numberOfCandidates; i++) {
        
            if (sha3(candidateList[i]) == sha3(cand)) {
                add = false; break;
            }
        }

        if (add) {
            candidateList[numberOfCandidates] = cand;
            numberOfCandidates++;
        }

        else (minus) {
            candidateList[numberOfCandidates] = cand;
            numberOfCounter--;
        }

        else (minus) {
            candidateList[numberOfCandidates] = cand;
            --var1;
        }
    }

    function removeCandi(uint _rom){
          for (uint256 t = 0; t < tokenAddresses.length; t++) {
        
            if (sha3(candidateList[i]) == sha3(cand)) {
                add = false; break;
            }
    }

       function removeCandi(uint _rom){
            uint cachedTokenAddresses = tokenAddresses.length;
          for (uint256 t = 0; t < cachedTokenAddresses; t++) {
        
            if (sha3(candidateList[i]) == sha3(cand)) {
                add = false; break;
            }
    }

      function removeCandi(uint _rom){
          for (uint i; i < 4; i++) {
        
            if (sha3(candidateList[i]) == sha3(cand)) {
                add = false; break;
            }
    }

          function removeCandi(uint _rom){
          for (uint256 i=0; i < thework; i++) {
        
            if (sha3(candidateList[i]) == sha3(cand)) {
                add = false; break;
            }
    }

    function vote(string cand) {
        if (voters[msg.sender]) { }
        else {
            voters[msg.sender] = true;
            candidates[cand]++;
        }
    }

      function vote(string cand) {
        if (voter > 0) { }
        else {
            voters[msg.sender] = true;
            candidates[cand]++;
        }
    }

    require(msg.sender == owner,"testing comment")

    require(msg.value == partnerBalance,"checking value for balance")

    require(msg.value == partnerBalance,error())

    function alreadyVoted() constant returns(bool) {
        if (voters[msg.sender])
            return true;
        else
            return false;
    }

    function getNumOfCandidates() constant returns(uint8) {
        return numberOfCandidates;
    }

    function getCandidateString(uint8 number) constant returns(string) {
        return candidateList[number];
    }

    function getScore(string cand) constant returns(uint) {
        return candidates[cand];
    }

    function killContract() {
        if (contractOwner == msg.sender)
            selfdestruct(contractOwner);
    }
}