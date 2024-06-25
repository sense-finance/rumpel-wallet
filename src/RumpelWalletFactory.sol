// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {ISafe, Enum} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";
import {RumpelModule} from "./RumpelModule.sol";

// delegate claiming fnc in the vault?
// upgradable?'
// TODO: do we handle safe contract upgrades?

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
        address _initializationScript,
        address _rumpelModule,
        address _rumpelGuard
    ) Ownable(msg.sender) {
        proxyFactory = _proxyFactory;
        safeSingleton = _safeSingleton;
        initializationScript = _initializationScript;

        rumpelModule = _rumpelModule;
        rumpelGuard = _rumpelGuard;
    }

    // Address can be predicted off-chain
    function createWallet(address[] calldata owners, uint256 threshold) public whenNotPaused returns (address) {
        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector(
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript, // Contract with initialization logic
                abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard), // Initializing call to enable module and guard
                address(0), // fallbackHandler TODO: do we want to set the default compatibility fallback handler? will any UIs be harder without this?
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

    function setRumpelGuard(address _rumpelGuard) public onlyOwner {
        emit RumpelGuardUpdated(rumpelGuard, _rumpelGuard);
        rumpelGuard = _rumpelGuard;
    }

    function setRumpelModule(address _rumpelModule) public onlyOwner {
        emit RumpelModuleUpdated(rumpelModule, _rumpelModule);
        rumpelModule = _rumpelModule;
    }

    function setInitializationScript(address _initializationScript) public onlyOwner {
        emit InitializationScriptUpdated(initializationScript, _initializationScript);
        initializationScript = _initializationScript;
    }

    function setSafeSingleton(address _safeSingleton) public onlyOwner {
        emit SafeSingletonUpdated(safeSingleton, _safeSingleton);
        safeSingleton = _safeSingleton;
    }

    function setProxyFactory(ISafeProxyFactory _proxyFactory) public onlyOwner {
        emit ProxyFactoryUpdated(address(proxyFactory), address(_proxyFactory));
        proxyFactory = _proxyFactory;
    }

    function pauseWalletCreation() public onlyOwner {
        _pause();
    }

    function unpauseWalletCreation() public onlyOwner {
        _unpause();
    }
}
