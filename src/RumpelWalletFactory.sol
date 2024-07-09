// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {ISafe, Enum} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";
import {RumpelModule} from "./RumpelModule.sol";

// TODO: do we handle safe contract upgrades?
// interface for the factory

contract RumpelWalletFactory is Ownable, Pausable {
    event SafeCreated(address indexed safe, address[] indexed owners, uint256 threshold);
    event RumpelGuardUpdated(address prevGuard, address newGuard);
    event RumpelModuleUpdated(address prevModule, address newModule);
    event InitializationScriptUpdated(address prevScript, address newScript);
    event SafeSingletonUpdated(address prevSafeSingleton, address newSafeSingleton);
    event ProxyFactoryUpdated(address prevProxyFactory, address newProxyFactory);

    uint256 public saltNonce;

    address public rumpelGuard;
    address public rumpelModule;

    address public initializationScript;
    address public safeSingleton;
    ISafeProxyFactory public proxyFactory;

    constructor(
        ISafeProxyFactory _proxyFactory,
        address _safeSingleton,
        address _rumpelModule,
        address _rumpelGuard,
        address _initializationScript
    ) Ownable(msg.sender) {
        proxyFactory = _proxyFactory;
        safeSingleton = _safeSingleton;

        rumpelModule = _rumpelModule;
        rumpelGuard = _rumpelGuard;

        initializationScript = _initializationScript;
    }

    // Address can be predicted off-chain
    function createWallet(address[] calldata owners, uint256 threshold) external whenNotPaused returns (address) {
        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector(
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript, // Contract with initialization logic
                abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard), // Initializing call to enable module and guard
                address(0), // fallbackHandler
                address(0), // paymentToken
                0, // payment
                address(0) // paymentReceiver
            ),
            saltNonce++
        );

        emit SafeCreated(safe, owners, threshold);

        return safe;
    }

    // Admin ----

    function setRumpelGuard(address _rumpelGuard) external onlyOwner {
        emit RumpelGuardUpdated(rumpelGuard, _rumpelGuard);
        rumpelGuard = _rumpelGuard;
    }

    function setRumpelModule(address _rumpelModule) external onlyOwner {
        emit RumpelModuleUpdated(rumpelModule, _rumpelModule);
        rumpelModule = _rumpelModule;
    }

    function setInitializationScript(address _initializationScript) external onlyOwner {
        emit InitializationScriptUpdated(initializationScript, _initializationScript);
        initializationScript = _initializationScript;
    }

    function setSafeSingleton(address _safeSingleton) external onlyOwner {
        emit SafeSingletonUpdated(safeSingleton, _safeSingleton);
        safeSingleton = _safeSingleton;
    }

    function setProxyFactory(ISafeProxyFactory _proxyFactory) external onlyOwner {
        emit ProxyFactoryUpdated(address(proxyFactory), address(_proxyFactory));
        proxyFactory = _proxyFactory;
    }

    function pauseWalletCreation() external onlyOwner {
        _pause();
    }

    function unpauseWalletCreation() external onlyOwner {
        _unpause();
    }
}
