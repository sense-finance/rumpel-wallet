// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {PointTokenVault} from "point-tokenization-vault/PointTokenVault.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {CompatibilityFallbackHandler, ValidationBeacon} from "../src/external/CompatibilityFallbackHandler.sol";
import {ISafeProxyFactory} from "../src/interfaces/external/ISafeProxyFactory.sol";
import {ISafe} from "../src/interfaces/external/ISafe.sol";
import {RumpelConfig} from "./RumpelConfig.sol";

contract RumpelWalletFactoryScripts is Script {
    address public MAINNET_ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    address public MAINNET_RUMPEL_VAULT = 0xe47F9Dbbfe98d6930562017ee212C1A1Ae45ba61;

    address public MAINNET_SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552; // 1.3.0
    address public MAINNET_SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2; // 1.3.0
    address public MAINNET_SAFE_PROXY_FACTORY = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2; // 1.3.0
    address public MAINNET_RUMPEL_GUARD = 0x9000FeF2846A5253fD2C6ed5241De0fddb404302;
    address public MAINNET_RUMPEL_MODULE = 0x28c3498B4956f4aD8d4549ACA8F66260975D361a;

    address public HYPEEVM_ADMIN = 0x3ffd3d3695Ee8D51A54b46e37bACAa86776A8CDA;
    address public HYPEEVM_RUMPEL_VAULT = 0xEa333eb11FC6ea62F6f4c2d73Cd9F2d994Ff3587;
    address public HYPEEVM_RUMPEL_GUARD = 0x33e3fcA5C2972781a32Ca0F034Ae293d77962210;
    address public HYPEEVM_RUMPEL_MODULE = 0xa1804146617bFDb81dF7bf35a1dCC02f922559Fe;

    bytes32 internal constant MODULE_SALT = keccak256("RUMPEL_MODULE_V1");
    bytes32 internal constant GUARD_SALT = keccak256("RUMPEL_GUARD_V1");
    bytes32 internal constant VALIDATION_BEACON_SALT = keccak256("RUMPEL_VALIDATION_BEACON_V1");
    bytes32 internal constant FALLBACK_HANDLER_SALT = keccak256("RUMPEL_COMPATIBILITY_FALLBACK_V1");
    bytes32 internal constant INITIALIZATION_SCRIPT_SALT = keccak256("RUMPEL_INITIALIZATION_SCRIPT_V1");
    bytes32 internal constant FACTORY_SALT = keccak256("RUMPEL_WALLET_FACTORY_V1");

    struct FactoryConstructorParams {
        ISafeProxyFactory proxyFactory;
        address fallbackHandler;
        address safeSingleton;
        address module;
        address guard;
        address initializationScript;
        address owner;
    }

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        run(MAINNET_ADMIN);
        vm.stopBroadcast();
    }

    function run(address admin) public returns (RumpelModule, RumpelGuard, RumpelWalletFactory) {
        ValidationBeacon validationBeacon =
            ValidationBeacon(_deployOrGet(VALIDATION_BEACON_SALT, type(ValidationBeacon).creationCode));

        CompatibilityFallbackHandler compatibilityFallbackHandler = CompatibilityFallbackHandler(
            _deployOrGet(
                FALLBACK_HANDLER_SALT,
                abi.encodePacked(type(CompatibilityFallbackHandler).creationCode, abi.encode(admin, validationBeacon))
            )
        );

        (
            RumpelModule rumpelModule,
            RumpelGuard rumpelGuard,
            InitializationScript initializationScript,
            RumpelWalletFactory rumpelWalletFactory
        ) = _deployCore(admin, compatibilityFallbackHandler);

        _configureCore(rumpelModule, rumpelGuard);

        _finalizeDeployment(rumpelModule, rumpelGuard, rumpelWalletFactory, admin);

        console.log("RumpelWalletFactory deployed at", address(rumpelWalletFactory));

        return (rumpelModule, rumpelGuard, rumpelWalletFactory);
    }

    function _deployCore(address admin, CompatibilityFallbackHandler compatibilityFallbackHandler)
        internal
        returns (
            RumpelModule rumpelModule,
            RumpelGuard rumpelGuard,
            InitializationScript initializationScript,
            RumpelWalletFactory rumpelWalletFactory
        )
    {
        initializationScript =
            InitializationScript(_deployOrGet(INITIALIZATION_SCRIPT_SALT, type(InitializationScript).creationCode));

        bytes memory moduleInitCode =
            abi.encodePacked(type(RumpelModule).creationCode, abi.encode(MAINNET_SIGN_MESSAGE_LIB, address(this)));
        rumpelModule = RumpelModule(_deployOrGet(MODULE_SALT, moduleInitCode));

        bytes memory guardInitCode =
            abi.encodePacked(type(RumpelGuard).creationCode, abi.encode(MAINNET_SIGN_MESSAGE_LIB, address(this)));
        rumpelGuard = RumpelGuard(_deployOrGet(GUARD_SALT, guardInitCode));

        FactoryConstructorParams memory params;
        params.proxyFactory = ISafeProxyFactory(MAINNET_SAFE_PROXY_FACTORY);
        params.fallbackHandler = address(compatibilityFallbackHandler);
        params.safeSingleton = MAINNET_SAFE_SINGLETON;
        params.module = address(rumpelModule);
        params.guard = address(rumpelGuard);
        params.initializationScript = address(initializationScript);
        params.owner = address(this);

        bytes memory factoryInitCode = abi.encodePacked(type(RumpelWalletFactory).creationCode, abi.encode(params));

        rumpelWalletFactory = RumpelWalletFactory(_deployOrGet(FACTORY_SALT, factoryInitCode));

        _ensureOwner(address(rumpelWalletFactory), admin);

        // Ownership of module and guard is still the script address at this point; transfer below.
    }

    function _configureCore(RumpelModule rumpelModule, RumpelGuard rumpelGuard) internal {
        address configOperator = rumpelModule.owner();
        address guardOwner = rumpelGuard.owner();
        if (configOperator != guardOwner) revert("module/guard owner mismatch");

        if (configOperator != address(this)) {
            // Already configured; skip to avoid unauthorized modifications.
            return;
        }

        // Prevent swapping out the Rumpel Module for one without a blocklist.
        rumpelModule.addBlockedModuleCall(address(0), ISafe.enableModule.selector);
        // Prevent disabling the module.
        rumpelModule.addBlockedModuleCall(address(0), ISafe.disableModule.selector);

        // Allow Safes to delegate pToken claiming
        rumpelGuard.setCallAllowed(
            MAINNET_RUMPEL_VAULT, PointTokenVault.trustClaimer.selector, RumpelGuard.AllowListState.ON
        );

        // Populate initial allowlist
        RumpelConfig.updateGuardAllowlist(rumpelGuard, "initial");
    }

    function updateGuardAndModuleLists(uint256 networkId, string memory tag) public {
        RumpelGuard rumpelGuard;
        RumpelModule rumpelModule;
        if (networkId == 1) {
            vm.startBroadcast(MAINNET_ADMIN); // Impersonating admin for safe tx building
            rumpelGuard = RumpelGuard(MAINNET_RUMPEL_GUARD);
            rumpelModule = RumpelModule(MAINNET_RUMPEL_MODULE);
        } else if (networkId == 999) {
            vm.startBroadcast(HYPEEVM_ADMIN);
            rumpelGuard = RumpelGuard(HYPEEVM_RUMPEL_GUARD);
            rumpelModule = RumpelModule(HYPEEVM_RUMPEL_MODULE);
        } else {
            revert("Unknown ChainId");
        }

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

    function _deployOrGet(bytes32 salt, bytes memory creationCode) internal returns (address deployed) {
        address predicted = CREATE3.getDeployed(salt, address(this));
        if (predicted.code.length == 0) {
            deployed = CREATE3.deploy(salt, creationCode, 0);
        } else {
            deployed = predicted;
        }
    }

    function _ensureOwner(address ownableAddress, address admin) internal {
        Ownable ownable = Ownable(ownableAddress);
        if (ownable.owner() != admin) {
            ownable.transferOwnership(admin);
        }
    }

    function _finalizeDeployment(
        RumpelModule rumpelModule,
        RumpelGuard rumpelGuard,
        RumpelWalletFactory rumpelWalletFactory,
        address admin
    ) internal {
        _ensureOwner(address(rumpelGuard), admin);
        _ensureOwner(address(rumpelModule), admin);
        _ensureOwner(address(rumpelWalletFactory), admin);
    }
}
