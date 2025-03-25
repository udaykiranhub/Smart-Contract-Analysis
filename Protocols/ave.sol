
Ave:
Aave is a decentralized finance (DeFi) protocol ,
that allows users to lend and borrow cryptocurrencies without needing a middleman.


1.Lenders deposit their crypto into Aave's liquidity pool and earn interest.

2.Borrowers can take loans but must provide collateral.

3.Interest rates are dynamic and depend on supply and demand.

4.Loans can be overcollateralized (borrow less than deposited) to prevent defaults.


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AaveProtocol {
    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    struct Loan {
        uint256 amount;
        uint256 collateral;
        uint256 timestamp;
    }

    mapping(address => Deposit) public deposits;
    mapping(address => Loan) public loans;

    uint256 public interestRate = 5; // 5% interest per loan cycle
    uint256 public collateralRatio = 150; // 150% collateral required

    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount, uint256 collateral);
    event Repaid(address indexed user, uint256 amount);
    event Liquidated(address indexed user, uint256 collateralSeized);


    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");

        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].timestamp = block.timestamp;

        emit Deposited(msg.sender, msg.value);
    }

    function borrow(uint256 _amount) external payable {
        require(msg.value > 0, "Collateral must be provided");
        //Calculating the required collatoral
        uint256 requiredCollateral = (_amount * collateralRatio) / 100;
        require(msg.value >= requiredCollateral, "Insufficient collateral");

        loans[msg.sender] = Loan(_amount, msg.value, block.timestamp);
        payable(msg.sender).transfer(_amount);

        emit Borrowed(msg.sender, _amount, msg.value);
    }

  
    function repay() external payable {
        require(loans[msg.sender].amount > 0, "No active loan");

        uint256 borrowedAmount = loans[msg.sender].amount;
        uint256 interest = (borrowedAmount * interestRate) / 100;
        uint256 totalRepay = borrowedAmount + interest;

        require(msg.value >= totalRepay, "Insufficient repayment amount");

        delete loans[msg.sender];

        emit Repaid(msg.sender, totalRepay);
    }

    function liquidate(address _user) external {
        require(loans[_user].amount > 0, "User has no active loan");

        uint256 borrowedAmount = loans[_user].amount;
        uint256 collateral = loans[_user].collateral;

        uint256 requiredCollateral = (borrowedAmount * collateralRatio) / 100;

        if (collateral < requiredCollateral) {
            delete loans[_user];
            emit Liquidated(_user, collateral);
        }
    }

    function withdraw(uint256 _amount) external {
        require(deposits[msg.sender].amount >= _amount, "Insufficient funds");
        deposits[msg.sender].amount -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}
