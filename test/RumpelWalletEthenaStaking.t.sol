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

interface IEthenaLpStaking {
    struct StakeData {
        uint256 stakedAmount;
        uint152 coolingDownAmount;
        uint104 cooldownStartTimestamp;
    }

    function stakes(address user, address token) external view returns (StakeData memory);
    function stake(address token, uint104 amount) external;
    function unstake(address token, uint104 amount) external;
    function withdraw(address token, uint104 amount) external;
}

contract RumpelWalletEthenaStaking is Test {
    address public GUARD_OWNER = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    address public constant MAINNET_USDE = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address public constant MAINNET_ETHENA_LP_STAKING = 0x8707f238936c12c309bfc2B9959C35828AcFc512;

    RumpelGuard public rumpelGuard = RumpelGuard(0x9000FeF2846A5253fD2C6ed5241De0fddb404302);
    RumpelModule public rumpelModule = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    RumpelWalletFactory public rumpelWalletFactory = RumpelWalletFactory(0x5774AbCF415f34592514698EB075051E97Db2937);

    address alice;
    uint256 alicePk;

    struct SafeTX {
        address to;
        uint256 value;
        bytes data;
        Enum.Operation operation;
    }

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 FORK_BLOCK_NUMBER = 21339956; // Dec-06-2024 12:44:47 AM UTC
        vm.createSelectFork(MAINNET_RPC_URL, FORK_BLOCK_NUMBER);
    }

    function test_UnstakeAndWithdraw() public {
        RumpelWalletFactoryScripts scripts = new RumpelWalletFactoryScripts();

        address[] memory owners = new address[](1);
        owners[0] = address(alice);

        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = rumpelWalletFactory.createWallet(owners, 1, initCalls);
        assertTrue(safe != address(0));

        // Mint alice USDe
        deal(MAINNET_USDE, alice, 1 ether);
        // Transfer USDe to safe
        vm.prank(alice);
        ERC20(MAINNET_USDE).transfer(safe, 1 ether);
        assertEq(ERC20(MAINNET_USDE).balanceOf(safe), 1 ether);

        // Approve ethena staking
        bytes memory approveData = abi.encodeWithSelector(ERC20.approve.selector, MAINNET_ETHENA_LP_STAKING, 1 ether);
        _execSafeTx(ISafe(safe), MAINNET_USDE, 0, approveData, Enum.Operation.Call);

        // Stake USDe in ethena staking
        bytes memory stakeData = abi.encodeWithSelector(IEthenaLpStaking.stake.selector, MAINNET_USDE, 1 ether);
        _execSafeTx(ISafe(safe), MAINNET_ETHENA_LP_STAKING, 0, stakeData, Enum.Operation.Call);

        assertEq(ERC20(MAINNET_USDE).balanceOf(safe), 0);
        assertEq(IEthenaLpStaking(MAINNET_ETHENA_LP_STAKING).stakes(safe, MAINNET_USDE).stakedAmount, 1 ether);

        // Unstake USDe from ethena staking
        bytes memory unstakeData = abi.encodeWithSelector(IEthenaLpStaking.unstake.selector, MAINNET_USDE, 1 ether);
        _execSafeTx(ISafe(safe), MAINNET_ETHENA_LP_STAKING, 0, unstakeData, Enum.Operation.Call);

        assertEq(ERC20(MAINNET_USDE).balanceOf(safe), 0);
        assertEq(IEthenaLpStaking(MAINNET_ETHENA_LP_STAKING).stakes(safe, MAINNET_USDE).stakedAmount, 0);
        assertEq(IEthenaLpStaking(MAINNET_ETHENA_LP_STAKING).stakes(safe, MAINNET_USDE).coolingDownAmount, 1 ether);
        assertEq(
            IEthenaLpStaking(MAINNET_ETHENA_LP_STAKING).stakes(safe, MAINNET_USDE).cooldownStartTimestamp,
            block.timestamp
        );

        // Advance time to cooldown end
        vm.warp(block.timestamp + 7 days);

        // Withdraw USDe from ethena staking, expect revert before update
        bytes memory withdrawData = abi.encodeWithSelector(IEthenaLpStaking.withdraw.selector, MAINNET_USDE, 1 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                RumpelGuard.CallNotAllowed.selector, address(MAINNET_ETHENA_LP_STAKING), bytes4(withdrawData)
            )
        );
        this._execSafeTx(ISafe(safe), MAINNET_ETHENA_LP_STAKING, 0, withdrawData, Enum.Operation.Call);

        scripts.updateGuardAndModuleLists(rumpelGuard, rumpelModule, "ethena-staking-lp-withdraw");

        // Withdraw USDe from ethena staking successfully after withdraw added
        _execSafeTx(ISafe(safe), MAINNET_ETHENA_LP_STAKING, 0, withdrawData, Enum.Operation.Call);

        assertEq(ERC20(MAINNET_USDE).balanceOf(safe), 1 ether);
        assertEq(IEthenaLpStaking(MAINNET_ETHENA_LP_STAKING).stakes(safe, MAINNET_USDE).coolingDownAmount, 0);

        // Send USDe to alice
        bytes memory transferData = abi.encodeWithSelector(ERC20.transfer.selector, alice, 1 ether);
        _execSafeTx(ISafe(safe), MAINNET_USDE, 0, transferData, Enum.Operation.Call);

        assertEq(ERC20(MAINNET_USDE).balanceOf(alice), 1 ether);
        assertEq(ERC20(MAINNET_USDE).balanceOf(safe), 0);
    }

    function _execSafeTx(ISafe safe, address to, uint256 value, bytes memory data, Enum.Operation operation) public {
        SafeTX memory safeTX = SafeTX({to: to, value: value, data: data, operation: operation});

        uint256 nonce = safe.nonce();

        bytes32 txHash = safe.getTransactionHash(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), nonce
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, txHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        safe.execTransaction(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), signature
        );
    }
}
