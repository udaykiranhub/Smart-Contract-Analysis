// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// Gold Token (GOLD)
contract GoldToken is ERC20 {
    constructor() ERC20("GoldToken", "GOLD") {
        _mint(msg.sender, 100000 * 10 ** decimals()); // Mint 100,000 GOLD
    }
}

// Diamond Token (DIAMOND)
contract DiamondToken is ERC20 {
    constructor() ERC20("DiamondToken", "DIAMOND") {
        _mint(msg.sender, 50000 * 10 ** decimals()); // Mint 50,000 DIAMOND
    }
}


// Automated Market Maker (AMM) Contract
contract AMM {
    IERC20 public gold;
    IERC20 public diamond;
    uint256 public reserveGold;
    uint256 public reserveDiamond;
    
    constructor(address _gold, address _diamond) {
        gold = IERC20(_gold);
        diamond = IERC20(_diamond);
    }

    function addLiquidity(uint256 goldAmount, uint256 diamondAmount) external {
        gold.transferFrom(msg.sender, address(this), goldAmount);
        diamond.transferFrom(msg.sender, address(this), diamondAmount);
        reserveGold += goldAmount;
        reserveDiamond += diamondAmount;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "Invalid reserves");
        uint256 amountInWithFee = amountIn * 997; // 0.3% fee
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        return numerator / denominator;
    }

    function swapGoldForDiamond(uint256 goldAmount) external {
        uint256 diamondAmount = getAmountOut(goldAmount, reserveGold, reserveDiamond);
        require(diamondAmount > 0, "Insufficient output amount");
        
        gold.transferFrom(msg.sender, address(this), goldAmount);
        diamond.transfer(msg.sender, diamondAmount);
        
        reserveGold += goldAmount;
        reserveDiamond -= diamondAmount;
    }

    function swapDiamondForGold(uint256 diamondAmount) external {
        uint256 goldAmount = getAmountOut(diamondAmount, reserveDiamond, reserveGold);
        require(goldAmount > 0, "Insufficient output amount");
        
        diamond.transferFrom(msg.sender, address(this), diamondAmount);
        gold.transfer(msg.sender, goldAmount);
        
        reserveDiamond += diamondAmount;
        reserveGold -= goldAmount;
    }
}


=== Constant product formulae  =>
 x*y=k;


For instance ,   Gold=1000
                Diamond =2000

                k=Gold* Diamond
                 = 2000000

       1.  Swap for   100 Gold to the Diamond = > goldNew=1000+100
                                                         =1100
       2.   diamondNew =>
            diamondNew= k / goldNew
               
                =2000000/11000
                =1818.1818
      3. Diamonds to the user => Diamond - diamondNew
                         =2000-1818.1818
                         =181.8182
      4. Updated  Diamonds Are =2000 - 181.8282
                               =1818.1818









@@@ wanted= we have * Total 

fee=0.3%
==========> amountinFee  =  amountin * 997
                          ________________
                               1000


=========>  numerator= (amountInWithFee ×  reserveOut)


=======>  denominator=  reserveIn × 1000  +  amountInWithFee


========> amountOut= numerator/ denominator

​
