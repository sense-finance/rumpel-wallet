// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";

import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";
import {RumpelWalletFactoryScripts} from "../script/RumpelWalletFactory.s.sol";

contract RumpelWalletSwapOwnerTest is Test {
    RumpelModule public rumpelModule = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    RumpelGuard public rumpelGuard = RumpelGuard(0x9000FeF2846A5253fD2C6ed5241De0fddb404302);
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
        uint256 FORK_BLOCK_NUMBER = 21748243; // Feb-01-2025 12:59:47 AM +UTC
        vm.createSelectFork(MAINNET_RPC_URL, FORK_BLOCK_NUMBER);
    }

    function test_SwapOwner() public {
        RumpelWalletFactoryScripts scripts = new RumpelWalletFactoryScripts();

        address[] memory owners = new address[](1);
        owners[0] = address(alice);

        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = rumpelWalletFactory.createWallet(owners, 1, initCalls);

        address NEW_OWNER = address(0x123);

        assertEq(ISafe(safe).getOwners().length, 1);
        assertEq(ISafe(safe).getOwners()[0], address(alice));

        bytes memory swapOwnerData =
            abi.encodeWithSelector(ISafe.swapOwner.selector, address(0x1), address(alice), NEW_OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(RumpelGuard.CallNotAllowed.selector, address(safe), bytes4(swapOwnerData))
        );
        this._execSafeTx(ISafe(safe), safe, 0, swapOwnerData, Enum.Operation.Call);

        assertEq(ISafe(safe).getOwners().length, 1);
        assertEq(ISafe(safe).getOwners()[0], address(alice));

        // Run the script to enable the swapOwner call
        scripts.updateGuardAndModuleLists(rumpelGuard, rumpelModule, "enable-swap-owner");

        this._execSafeTx(ISafe(safe), safe, 0, swapOwnerData, Enum.Operation.Call);

        assertEq(ISafe(safe).getOwners().length, 1);
        assertEq(ISafe(safe).getOwners()[0], NEW_OWNER);
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
