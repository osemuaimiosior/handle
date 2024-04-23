// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity = 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';

contract tokenSwap {
    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    mapping(string => address) listOfTokenAddress;

    constructor() {
        listOfTokenAddress['BNB'] = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;
    }

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    // This is an example payment address.
    address public USDTPaymentAccount = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

/// @param amountOut The exact amount of token to receive from the swap. - This will be the amount of the item we want to pay for.
/// @param amountInMaximum The amount of token we are willing to spend to receive the specified amount of specified toekn. - The amount we want to withdraw from our wallet.
/// @return amountIn The amount of token actually spent in the swap.
function swapExactOutputSingle(uint256 amountOut, string calldata _tokenIn,  uint256 amountInMaximum) external returns (uint256 amountIn) {
        address _USDTOut = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        address _in = listOfTokenAddr(_tokenIn);
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to achieve a better swap.
        TransferHelper.safeApprove(_in, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: _in,
                tokenOut: _USDTOut,
                fee: poolFee,
                recipient: USDTPaymentAccount,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        amountIn = swapRouter.exactOutputSingle(params);

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(_in, address(swapRouter), 0);
            TransferHelper.safeTransfer(_in, msg.sender, amountInMaximum - amountIn);
        }
    }


    function getTokenBalance() public view returns (uint){

    }

    function listOfTokenAddr (string calldata tokenSymbol) view private returns (address) {
        return listOfTokenAddress[tokenSymbol];
    }
}