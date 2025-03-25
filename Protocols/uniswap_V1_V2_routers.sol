---------> Uniswap V1 (2018)

.In Uniswap V1, every ERC-20 token was paired directly with ETH.

.If you wanted to swap Token A for Token B, you had to:

.Swap Token A → ETH.

.Swap ETH → Token B.
 .ETH as intermediary

--Limitations:

.Extra gas fees due to the ETH intermediary.

.No direct token-to-token swaps.



--------> uniswap V2(2020)
.Introduced direct ERC-20 to ERC-20 swaps, eliminating ETH as an intermediary.

.Used pair contracts that hold reserves of two tokens.

.Introduced flash swaps, allowing users to borrow assets temporarily.

.Implemented better price oracles to prevent manipulation.

.More efficient gas usage.
 .ETH is not intermediary


*** Uniswap V1 ****

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV1 {
    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline) external payable;
    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline) external;
}

contract UniswapV1Swap {
    address private constant UNISWAP_V1_EXCHANGE =
        0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14; // Example exchange address

    address private constant TOKEN =
        0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT Token

    IUniswapV1 public uniswapV1;

    constructor() {
        uniswapV1 = IUniswapV1(UNISWAP_V1_EXCHANGE);
    }

    function swapTokenForETH(uint256 amountIn, uint256 minEth) external {
        IERC20(TOKEN).transferFrom(msg.sender, address(this), amountIn);
        IERC20(TOKEN).approve(UNISWAP_V1_EXCHANGE, amountIn);

        uniswapV1.tokenToEthSwapInput(amountIn, minEth, block.timestamp + 300);
    }

    function swapETHForToken(uint256 minTokens) external payable {
        uniswapV1.ethToTokenSwapInput{value: msg.value}(minTokens, block.timestamp + 300);
    }
}




**** uniswap V2 ****



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV2Swap {
    address private constant UNISWAP_V2_ROUTER =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // Uniswap V2 Router Address

    address private constant USDT =
        0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT Token
    address private constant WETH =
        0xC02aaa39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH Token

    IUniswapV2Router02 public uniswapRouter;

    constructor() {
        uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    }

    function swapUSDTForWETH(uint256 amountIn, uint256 amountOutMin) external {
        IERC20(USDT).transferFrom(msg.sender, address(this), amountIn);
        IERC20(USDT).approve(address(uniswapRouter), amountIn);

        address ;
        path[0] = USDT;
        path[1] = WETH;

        uniswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 300
        );
    }
}


****manual Swap***
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

contract UniswapV2ManualSwap {
    address private constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f; // Ethereum Mainnet Factory
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT Mainnet Address
    address private constant WETH = 0xC02aaa39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH Mainnet Address

    function getPairAddress(address tokenA, address tokenB) public view returns (address) {
        return IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(tokenA, tokenB);
    }

    function getAmountOut(uint256 amountIn, address tokenA, address tokenB) public view returns (uint256 amountOut) {
        address pair = getPairAddress(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(pair).getReserves();
        (uint112 reserveIn, uint112 reserveOut) = tokenA < tokenB ? (reserve0, reserve1) : (reserve1, reserve0);

        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "Invalid input values");

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function swapUSDTForWETH(uint256 amountIn, uint256 amountOutMin) external {
        address pair = getPairAddress(USDT, WETH);
        require(pair != address(0), "Pair does not exist");

        // Transfer USDT to the pair contract
        IERC20(USDT).transferFrom(msg.sender, pair, amountIn);

        // Compute the output amount
        uint256 amountOut = getAmountOut(amountIn, USDT, WETH);
        require(amountOut >= amountOutMin, "Slippage too high");

        // Execute the swap
        (uint256 amount0Out, uint256 amount1Out) = USDT < WETH ? (uint256(0), amountOut) : (amountOut, uint256(0));
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, msg.sender, new bytes(0));
    }
}
