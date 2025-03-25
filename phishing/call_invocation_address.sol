Call Structure	                                      msg.sender         	tx.origin
-------------                                       -------------           ---------
.User → Victim Contract                                 user                  user

.User → Attacker Contract → Victim Contract	        Attacker Contract         user 


contract {
  address public owner;

    constructor() {
        owner = msg.sender;
    }
//tx.origin will be the EOA account address directly no need  the  attacker contract.
//attacker contract is the  msg.sender
    function transfer(address payable _to, uint256 _amount) public {
        require(tx.origin == owner, "Not authorized");
        _to.transfer(_amount);
    }


}