// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {RumpelWalletFactory} from "../src/RumpelWallet.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {RumpelModule} from "../src/RumpelModule.sol";

import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "../src/interfaces/external/ISafeProxyFactory.sol";

contract RumpelWalletTest is Test {
    RumpelWalletFactory public rumpelWalletFactory;
    RumpelModule public rumpelModule;
    InitializationScript public initializationScript;
    RumpelGuard public rumpelGuard;
    Counter public counter;
    MockERC20 public mockToken;

    ISafeProxyFactory public PROXY_FACTORY = ISafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address public SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address public RUMPEL_VAULT = 0x1EeEBa76f211C4Dce994b9c5A74BDF25DB649Fa1;

    address alice;
    uint256 alicePk;

    address admin = makeAddr("admin");

    struct SafeTX {
        address to;
        uint256 value;
        bytes data;
        Enum.Operation operation;
    }

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");

        vm.startPrank(admin);
        rumpelModule = new RumpelModule(address(this));

        // Script to delegate call to enable modules
        initializationScript = new InitializationScript();

        rumpelGuard = new RumpelGuard();

        rumpelWalletFactory = new RumpelWalletFactory(
            PROXY_FACTORY, SAFE_SINGLETON, address(initializationScript), address(rumpelModule), address(rumpelGuard)
        );
        vm.stopPrank();

        counter = new Counter();
        mockToken = new MockERC20("Mock Token", "MTKN", 18);

        string memory MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
        uint256 mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }

    function test_createWalletRumpelModuleEnabled() public {
        address[] memory owners = new address[](1);
        owners[0] = address(alice);

        ISafe safe = ISafe(rumpelWalletFactory.createWallet(owners, 1, address(0), address(0), 0, payable(address(0))));

        assertEq(safe.isModuleEnabled(address(rumpelModule)), true);
    }

    function test_createWalletRumpelGuardSet() public {
        address[] memory owners = new address[](1);
        owners[0] = address(alice);

        ISafe safe = ISafe(rumpelWalletFactory.createWallet(owners, 1, address(0), address(0), 0, payable(address(0))));

        assertEq(
            address(uint160(uint256(vm.load(address(safe), keccak256("guard_manager.guard.address"))))),
            address(rumpelGuard)
        );
    }

    function testFuzz_createWalletOwners(uint256 ownersLength, uint256 threshold) public {
        ownersLength = ownersLength % 255;
        threshold = threshold % 255;

        vm.assume(ownersLength > 0);
        vm.assume(threshold > 0 && threshold <= ownersLength);
        address[] memory owners = new address[](ownersLength);
        for (uint256 i = 0; i < ownersLength; i++) {
            owners[i] = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
        }

        ISafe safe = ISafe(
            rumpelWalletFactory.createWallet(owners, uint256(threshold), address(0), address(0), 0, payable(address(0)))
        );

        assertEq(safe.getOwners(), owners);
    }

    function test_rumpelModuleCanExecute() public {
        address[] memory owners = new address[](1);
        owners[0] = address(makeAddr("random 111")); // random owner

        ISafe safe = ISafe(rumpelWalletFactory.createWallet(owners, 1, address(0), address(0), 0, payable(address(0))));

        mockToken.mint(address(this), 1.1e18);
        mockToken.transfer(address(safe), 1.1e18);

        assertEq(mockToken.balanceOf(address(safe)), 1.1e18);
        assertEq(mockToken.balanceOf(address(RUMPEL_VAULT)), 0);

        vm.prank(admin);
        rumpelModule.exec(
            safe, address(mockToken), 0, abi.encodeCall(ERC20.transfer, (RUMPEL_VAULT, 1.1e18)), Enum.Operation.Call
        );

        assertEq(mockToken.balanceOf(address(safe)), 0);
        assertEq(mockToken.balanceOf(address(RUMPEL_VAULT)), 1.1e18);
    }

    function test_rumpelWalletIsGuarded() public {
        address[] memory owners = new address[](1);
        owners[0] = address(alice);

        ISafe safe = ISafe(rumpelWalletFactory.createWallet(owners, 1, address(0), address(0), 0, payable(address(0))));

        SafeTX memory safeTX = SafeTX({
            to: address(counter),
            value: 0,
            data: abi.encodeCall(Counter.increment, ()),
            operation: Enum.Operation.Call
        });

        bytes32 txHash = safe.getTransactionHash(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), 0
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, txHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Will revert if the address.func has not been allowed
        vm.expectRevert(RumpelGuard.CallNotAllowed.selector);
        safe.execTransaction(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), signature
        );

        vm.prank(admin);
        rumpelGuard.setCallAllowed(address(counter), Counter.increment.selector, true);

        // Will succeed if the address.func has been allowed
        safe.execTransaction(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), signature
        );

        assertEq(counter.count(), 1);
    }

    // test owner is blocked for actions not on the whitelist
    // - cant disable module
    // - cant change guard
    // - cant change owners
    // - cant withdraw funds
    // test owner is allowed for actions on the whitelist
    // test whitelist can be updated
    // test migrations
}

contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }
}
