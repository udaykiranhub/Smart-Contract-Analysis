// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Defi {
    //Contract providing the liquidity and the Swaping Token for ETH and vice versa
    IERC20 public token;
    uint256 public tokenReserve;//storing tokens
    uint256 public ethReserve;//storing ETH
receive() external payable {}

//Loging the events
    event LiquidityProvided(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event ETHToTokenSwap(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
     event TokenToETHSwap(address indexed buyer, uint256 tokenAmount, uint256 ethAmount);

    constructor(IERC20 _token) {
        token = _token; //TOken address 
    }

    // Function for providing liquidity (both ETH and tokens)
    function provideLiquidity(uint256 tokenAmount) external payable {
        require(msg.value > 0 && tokenAmount > 0, "Provide ETH and tokens");

        // Transfer tokens from liquidity provider to the contract
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        //must approve

        // Update the reserves
        ethReserve += msg.value;
          tokenReserve += tokenAmount;

    emit LiquidityProvided(msg.sender, msg.value, tokenAmount);
   
   
    }

    // Swap ETH for tokens
    function swapETHForTokens() external payable {//sending ETH
          require(msg.value > 0, "Send ETH to swap for tokens");
         require(ethReserve > 0 && tokenReserve > 0, "Insufficient liquidity");

        // Calculate how many tokens to provide using a simple formula
        uint256 tokenAmount = (msg.value * tokenReserve) / ethReserve;

        require(tokenAmount <= tokenReserve, "Not enough tokens in the pool");

        // Transfer tokens to the buyer
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");//Direct transfering Tokens
        //from the contract

        // Update reserves
        ethReserve += msg.value;
        tokenReserve -= tokenAmount;

        emit ETHToTokenSwap(msg.sender, msg.value, tokenAmount);
    }

    // Swap Tokens for ETH
    function swapTokensForETH(uint256 tokenAmount) external {//entering the amount of the tokens
    
        require(tokenAmount > 0, "Send tokens to swap for ETH");
        require(ethReserve > 0 && tokenReserve > 0, "Insufficient liquidity");

        // Calculate how much ETH to provide using a simple formula
        uint256 ethAmount = (tokenAmount * ethReserve) / tokenReserve;

        require(ethAmount <= ethReserve, "Not enough ETH in the pool");

        // Transfer tokens to the contract
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

        // Transfer ETH to the buyer
        payable(msg.sender).transfer(ethAmount);

        // Update reserves
        ethReserve -= ethAmount;
        tokenReserve += tokenAmount;

        emit TokenToETHSwap(msg.sender, tokenAmount, ethAmount);
    }

    // Get token amount based on ETH input
    function getTokenAmount(uint256 ethAmount) public view returns (uint256) {
        return (ethAmount * tokenReserve) / ethReserve;
    }

    // Get ETH amount based on token input 
    function getETHAmount(uint256 tokenAmount) public view returns (uint256) {
        return (tokenAmount * ethReserve) / tokenReserve;
    }
}
