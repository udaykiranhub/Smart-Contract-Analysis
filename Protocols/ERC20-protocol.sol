// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyERC20Token {

    mapping(address => uint256) private _balances;


    mapping(address => mapping(address => uint256)) private _allowances;


    uint256 private _totalSupply;


    string public name;


    string public symbol;

    uint8 public decimals;
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(string memory _name, string memory _symbol, uint256 initialSupply, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = initialSupply * (10 ** uint256(decimals)); 
        _balances[msg.sender] = _totalSupply; 
    }

    // Function to get the total token supply
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Function to get the token balance of a specific address
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // Function to transfer tokens from the caller to a recipient
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Function to approve a spender to spend a certain amount of tokens on behalf of the caller
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to get the amount of tokens a spender is allowed to spend on behalf of an owner
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Function to transfer tokens from one address to another using allowance
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}
