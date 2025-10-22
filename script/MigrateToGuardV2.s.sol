// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RumpelGuard_V2} from "../src/RumpelGuard_V2.sol";
import {RumpelTimelockRegistry} from "../src/RumpelTimelockRegistry.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";

/// @notice Script to migrate existing Rumpel Wallets to Guard V2 with timelock support
contract MigrateToGuardV2Script is Script {
    // Mainnet addresses
    address public constant MAINNET_SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2;
    address public constant MAINNET_RUMPEL_GUARD = 0x9000FeF2846A5253fD2C6ed5241De0fddb404302;
    address public constant MAINNET_RUMPEL_MODULE = 0x28c3498B4956f4aD8d4549ACA8F66260975D361a;
    address public constant MAINNET_FACTORY = 0x0000000000000000000000000000000000000000; // TODO: Add factory address
    address public constant MAINNET_ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    // HyperEVM addresses
    address public constant HYPEREVM_SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2;
    address public constant HYPEEVM_RUMPEL_GUARD = 0x33e3fcA5C2972781a32Ca0F034Ae293d77962210;
    address public constant HYPEEVM_RUMPEL_MODULE = 0xa1804146617bFDb81dF7bf35a1dCC02f922559Fe;
    address public constant HYPEREVM_FACTORY = 0x0000000000000000000000000000000000000000; // TODO: Add factory address
    address public constant HYPEREVM_ADMIN = 0x3ffd3d3695Ee8D51A54b46e37bACAa86776A8CDA;

    RumpelGuard_V2 public guardV2;
    RumpelTimelockRegistry public timelockRegistry;

    function setUp() public {}

    /// @notice Deploy new Guard V2 and Timelock Registry
    function deployContracts() public returns (RumpelGuard_V2, RumpelTimelockRegistry) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Determine which chain we're on
        uint256 chainId = block.chainid;
        address signMessageLib;
        address admin;

        if (chainId == 1) {
            signMessageLib = MAINNET_SIGN_MESSAGE_LIB;
            admin = MAINNET_ADMIN;
        } else if (chainId == 999) {
            signMessageLib = HYPEREVM_SIGN_MESSAGE_LIB;
            admin = HYPEREVM_ADMIN;
        } else {
            revert("Unsupported chain");
        }

        // Deploy new contracts
        guardV2 = new RumpelGuard_V2(signMessageLib);
        timelockRegistry = new RumpelTimelockRegistry();

        console.log("Deployed RumpelGuard_V2 at:", address(guardV2));
        console.log("Deployed RumpelTimelockRegistry at:", address(timelockRegistry));

        // Configure guard to use registry
        guardV2.setTimelockRegistry(address(timelockRegistry));
        console.log("Configured guard to use registry");

        // Copy all allowlist settings from old guard to new guard
        // Note: This needs to be done manually or via a script that reads from the old guard
        console.log("WARNING: You must copy allowlist settings from old guard to new guard");
        console.log("Old guard address:", chainId == 1 ? MAINNET_RUMPEL_GUARD : HYPEEVM_RUMPEL_GUARD);

        // Transfer ownership to admin
        guardV2.transferOwnership(admin);
        timelockRegistry.transferOwnership(admin);

        console.log("Transferred ownership to admin:", admin);

        vm.stopBroadcast();

        return (guardV2, timelockRegistry);
    }

    /// @notice Migrate a batch of wallets to the new guard
    /// @dev This must be called by the admin via the RumpelModule
    /// @param module The RumpelModule contract
    /// @param wallets Array of wallet addresses to migrate
    /// @param newGuard The new guard address
    function migrateWallets(RumpelModule module, address[] calldata wallets, address newGuard) public {
        require(wallets.length > 0, "No wallets to migrate");

        RumpelModule.Call[] memory calls = new RumpelModule.Call[](wallets.length);

        for (uint256 i = 0; i < wallets.length;) {
            calls[i] = RumpelModule.Call({
                safe: ISafe(wallets[i]),
                to: wallets[i], // Calling the Safe itself
                data: abi.encodeCall(ISafe.setGuard, (newGuard)),
                operation: Enum.Operation.Call
            });

            unchecked {
                ++i;
            }
        }

        // Execute batch migration
        module.exec(calls);

        console.log("Migrated", wallets.length, "wallets to new guard");
    }

    /// @notice Update factory to use new guard for new wallets
    /// @param factory The RumpelWalletFactory contract
    /// @param newGuard The new guard address
    function updateFactory(RumpelWalletFactory factory, address newGuard) public {
        factory.setParam("RUMPEL_GUARD", newGuard);
        console.log("Updated factory to use new guard");
    }

    /// @notice Complete migration flow for a specific chain
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contracts
        (RumpelGuard_V2 newGuard, RumpelTimelockRegistry registry) = deployContracts();

        console.log("\n=== Migration Instructions ===");
        console.log("1. Copy allowlist settings from old guard to new guard");
        console.log("2. Call migrateWallets() with the list of wallet addresses");
        console.log("3. Call updateFactory() to use new guard for new wallets");
        console.log("4. Block setGuard in RumpelModule to prevent future changes");
        console.log("\n=== Deployed Addresses ===");
        console.log("RumpelGuard_V2:", address(newGuard));
        console.log("RumpelTimelockRegistry:", address(registry));

        vm.stopBroadcast();
    }

    /// @notice Helper function to verify a wallet has been migrated
    /// @param wallet The wallet address to check
    /// @param expectedGuard The expected guard address
    function verifyMigration(address wallet, address expectedGuard) public view returns (bool) {
        // Read guard address from Safe storage
        // Guard is stored at: keccak256("guard_manager.guard.address")
        bytes32 guardSlot = keccak256("guard_manager.guard.address");
        address currentGuard = address(uint160(uint256(vm.load(wallet, guardSlot))));
        return currentGuard == expectedGuard;
    }

    /// @notice Batch verify migrations
    /// @param wallets Array of wallet addresses to verify
    /// @param expectedGuard The expected guard address
    function batchVerifyMigration(address[] calldata wallets, address expectedGuard)
        public
        view
        returns (bool[] memory)
    {
        bool[] memory results = new bool[](wallets.length);
        for (uint256 i = 0; i < wallets.length;) {
            results[i] = verifyMigration(wallets[i], expectedGuard);
            unchecked {
                ++i;
            }
        }
        return results;
    }
}
