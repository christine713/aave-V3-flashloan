// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {FlashLoanSimpleReceiverBase} from "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import { SafeMath } from "https://github.com/aave/aave-v3-core/contracts/dependencies/openzeppelin/contracts/SafeMath.sol";

// ----------------------INTERFACE------------------------------
// Uniswap
// Some helper function, it is totally fine if you can finish the lab without using these functions
interface IUniswapV2Router {

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns
     (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (
      uint amountA, uint amountB, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}

interface IUniswapV2Pair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external view returns (address);
}

// ----------------------IMPLEMENTATION------------------------------
contract FlashloanV3 is FlashLoanSimpleReceiverBase {
    // TODO: define constants used in the contract including ERC-20 tokens, Uniswap router, Aave address provider, etc.
    //  Aave V3 DAI address (Goerli testnet): 0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464
    //  Uniswap V2 router address (Goerli testnet): 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    //    *** Your code here ***
    address private immutable daiAddr =
        0xDF1742fE5b0bFc12331D8EAec6b478DfDbD31464;
    address  private immutable tkaAddr =
        0x6c12fF9aDDE41D579f7D4331a9628C6f75657B6B;
    address  private immutable tkbAddr =
        0x6A3d966285E32Cd11A89e197Cd338C1F31eF05C7;
    address  private immutable uniRouter =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IERC20 private dai;
    IERC20 private tka;
    IERC20 private tkb;
    // END TODO
    using SafeMath for uint256;
    address payable owner;

    constructor(address _addressProvider)FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
    }

    /**
     * Allows users to access liquidity of one reserve or one transaction as long as the amount taken plus fee is returned.
     * @param _asset The address of the asset you want to borrow
     * @param _amount The borrow amount
     **/
    // Doc: https://docs.aave.com/developers/core-contracts/pool#flashloansimple
    function RequestFlashLoan(address _asset, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _asset;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        // POOL comes from FlashLoanSimpleReceiverBase
        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    /**
     * This function is called after your contract has received the flash loaned amount
     * @param asset The address of the asset you want to borrow
     * @param amount The borrow amount
     * @param premium The borrow fee
     * @param initiator The address initiates this function
     * @param params Arbitrary bytes-encoded params passed from flash loan
     * @return  true or false
     **/
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        // TODO: implement your logic
        IERC20(daiAddr).approve(uniRouter,2**256-1);
        address[] memory route1 = new address[](2);
        route1[0] = daiAddr; 
        route1[1] = tkbAddr;
        uint256 tkB = IUniswapV2Router(uniRouter).swapExactTokensForTokens(amount,0,route1,address(this),block.timestamp)[1]; 

        IERC20(tkbAddr).approve(uniRouter,2**256-1);
        address[] memory route2 = new address[](2);
        route2[0] = tkbAddr; 
        route2[1] = tkaAddr;
        uint256 tkA = IUniswapV2Router(uniRouter).swapExactTokensForTokens(tkB,0,route2,address(this),block.timestamp)[1]; 

        IERC20(tkaAddr).approve(uniRouter,2**256-1);
        address[] memory route3 = new address[](2);
        route3[0] = tkaAddr; 
        route3[1] = daiAddr;
        uint256 Dai = IUniswapV2Router(uniRouter).swapExactTokensForTokens(tkA,0,route3,address(this),block.timestamp)[1]; 

       
        // Don't forget to payback the amount of the borrowed asset + flash loan fee 
        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwed);
        // END TODO
        return true;
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    receive() external payable {}

}