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
import {RumpelConfig} from "./RumpelConfig.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract RumpelWalletFactoryScripts is Script {
    address public MAINNET_ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    address public MAINNET_RUMPEL_VAULT = 0xe47F9Dbbfe98d6930562017ee212C1A1Ae45ba61;

    address public MAINNET_SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // 1.3.0
    address public MAINNET_SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2; // 1.3.0
    address public MAINNET_SAFE_PROXY_FACTORY = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // 1.3.0

    // Hype addresses
    ISafeProxyFactory public HYPE_SAFE_PROXY_FACTORY = ISafeProxyFactory(0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC);
    address public HYPE_SAFE_SINGLETON = 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA;
    address public HYPE_SIGN_MESSAGE_LIB = 0x98FFBBF51bb33A056B08ddf711f289936AafF717;

    address public HYPE_OPERATOR = 0x200F8df85C37268F39e3Fae332E91730A2d049d5;
    address public HYPE_ADMIN = 0x3ffd3d3695Ee8D51A54b46e37bACAa86776A8CDA;
    address public HYPE_MERKLE_UPDATER = 0x800e8022528c36273044e144580859EA629e1B63;

    address public HYPE_RUMPEL_VAULT = 0xEa333eb11FC6ea62F6f4c2d73Cd9F2d994Ff3587;
    address public HYPE_FEUSD = 0x02c6a2fA58cC01A18B8D9E00eA48d65E4dF26c70;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        run(HYPE_ADMIN);
        vm.stopBroadcast();
    }

    function run(address admin) public returns (RumpelModule, RumpelGuard, RumpelWalletFactory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer:", deployer);

        RumpelModule rumpelModule = new RumpelModule(address(HYPE_SIGN_MESSAGE_LIB));

        RumpelGuard rumpelGuard = new RumpelGuard(address(HYPE_SIGN_MESSAGE_LIB));

        ValidationBeacon validationBeacon = new ValidationBeacon();
        CompatibilityFallbackHandler compatibilityFallbackHandler =
            new CompatibilityFallbackHandler(admin, validationBeacon);

        // Script that will be delegatecalled to enable modules
        InitializationScript initializationScript = new InitializationScript();

        RumpelWalletFactory rumpelWalletFactory = new RumpelWalletFactory(
            ISafeProxyFactory(HYPE_SAFE_PROXY_FACTORY),
            address(compatibilityFallbackHandler),
            HYPE_SAFE_SINGLETON,
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
            HYPE_RUMPEL_VAULT, PointTokenVault.trustClaimer.selector, RumpelGuard.AllowListState.ON
        );

        rumpelGuard.setCallAllowed(HYPE_FEUSD, IERC20.transfer.selector, RumpelGuard.AllowListState.ON);
        rumpelGuard.setCallAllowed(HYPE_FEUSD, IERC20.approve.selector, RumpelGuard.AllowListState.ON);

        // Populate initial allowlist
        // RumpelConfig.updateGuardAllowlist(rumpelGuard, "initial");

        https://rbskphftvfnpcetghldu.supabase.co/rest/v1/points_snapshots?select=*&addres=eq.0xfe82af4569830228dce4e75788452c213afec39b&order=week_number.asc&apikey=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJic2twaGZ0dmZucGNldGdobGR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyNzE0NzAsImV4cCI6MjA1NDg0NzQ3MH0.naRsLDRJHXRrBv2MVCUfZMaI17tDl9Lk-ZL8QoWuHLY

        rumpelGuard.transferOwnership(admin);
        rumpelModule.transferOwnership(admin);
        rumpelWalletFactory.transferOwnership(admin);

        console.log("RumpelWalletFactory deployed at", address(rumpelWalletFactory));

        return (rumpelModule, rumpelGuard, rumpelWalletFactory);
    }

    function updateGuardAndModuleLists(RumpelGuard rumpelGuard, RumpelModule rumpelModule, string memory tag) public {
        vm.startBroadcast(MAINNET_ADMIN); // Impersonating admin for safe tx building
        RumpelConfig.updateGuardAllowlist(rumpelGuard, tag);
        RumpelConfig.updateModuleBlocklist(rumpelModule, tag);
        vm.stopBroadcast();
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
