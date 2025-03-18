
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract X {
//******  Attacker  can easily show the private storage through storage slots *********** 
string private password;


function set(string memory pass) public {
        password = pass;
    }
}
 

//****************  FOUNDRY To Know The Private Storage *******************************
1.cast storage <contract address> slot 

root@lenova:/mnt/c/users/pedda/onedrive/desktop/foundry-one# cast storage  0x66C32205938C034f586eada0b579c0592a639a97 0


Warning: This is a nightly build of Foundry. It is recommended to use the latest stable version. Visit https://book.getfoundry.sh/announcements for more information.
To mute this warning set `FOUNDRY_DISABLE_NIGHTLY_WARNING` in your environment.

0x756461796b6972616e706564646100000000000000000000000000000000001c

2.To Hexa 
root@lenova:/mnt/c/users/pedda/onedrive/desktop/foundry-one# cast --to-ascii 0x756461796b6972616e706564646100000000000000000000000000000000001c

Warning: This is a nightly build of Foundry. It is recommended to use the latest stable version. Visit https://book.getfoundry.sh/announcements for more information.
To mute this warning set `FOUNDRY_DISABLE_NIGHTLY_WARNING` in your environment.

udaykiranpedda

Password is:udaykiranpedda



/********** Secure Storage of the Private Data */


contract X {
    bytes32 private passwordHash;

    function set(string memory pass) public {
        passwordHash = keccak256(abi.encodePacked(pass));
    }

    function verify(string memory input) public view returns (bool) {
        return passwordHash == keccak256(abi.encodePacked(input));
    }
}
### Attacker can see the Keccak stoage But he Can not decode or rverse the Keccak Hash ###


Note :make sure use Off Chain for secure Data





