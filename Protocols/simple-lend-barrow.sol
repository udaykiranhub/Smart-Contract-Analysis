// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//this is my token 
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LendingProtocol {
    IERC20 public token;
    uint256 public interestRate = 5; // 5% interest per loan 

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowedAmount;
    mapping(address => uint256) public collateral;

    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    // 🔹 Deposit ERC-20 tokens as collateral
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    // 🔹 Borrow ERC-20 tokens based on collateral (50% loan-to-value ratio)
    function borrow(uint256 amount) external {
        require(deposits[msg.sender] > 0, "No collateral deposited");
        uint256 maxBorrow = deposits[msg.sender] / 2;
        require(amount <= maxBorrow, "Borrow amount exceeds limit");

        borrowedAmount[msg.sender] += amount;
        token.transfer(msg.sender, amount);
        emit Borrowed(msg.sender, amount);
    }

    // 🔹 Repay borrowed tokens with interest (5% interest)
    function repay(uint256 amount) external {
        require(borrowedAmount[msg.sender] > 0, "No active loan");
        uint256 interest = (borrowedAmount[msg.sender] * interestRate) / 100;
        uint256 totalRepay = borrowedAmount[msg.sender] + interest;
        require(amount >= totalRepay, "Repay amount insufficient");

        token.transferFrom(msg.sender, address(this), totalRepay);
        borrowedAmount[msg.sender] = 0;
        emit Repaid(msg.sender, totalRepay);
    }

    // 🔹 Withdraw collateral after full repayment
    function withdraw() external {
        require(borrowedAmount[msg.sender] == 0, "Loan not repaid");
        uint256 amount = deposits[msg.sender];
        require(amount > 0, "No balance to withdraw");

        deposits[msg.sender] = 0;
        token.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
}
