1.Users deposit ETH as collateral.
2 Users borrow tokens based on collateral.
3️ Users repay loans to free up collateral.
4️ If collateral falls below 120%, admin can liquidate the position.
5️ Collateral can be withdrawn only if there’s no outstanding loan.



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20 {
    
    constructor() ERC20("stableToken", "STK") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
} //get the token address 
contract SimpleLending is Ownable {
    IERC20 public stableToken;
    uint256 public constant COLLATERAL_RATIO = 150; 
    uint256 public constant LIQUIDATION_RATIO = 120; 
    uint256 public constant ETH_TO_TOKEN_RATE = 2000; // 1 ETH = 2000 tokens

    struct Loan {
        uint256 collateralETH;
        uint256 borrowedTokens;
    }

    mapping(address => Loan) public loans;

    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Liquidated(address indexed user);

    constructor(IERC20 _stableToken) {
        stableToken = _stableToken;
    }


    function depositCollateral() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        loans[msg.sender].collateralETH += msg.value;
        emit Deposited(msg.sender, msg.value);
    }


    function borrow(uint256 amount) external {
        Loan storage loan = loans[msg.sender];

        require(loan.collateralETH > 0, "No collateral deposited");
        uint256 maxBorrow = (loan.collateralETH * ETH_TO_TOKEN_RATE * 100) / COLLATERAL_RATIO;
        require(amount <= maxBorrow, "Borrow amount exceeds collateral limit");

        loan.borrowedTokens += amount;
        require(stableToken.transfer(msg.sender, amount), "Token transfer failed");
        
        emit Borrowed(msg.sender, amount);
    }


    function repay(uint256 amount) external {
        Loan storage loan = loans[msg.sender];
        require(loan.borrowedTokens >= amount, "Repay amount exceeds loan");

        require(stableToken.transferFrom(msg.sender, address(this), amount), "Repayment failed");
        loan.borrowedTokens -= amount;

        emit Repaid(msg.sender, amount);
    }


    function liquidate(address user) external onlyOwner {
        Loan storage loan = loans[user];

        uint256 requiredCollateral = (loan.borrowedTokens * COLLATERAL_RATIO) / 100;
        uint256 liquidationThreshold = (loan.borrowedTokens * LIQUIDATION_RATIO) / 100;

        require(loan.collateralETH * ETH_TO_TOKEN_RATE < liquidationThreshold, "Collateral sufficient");

        // Seize collateral
        loan.collateralETH = 0;
        loan.borrowedTokens = 0;

        emit Liquidated(user);
    }

    function withdrawCollateral() external {
        Loan storage loan = loans[msg.sender];
        require(loan.borrowedTokens == 0, "Outstanding loan exists");

        uint256 amount = loan.collateralETH;
        loan.collateralETH = 0;
        payable(msg.sender).transfer(amount);
    }
}
