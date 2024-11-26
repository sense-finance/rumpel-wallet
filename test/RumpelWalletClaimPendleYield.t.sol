// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";
import {RumpelWalletFactoryScripts} from "../script/RumpelWalletFactory.s.sol";
import {RumpelConfig, IPendleRouterV4} from "../script/RumpelConfig.sol";

contract RumpelWalletClaimPendleYield is Test {
    address public GUARD_OWNER = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;
    RumpelModule public rumpelModule = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    RumpelGuard public rumpelGuard = RumpelGuard(0x9000FeF2846A5253fD2C6ed5241De0fddb404302);

    IStandardizedYield sySUSDE = IStandardizedYield(RumpelConfig.MAINNET_SY_SUSDE);
    ERC20 public sySUSDEErc20 = ERC20(RumpelConfig.MAINNET_SY_SUSDE);
    ERC20 public susdeErc20 = ERC20(RumpelConfig.MAINNET_SUSDE);

    IPendleRouterV4 public pendleRouterV3 = IPendleRouterV4(0x00000000005BBB0EF59571E58418F9a4357b68A0);
    IPendleRouterV4 public pendleRouterV4 = IPendleRouterV4(RumpelConfig.MAINNET_PENDLE_ROUTERV4);

    PendelYieldTokenFactory pendelYieldFactory = PendelYieldTokenFactory(0x273b4bFA3Bb30fe8F32c467b5f0046834557F072);
    PendelYieldToken yt = PendelYieldToken(RumpelConfig.MAINNET_YT_SUSDE_26DEC2024);

    struct SafeTX {
        address to;
        uint256 value;
        bytes data;
        Enum.Operation operation;
    }

    function setUp() public {
        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        uint256 desiredBlockNumber = 21246172;
        vm.rollFork(desiredBlockNumber);
    }

    function test_RouterV3() public {
        _testRedeem(address(pendleRouterV3));
    }

    // same test as v3 but v4 fails,
    // the tenderly simulation against v4 works from logged data works as expected
    // https://www.tdly.co/shared/simulation/1cdc9c33-d9b9-4b61-ad08-d3f7cd31e1e7
    function test_RouterV4() public {
        _testRedeem(address(pendleRouterV4));
    }

    function _testRedeem(address router) internal {
        // wallet with interest
        address wallet = 0x356bF754079D5A797da8884a328120016C1B8Ddb;

        // calc expected interest in SY terms
        uint256 principal = ERC20(address(yt)).balanceOf(wallet);
        (uint128 prevIndex,) = yt.userInterest(wallet);
        uint256 currentIndex = sySUSDE.exchangeRate();
        uint256 accruedInterest = (principal * (currentIndex - prevIndex) * 1e18) / (prevIndex * currentIndex);

        uint256 feePercentage = pendelYieldFactory.interestFeeRate();
        uint256 finalAmount = accruedInterest - (accruedInterest * feePercentage / 1e18);

        uint256 syBalanceBefore = sySUSDEErc20.balanceOf(wallet);

        address[] memory emptyAddressArray = new address[](0);
        address[] memory yts = new address[](1);
        yts[0] = RumpelConfig.MAINNET_YT_SUSDE_26DEC2024;

        // redeem interest from YT in SY tokens
        bytes memory data = abi.encodeWithSelector(0xf7e375e8, wallet, emptyAddressArray, yts, emptyAddressArray);
        console.logBytes(data);

        vm.prank(wallet);
        IPendleRouterV4(router).redeemDueInterestAndRewards(wallet, emptyAddressArray, yts, emptyAddressArray);

        uint256 syBalanceAfter = sySUSDEErc20.balanceOf(wallet);
        assertGt(syBalanceAfter, syBalanceBefore);

        uint256 usdceBefore = susdeErc20.balanceOf(wallet);

        // redeem interest from SY tokens for underlying
        vm.prank(wallet);
        sySUSDE.redeem(wallet, finalAmount, 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497, 0, false);

        uint256 usdceAfter = susdeErc20.balanceOf(wallet);
        assertGt(usdceAfter, usdceBefore);
    }
}

contract PendelYieldToken {
    struct UserInterest {
        uint128 index;
        uint128 accrued;
    }

    mapping(address => UserInterest) public userInterest;

    function redeemDueInterestAndRewards(
        address user,
        address[] calldata sys,
        address[] calldata yts,
        address[] calldata markets
    ) external {}
}

contract PendelYieldTokenFactory {
    uint128 public interestFeeRate;
}

interface IStandardizedYield {
    function redeem(
        address receiver,
        uint256 amountSharesToRedeem,
        address tokenOut,
        uint256 minTokenOut,
        bool burnFromInternalBalance
    ) external;

    function exchangeRate() external returns (uint256 res);
}
