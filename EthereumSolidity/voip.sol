pragma solidity ^0.4.18;

contract Voipo {
    string constant appname = 'Plivo';
    struct Instructor {
        string  sipto;
        string  sipfrom;
        string  callsubject;
        uint  callid;
    }
    
    mapping (address => Instructor) instructors;
    address[] public instructorAccts;
    
    function setInstructor(address _address,string _sipto, string _sipfrom, string _callsubject, uint _callid) public {
        
        instructors[_address].sipto = _sipto;
        instructors[_address].sipfrom = _sipfrom;
        instructors[_address].callsubject= _callsubject;
        instructors[_address].callid = _callid;
        instructorAccts.push(_address) -1;
    }
    
    function getInstructors() view public returns(address[]) {
        return instructorAccts;
    }
    
    function getInstructor(address _address) view public returns (string, string , string , uint) {
        return (
            instructors[_address].sipto, 
            instructors[_address].sipfrom, 
            instructors[_address].callsubject, 
            instructors[_address].callid
            );
    }
    
    function countInstructors() view public returns (uint) {
        return instructorAccts.length;
    }
}

// Tested on Ropsten via MetaMask injector