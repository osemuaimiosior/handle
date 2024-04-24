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
        listOfTokenAddress['USDC'] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        listOfTokenAddress['SOL'] = 0x570A5D26f7765Ecb712C0924E4De545B89fD43dF;
        listOfTokenAddress['XRP'] = 0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE;
        listOfTokenAddress['DAI'] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        listOfTokenAddress['LINK'] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        listOfTokenAddress['ADA'] = 0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47;
        listOfTokenAddress['ARB'] = 0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1;
        listOfTokenAddress['NEAR'] = 0x85F17Cf997934a597031b2E18a9aB6ebD4B9f6a4;
        listOfTokenAddress['TRX'] = 0x50327c6c5a14DCaDE707ABad2E27eB517df87AB5;
    }

    // We will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    // This is an example payment address.
    address public USDTPaymentAccount = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

/// @param amountOut The exact amount of token to receive from the swap, that will be paid to the merchant - This will be the amount of the item we want to pay for.
/// @param amountInMaximum The amount of token we are willing to spend to receive the specified amount of specified token. - The amount we want to withdraw from our wallet.
/// @return amountIn The amount of token actually spent in the swap.- The amount that will be required for the buyer to send to the contract to carry out the swap and pay the merchant.
/// @param _tokenIn The symbol of the token the payer has selected to pay/make the swap with.

function swapExactOutputSingle(uint256 amountOut, string calldata _tokenIn,  uint256 amountInMaximum) external returns (uint256 amountIn) {
        address _USDTOut = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        address _in = listOfTokenAddress[_tokenIn];

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
}