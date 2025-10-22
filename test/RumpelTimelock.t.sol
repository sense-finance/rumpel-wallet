// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {RumpelTimelockRegistry} from "../src/RumpelTimelockRegistry.sol";
import {RumpelGuard_V2} from "../src/RumpelGuard_V2.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "../src/interfaces/external/ISafeProxyFactory.sol";
import {RumpelWalletFactoryScripts} from "../script/RumpelWalletFactory.s.sol";
import {MigrateToGuardV2Script} from "../script/MigrateToGuardV2.s.sol";

contract RumpelTimelockTest is Test {
    RumpelTimelockRegistry public registry;
    RumpelGuard_V2 public guardV2;
    RumpelWalletFactory public factory;
    RumpelModule public module;
    MockERC20 public token;

    address alice;
    uint256 alicePk;
    address admin = makeAddr("admin");

    // Mainnet addresses
    ISafeProxyFactory public PROXY_FACTORY = ISafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address public SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address public SIGN_MESSAGE_LIB = 0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2;

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);

        // Deploy timelock registry
        registry = new RumpelTimelockRegistry();

        // Deploy guard V2
        guardV2 = new RumpelGuard_V2(SIGN_MESSAGE_LIB);
        guardV2.setTimelockRegistry(address(registry));

        // Deploy module
        module = new RumpelModule(SIGN_MESSAGE_LIB);

        // Deploy factory with V2 guard
        InitializationScript initScript = new InitializationScript();
        factory = new RumpelWalletFactory(
            PROXY_FACTORY,
            address(0), // compatibilityFallback not needed for tests
            SAFE_SINGLETON,
            address(module),
            address(guardV2),
            address(initScript)
        );

        // Deploy mock token
        token = new MockERC20("Test Token", "TEST", 18);

        // Transfer ownership to admin
        guardV2.transferOwnership(admin);
        module.transferOwnership(admin);
        registry.transferOwnership(admin);
    }

    // Registry Tests ----

    function test_SetTimelock() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set timelock for token transfers
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 30 days);

        // Check timelock is set
        (bool locked, uint256 unlocksAt) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        assertTrue(locked);
        assertEq(unlocksAt, block.timestamp + 30 days);
    }

    function test_SetBatchTimelocks() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Create batch config
        RumpelTimelockRegistry.TimelockConfig[] memory configs = new RumpelTimelockRegistry.TimelockConfig[](2);
        configs[0] = RumpelTimelockRegistry.TimelockConfig({
            target: address(token),
            selector: ERC20.transfer.selector,
            duration: 30 days
        });
        configs[1] = RumpelTimelockRegistry.TimelockConfig({
            target: address(token),
            selector: ERC20.approve.selector,
            duration: 60 days
        });

        // Set batch timelocks
        vm.prank(safe);
        registry.setTimelocks(configs);

        // Verify both are set
        (bool locked1,) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        (bool locked2,) = registry.isLocked(safe, address(token), ERC20.approve.selector);
        assertTrue(locked1);
        assertTrue(locked2);
    }

    function test_CannotReduceTimelock() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set initial timelock
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 60 days);

        // Try to reduce it
        vm.prank(safe);
        vm.expectRevert();
        registry.setTimelock(address(token), ERC20.transfer.selector, 30 days);
    }

    function test_CanExtendTimelock() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set initial timelock
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 30 days);

        uint256 firstUnlock = registry.getUnlockTime(safe, address(token), ERC20.transfer.selector);

        // Extend it
        vm.warp(block.timestamp + 1 days);
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 60 days);

        uint256 secondUnlock = registry.getUnlockTime(safe, address(token), ERC20.transfer.selector);
        assertGt(secondUnlock, firstUnlock);
    }

    function test_WildcardTimelock() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set wildcard timelock for entire token
        vm.prank(safe);
        registry.setTargetTimelock(address(token), 30 days);

        // Both transfer and approve should be locked
        (bool locked1,) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        (bool locked2,) = registry.isLocked(safe, address(token), ERC20.approve.selector);
        assertTrue(locked1);
        assertTrue(locked2);
    }

    function test_TimelockExpires() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set timelock
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 30 days);

        // Check it's locked
        (bool locked,) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        assertTrue(locked);

        // Warp past expiration
        vm.warp(block.timestamp + 31 days);

        // Check it's unlocked
        (bool stillLocked,) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        assertFalse(stillLocked);
    }

    function test_AdminCanClearTimelock() public {
        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address safe = factory.createWallet(owners, 1, initCalls);

        // Set timelock
        vm.prank(safe);
        registry.setTimelock(address(token), ERC20.transfer.selector, 30 days);

        // Admin clears it
        vm.prank(admin);
        registry.adminClearTimelock(safe, address(token), ERC20.transfer.selector);

        // Check it's cleared
        (bool locked,) = registry.isLocked(safe, address(token), ERC20.transfer.selector);
        assertFalse(locked);
    }

    // Guard V2 Tests ----

    function test_GuardEnforcesTimelock() public {
        // Allow token transfers in guard
        vm.prank(admin);
        guardV2.setCallAllowed(address(token), ERC20.transfer.selector, RumpelGuard_V2.AllowListState.ON);

        // Allow registry calls in guard
        vm.prank(admin);
        guardV2.setCallAllowed(
            address(registry), RumpelTimelockRegistry.setTimelock.selector, RumpelGuard_V2.AllowListState.ON
        );

        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        ISafe safe = ISafe(factory.createWallet(owners, 1, initCalls));

        // Give safe some tokens
        token.mint(address(safe), 100e18);

        // Set timelock via safe
        bytes memory setTimelockData =
            abi.encodeCall(RumpelTimelockRegistry.setTimelock, (address(token), ERC20.transfer.selector, 30 days));
        _execSafeTx(safe, address(registry), 0, setTimelockData, Enum.Operation.Call);

        // Try to transfer - should revert due to timelock
        bytes memory transferData = abi.encodeCall(ERC20.transfer, (alice, 10e18));
        vm.expectRevert();
        this._execSafeTx(safe, address(token), 0, transferData, Enum.Operation.Call);

        // Warp past timelock
        vm.warp(block.timestamp + 31 days);

        // Now transfer should work
        this._execSafeTx(safe, address(token), 0, transferData, Enum.Operation.Call);
        assertEq(token.balanceOf(alice), 10e18);
    }

    function test_GuardAllowsUnlockedCalls() public {
        // Allow token transfers in guard
        vm.prank(admin);
        guardV2.setCallAllowed(address(token), ERC20.transfer.selector, RumpelGuard_V2.AllowListState.ON);

        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        ISafe safe = ISafe(factory.createWallet(owners, 1, initCalls));

        // Give safe some tokens
        token.mint(address(safe), 100e18);

        // Transfer without timelock should work
        bytes memory transferData = abi.encodeCall(ERC20.transfer, (alice, 10e18));
        _execSafeTx(safe, address(token), 0, transferData, Enum.Operation.Call);
        assertEq(token.balanceOf(alice), 10e18);
    }

    function test_GuardWithNoRegistry() public {
        // Deploy guard without registry
        RumpelGuard_V2 guardNoRegistry = new RumpelGuard_V2(SIGN_MESSAGE_LIB);
        guardNoRegistry.transferOwnership(admin);

        // Allow token transfers
        vm.prank(admin);
        guardNoRegistry.setCallAllowed(address(token), ERC20.transfer.selector, RumpelGuard_V2.AllowListState.ON);

        // Deploy factory with this guard
        InitializationScript initScript = new InitializationScript();
        RumpelWalletFactory factoryNoRegistry = new RumpelWalletFactory(
            PROXY_FACTORY, address(0), SAFE_SINGLETON, address(module), address(guardNoRegistry), address(initScript)
        );

        address[] memory owners = new address[](1);
        owners[0] = alice;
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        ISafe safe = ISafe(factoryNoRegistry.createWallet(owners, 1, initCalls));

        // Give safe some tokens
        token.mint(address(safe), 100e18);

        // Transfer should work (no registry to check)
        bytes memory transferData = abi.encodeCall(ERC20.transfer, (alice, 10e18));
        _execSafeTx(safe, address(token), 0, transferData, Enum.Operation.Call);
        assertEq(token.balanceOf(alice), 10e18);
    }

    // Integration Tests ----

    function test_CreateWalletWithDefaultTimelocks() public {
        // Allow registry calls in guard
        vm.prank(admin);
        guardV2.setCallAllowed(
            address(registry), RumpelTimelockRegistry.setTimelocks.selector, RumpelGuard_V2.AllowListState.ON
        );

        // Allow token transfers
        vm.prank(admin);
        guardV2.setCallAllowed(address(token), ERC20.transfer.selector, RumpelGuard_V2.AllowListState.ON);

        address[] memory owners = new address[](1);
        owners[0] = alice;

        // Create init calls to set timelocks during wallet creation
        RumpelTimelockRegistry.TimelockConfig[] memory configs = new RumpelTimelockRegistry.TimelockConfig[](1);
        configs[0] = RumpelTimelockRegistry.TimelockConfig({
            target: address(token),
            selector: ERC20.transfer.selector,
            duration: 30 days
        });

        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](1);
        initCalls[0] = InitializationScript.InitCall({
            to: address(registry),
            data: abi.encodeCall(RumpelTimelockRegistry.setTimelocks, (configs))
        });

        // Create wallet with timelocks
        ISafe safe = ISafe(factory.createWallet(owners, 1, initCalls));

        // Verify timelock is set
        (bool locked,) = registry.isLocked(address(safe), address(token), ERC20.transfer.selector);
        assertTrue(locked);

        // Give safe tokens and try to transfer - should fail
        token.mint(address(safe), 100e18);
        bytes memory transferData = abi.encodeCall(ERC20.transfer, (alice, 10e18));
        vm.expectRevert();
        this._execSafeTx(safe, address(token), 0, transferData, Enum.Operation.Call);
    }

    // Helper Functions ----

    function _execSafeTx(ISafe safe, address to, uint256 value, bytes memory data, Enum.Operation operation) public {
        uint256 nonce = safe.nonce();
        bytes32 txHash = safe.getTransactionHash(to, value, data, operation, 0, 0, 0, address(0), payable(address(0)), nonce);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, txHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        safe.execTransaction(to, value, data, operation, 0, 0, 0, address(0), payable(address(0)), signature);
    }
}
