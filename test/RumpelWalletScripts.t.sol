// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {RumpelModule} from "../src/RumpelModule.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {ISafe} from "../src/interfaces/external/ISafe.sol";
import {RumpelWalletFactoryScripts} from "../script/RumpelWalletFactory.s.sol";

contract ProxyFactoryStub {
    bytes internal creationCode;

    constructor(bytes memory code) {
        creationCode = code;
    }

    function proxyCreationCode() external view returns (bytes memory) {
        return creationCode;
    }

    function createProxyWithNonce(address, bytes memory, uint256) external pure returns (address) {
        revert("stub");
    }
}

contract RumpelWalletDeploymentScriptTest is Test {
    RumpelWalletFactoryScripts internal scripts;
    address internal admin;

    function setUp() public {
        scripts = new RumpelWalletFactoryScripts();
        admin = makeAddr("admin");
    }

    function test_RunTransfersOwnershipToAdmin() public {
        (RumpelModule module, RumpelGuard guard, RumpelWalletFactory factory) = scripts.run(admin);

        assertEq(module.owner(), admin, "module owner");
        assertEq(guard.owner(), admin, "guard owner");
        assertEq(factory.owner(), admin, "factory owner");
    }

    function test_RunRevertsWhenDeploymentsNotOwnedByScript() public {
        (RumpelModule module, RumpelGuard guard, RumpelWalletFactory factory) = scripts.run(admin);

        address hijacker = makeAddr("hijacker");

        vm.startPrank(admin);
        module.transferOwnership(hijacker);
        guard.transferOwnership(hijacker);
        factory.transferOwnership(hijacker);
        vm.stopPrank();

        assertEq(module.owner(), hijacker, "module hijacked");
        assertEq(guard.owner(), hijacker, "guard hijacked");
        assertEq(factory.owner(), hijacker, "factory hijacked");

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(scripts)));
        scripts.run(admin);
    }
}

contract RumpelWalletDeterminismTest is Test {
    address internal constant MAINNET_SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address internal constant HYPE_SAFE_SINGLETON = 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA;

    struct FactoryConfig {
        address proxyFactory;
        address safeSingleton;
        address module;
        address guard;
        address initializationScript;
        address fallbackHandler;
    }

    address internal admin;
    address internal user;
    RumpelWalletFactory internal factory;
    address internal mainnetProxyFactory;
    address internal hypeProxyFactory;

    function setUp() public {
        admin = makeAddr("admin");
        user = makeAddr("user");
        RumpelWalletFactoryScripts scripts = new RumpelWalletFactoryScripts();
        (,, factory) = scripts.run(admin);

        bytes memory proxyCode = hex"b0b1";
        mainnetProxyFactory = address(new ProxyFactoryStub(proxyCode));
        hypeProxyFactory = address(new ProxyFactoryStub(proxyCode));
    }

    function _owners() internal view returns (address[] memory owners) {
        owners = new address[](1);
        owners[0] = user;
    }

    function _initializer(InitializationScript.InitCall[] memory initCalls) internal view returns (bytes memory) {
        address[] memory owners = _owners();
        return abi.encodeWithSelector(
            ISafe.setup.selector,
            owners,
            1,
            factory.initializationScript(),
            abi.encodeWithSelector(
                InitializationScript.initialize.selector, factory.rumpelModule(), factory.rumpelGuard(), initCalls
            ),
            factory.compatibilityFallback(),
            address(0),
            0,
            address(0)
        );
    }

    function _precompute() internal view returns (address) {
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        bytes memory initializer = _initializer(initCalls);
        return factory.precomputeAddress(initializer, user, 0);
    }

    function _setSafeInfra(address proxyFactory, address safeSingleton) internal {
        vm.startPrank(admin);
        factory.setParam("PROXY_FACTORY", proxyFactory);
        factory.setParam("SAFE_SINGLETON", safeSingleton);
        vm.stopPrank();
    }

    function test_PrecomputeDiffersWhenSafeInfraDiffers() public {
        _setSafeInfra(mainnetProxyFactory, MAINNET_SAFE_SINGLETON);
        address mainnetWallet = _precompute();

        _setSafeInfra(hypeProxyFactory, HYPE_SAFE_SINGLETON);
        address hypeWallet = _precompute();
        assertTrue(mainnetWallet != hypeWallet, "addresses should differ when infra differs");

        _setSafeInfra(mainnetProxyFactory, MAINNET_SAFE_SINGLETON);
        address resetWallet = _precompute();
        assertEq(mainnetWallet, resetWallet, "resetting infra should restore address");
    }

    function test_PrecomputeMatchesWhenSafeInfraMatches() public {
        _setSafeInfra(mainnetProxyFactory, MAINNET_SAFE_SINGLETON);
        address mainnetWallet = _precompute();

        // Arbitrum reuses the same Safe infra addresses as mainnet.
        _setSafeInfra(mainnetProxyFactory, MAINNET_SAFE_SINGLETON);
        address arbitrumWallet = _precompute();

        assertEq(mainnetWallet, arbitrumWallet, "identical infra should give identical address");
    }
}

