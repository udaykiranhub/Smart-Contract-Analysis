// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract UniswapPair {
    address public token0;
    address public token1;
    mapping(address => uint256) public reserves;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1);
    event Swapped(address indexed trader, address tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        
        reserves[token0] += amount0;
        reserves[token1] += amount1;

        emit LiquidityAdded(msg.sender, amount0, amount1);
    }

    function swap(address tokenIn, uint256 amountIn) external {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        address tokenOut = (tokenIn == token0) ? token1 : token0;
        uint256 amountOut = getAmountOut(amountIn, reserves[tokenIn], reserves[tokenOut]);

        require(amountOut > 0, "Insufficient liquidity");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        reserves[tokenIn] += amountIn;
        reserves[tokenOut] -= amountOut;

        emit Swapped(msg.sender, tokenIn, amountIn, amountOut);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }
}

contract UniswapFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed tokenA, address indexed tokenB, address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical tokens not allowed");
        require(getPair[tokenA][tokenB] == address(0), "Pair already exists");

        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB));
        pair = address(new UniswapPair{salt: salt}(tokenA, tokenB));

        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        allPairs.push(pair);

        emit PairCreated(tokenA, tokenB, pair);
    }
}




interface IUniswapFactory {
    function getPair(address, address) external view returns (address);
}

interface IUniswapPair {
    function swap(address tokenIn, uint256 amountIn) external;
}

contract UniswapRouter {
    IUniswapFactory public factory;

    constructor(address _factory) {
        factory = IUniswapFactory(_factory);
    }

    function swapExactTokens(address tokenA, address tokenB, uint256 amountIn) external {
        address pair = factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        IUniswapPair(pair).swap(tokenA, amountIn);
    }



}

///////////////////////////////////////////////////////////////
UniswapPair (Liquidity Pool) → The Exchange Booth
Think of this as a currency exchange counter.

People deposit two currencies (e.g., USD and EUR) into the counter.

The exchange rate is determined automatically based on supply and demand.

You can swap USD for EUR or vice versa using the available liquidity.




2️⃣ UniswapFactory (Factory) → The Bank That Creates Exchange Counters
This is like a bank that sets up new exchange counters for different currencies.

If people want a USD-to-Bitcoin exchange, the bank creates a new counter for it.

The factory contract deploys new UniswapPair contracts for each trading pair (USD/EUR, BTC/ETH, etc.).






3️⃣ UniswapRouter (Swap Facilitator) → The Cashier That Helps You Exchange Money
This is like a cashier at the bank who helps customers swap their money.

Instead of directly interacting with the exchange booth, customers tell the cashier how much they want to exchange.

The router finds the correct exchange counter (pair contract) and processes the swap.

