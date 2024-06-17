// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RumpelWalletFactory, SafeModule, EnableModules} from "../src/RumpelWallet.sol";

import {ISafe} from "../src/interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "../src/interfaces/external/ISafeProxyFactory.sol";

contract RumpelWalletTest is Test {
    RumpelWalletFactory public rumpelWalletFactory;
    SafeModule public safeModule;
    EnableModules public enableModules;

    ISafeProxyFactory public PROXY_FACTORY = ISafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address public SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

    function setUp() public {
        rumpelWalletFactory = new RumpelWalletFactory(PROXY_FACTORY, SAFE_SINGLETON);
        safeModule = new SafeModule();

        enableModules = new EnableModules();

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }

    function test_createWalletModuleEnabled() public {
        address[] memory owners = new address[](1);
        owners[0] = address(0);
        address[] memory modules = new address[](1);
        modules[0] = address(safeModule);
        ISafe safe = ISafe(
            rumpelWalletFactory.createWallet(
                owners, 1, address(enableModules), "", address(0), address(0), 0, payable(address(0)), modules
            )
        );

        assertEq(safe.isModuleEnabled(address(safeModule)), true);
    }
}