contract RumpelWalletDeterminismForkTest is Test {
    address internal constant MAINNET_SAFE_PROXY_FACTORY = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
    address internal constant MAINNET_SAFE_SINGLETON = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

    address internal constant HYPE_SAFE_PROXY_FACTORY = 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC;
    address internal constant HYPE_SAFE_SINGLETON = 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA;

    struct FactoryConfig {
        address proxyFactory;
        address safeSingleton;
        address module;
        address guard;
        address initializationScript;
        address fallbackHandler;
    }

    address internal admin;
    address internal user;

    function setUp() public {
        admin = makeAddr("fork-admin");
        user = makeAddr("fork-user");
    }

    function test_MainnetVsHypeSafeInfra() public {
        string memory rpcMainnet = vm.envString("RPC_MAINNET");
        string memory rpcHype = vm.envString("RPC_HYPEREVM");

        uint256 forkMainnet = vm.createFork(rpcMainnet);
        uint256 forkHype = vm.createFork(rpcHype);

        RumpelWalletFactory factoryMainnet = _deployFactoryOnFork(forkMainnet);
        RumpelWalletFactory factoryHype = _deployFactoryOnFork(forkHype);

        FactoryConfig memory mainConfig = _captureFactoryConfig(forkMainnet, factoryMainnet);
        mainConfig.proxyFactory = MAINNET_SAFE_PROXY_FACTORY;
        mainConfig.safeSingleton = MAINNET_SAFE_SINGLETON;

        address mainnetWallet = _precomputeForFork(forkMainnet, factoryMainnet, mainConfig);

        FactoryConfig memory hypeDiffConfig;
        hypeDiffConfig.proxyFactory = HYPE_SAFE_PROXY_FACTORY;
        hypeDiffConfig.safeSingleton = HYPE_SAFE_SINGLETON;

        address hypeWalletDifferent = _precomputeForFork(forkHype, factoryHype, hypeDiffConfig);
        assertTrue(mainnetWallet != hypeWalletDifferent, "hype infra should change address");

        FactoryConfig memory hypeAlignedConfig = mainConfig;
        hypeAlignedConfig.proxyFactory = MAINNET_SAFE_PROXY_FACTORY;
        hypeAlignedConfig.safeSingleton = MAINNET_SAFE_SINGLETON;

        address hypeWalletMatching = _precomputeForFork(forkHype, factoryHype, hypeAlignedConfig);
        assertEq(mainnetWallet, hypeWalletMatching, "aligning infra should align addresses");
    }

    function test_MainnetMatchesArbitrumSafeInfra() public {
        string memory rpcMainnet = vm.envString("RPC_MAINNET");
        string memory rpcArbitrum = vm.envString("RPC_ARBITRUM");

        uint256 forkMainnet = vm.createFork(rpcMainnet);
        uint256 forkArbitrum = vm.createFork(rpcArbitrum);

        RumpelWalletFactory factoryMainnet = _deployFactoryOnFork(forkMainnet);
        RumpelWalletFactory factoryArbitrum = _deployFactoryOnFork(forkArbitrum);

        FactoryConfig memory mainConfig = _captureFactoryConfig(forkMainnet, factoryMainnet);
        mainConfig.proxyFactory = MAINNET_SAFE_PROXY_FACTORY;
        mainConfig.safeSingleton = MAINNET_SAFE_SINGLETON;

        address mainnetWallet = _precomputeForFork(forkMainnet, factoryMainnet, mainConfig);

        FactoryConfig memory arbitrumConfig = mainConfig;
        address arbitrumWallet = _precomputeForFork(forkArbitrum, factoryArbitrum, arbitrumConfig);

        assertEq(mainnetWallet, arbitrumWallet, "arbitrum should share mainnet address");
    }

    function _deployFactoryOnFork(uint256 forkId) internal returns (RumpelWalletFactory factory) {
        vm.selectFork(forkId);
        RumpelWalletFactoryScripts scripts = new RumpelWalletFactoryScripts();
        (,, factory) = scripts.run(admin);
    }

    function _captureFactoryConfig(uint256 forkId, RumpelWalletFactory factory)
        internal
        returns (FactoryConfig memory cfg)
    {
        vm.selectFork(forkId);
        cfg.module = address(factory.rumpelModule());
        cfg.guard = address(factory.rumpelGuard());
        cfg.initializationScript = factory.initializationScript();
        cfg.fallbackHandler = factory.compatibilityFallback();
    }

    function _precomputeForFork(uint256 forkId, RumpelWalletFactory factory, FactoryConfig memory config)
        internal
        returns (address)
    {
        vm.selectFork(forkId);

        vm.startPrank(admin);
        if (config.proxyFactory != address(0)) factory.setParam("PROXY_FACTORY", config.proxyFactory);
        if (config.safeSingleton != address(0)) factory.setParam("SAFE_SINGLETON", config.safeSingleton);
        if (config.module != address(0)) factory.setParam("RUMPEL_MODULE", config.module);
        if (config.guard != address(0)) factory.setParam("RUMPEL_GUARD", config.guard);
        if (config.initializationScript != address(0)) {
            factory.setParam("INITIALIZATION_SCRIPT", config.initializationScript);
        }
        if (config.fallbackHandler != address(0)) factory.setParam("COMPATIBILITY_FALLBACK", config.fallbackHandler);
        vm.stopPrank();

        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address[] memory owners = new address[](1);
        owners[0] = user;

        bytes memory initializer = abi.encodeWithSelector(
            ISafe.setup.selector,
            owners,
            1,
            factory.initializationScript(),
            abi.encodeWithSelector(
                InitializationScript.initialize.selector, factory.rumpelModule(), factory.rumpelGuard(), initCalls
            ),
            factory.compatibilityFallback(),
            address(0),
            0,
            address(0)
        );

        return factory.precomputeAddress(initializer, user, 0);
    }
}
