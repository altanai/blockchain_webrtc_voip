
pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Ast
{
    
    
    struct Transaction{
        uint tranxid;
        string  sender;
        string  receiver;
        string Date_Time;
    }

    
    
    Transaction[] private trns;
    uint private nextId=100;
    uint private nextIdS=100;
    uint private nextTrans=0;
    

    function compareStrings (string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
   }
    

    function New_Trans(string memory sender, string memory receiver, string memory datetime) public{
        nextTrans++;
        trns.push(Transaction(nextTrans, sender, receiver, datetime));
    }
    
    function read_trans(uint id) view public returns(Transaction memory){
        for(uint i=0; i<trns.length;i++){
            if(trns[i].tranxid == id)
                return(trns[i]);
        }
    }

    function readAlltrans() view public returns(Transaction[] memory){
            return(trns);
    }

    
}