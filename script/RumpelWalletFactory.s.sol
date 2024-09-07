// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {PointTokenVault} from "point-tokenization-vault/PointTokenVault.sol";

import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {CompatibilityFallbackHandler, ValidationBeacon} from "../src/external/CompatibilityFallbackHandler.sol";
import {ISafeProxyFactory} from "../src/interfaces/external/ISafeProxyFactory.sol";
import {ISafe} from "../src/interfaces/external/ISafe.sol";
import {RumpelGuardConfig} from "./RumpelGuardConfig.sol";

contract RumpelWalletFactoryScripts is Script {
    address public MAINNET_ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    // TODO
    address public MAINNET_RUMPEL_VAULT = 0x1EeEBa76f211C4Dce994b9c5A74BDF25DB649Fa1; // TODO: update with new address after vault deployment
    // TODO

    address public MAINNET_SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // 1.3.0
    address public MAINNET_SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2; // 1.3.0
    address public MAINNET_SAFE_PROXY_FACTORY = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // 1.3.0

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        run(MAINNET_ADMIN);
        vm.stopBroadcast();
    }

    function run(address admin) public returns (RumpelModule, RumpelGuard, RumpelWalletFactory) {
        RumpelModule rumpelModule = new RumpelModule(MAINNET_SIGN_MESSAGE_LIB);

        RumpelGuard rumpelGuard = new RumpelGuard(MAINNET_SIGN_MESSAGE_LIB);

        ValidationBeacon validationBeacon = new ValidationBeacon();
        CompatibilityFallbackHandler compatibilityFallbackHandler =
            new CompatibilityFallbackHandler(admin, validationBeacon);

        // Script that will be delegatecalled to enable modules
        InitializationScript initializationScript = new InitializationScript();

        RumpelWalletFactory rumpelWalletFactory = new RumpelWalletFactory(
            ISafeProxyFactory(MAINNET_SAFE_PROXY_FACTORY),
            address(compatibilityFallbackHandler),
            MAINNET_SAFE_SINGLETON,
            address(rumpelModule),
            address(rumpelGuard),
            address(initializationScript)
        );

        // Prevent us from just swapping out the Rumpel Module for one without a blocklist.
        rumpelModule.addBlockedModuleCall(address(0), ISafe.enableModule.selector);
        // Prevent us from disabling the module.
        rumpelModule.addBlockedModuleCall(address(0), ISafe.disableModule.selector);

        // Allow Safes to delegate pToken claiming
        rumpelGuard.setCallAllowed(
            MAINNET_RUMPEL_VAULT, PointTokenVault.trustClaimer.selector, RumpelGuard.AllowListState.ON
        );

        // Populate initial allowlist
        RumpelGuardConfig.setupProtocols(rumpelGuard);
        RumpelGuardConfig.setupTokens(rumpelGuard);

        rumpelGuard.transferOwnership(admin);
        rumpelModule.transferOwnership(admin);
        rumpelWalletFactory.transferOwnership(admin);

        console.log("RumpelWalletFactory deployed at", address(rumpelWalletFactory));

        return (rumpelModule, rumpelGuard, rumpelWalletFactory);
    }

    function addModuleCallBlocked(RumpelModule rumpelModule, address target, bytes4 functionSelector) public {
        rumpelModule.addBlockedModuleCall(target, functionSelector);
    }

    function setCallAllowed(
        RumpelGuard rumpelGuard,
        address target,
        bytes4 functionSelector,
        RumpelGuard.AllowListState allowListState
    ) public {
        rumpelGuard.setCallAllowed(target, functionSelector, allowListState);
    }

    function setModuleCallBlockedCallAllowed(
        RumpelModule rumpelModule,
        RumpelGuard rumpelGuard,
        address target,
        bytes4 functionSelector
    ) public {
        addModuleCallBlocked(rumpelModule, target, functionSelector);
        setCallAllowed(rumpelGuard, target, functionSelector, RumpelGuard.AllowListState.PERMANENTLY_ON);
    }

    function addBlockedModuleCall(RumpelModule rumpelModule, address target, bytes4 functionSelector) public {
        rumpelModule.addBlockedModuleCall(target, functionSelector);
    }

    // TODO: don't forget to make this call in the future
    function addSetGuardBlocked(RumpelModule rumpelModule) public {
        rumpelModule.addBlockedModuleCall(address(0), ISafe.setGuard.selector);
    }
}
