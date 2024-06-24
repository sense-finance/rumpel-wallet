// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {ISafe, Enum} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";
import {RumpelModule} from "./RumpelModule.sol";

// delegate claiming fnc in the vault?
// restrict what we can do with the wallet (top 20 no approve and transfer)
// upgradable?'
// TODO: do we handle safe contract upgrades?

contract RumpelWalletFactory is Ownable, Pausable {
    event SafeCreated(address indexed safe, address[] owners, uint256 threshold);
    event RumpelGuardUpdated(address indexed newGuard);
    event RumpelModuleUpdated(address indexed newModule);
    event InitializationScriptUpdated(address indexed newScript);
    event SafeSingletonUpdated(address indexed newSafeSingleton);
    event ProxyFactoryUpdated(address indexed newProxyFactory);

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

    function createWallet(address[] calldata owners, uint256 threshold) public whenNotPaused returns (address) {
        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector( // initializer
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript, // Target contract we delegatecall to for initialization
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
        rumpelGuard = _rumpelGuard;
        emit RumpelGuardUpdated(_rumpelGuard);
    }

    function setRumpelModule(address _rumpelModule) public onlyOwner {
        rumpelModule = _rumpelModule;
        emit RumpelModuleUpdated(_rumpelModule);
    }

    function setInitializationScript(address _initializationScript) public onlyOwner {
        initializationScript = _initializationScript;
        emit InitializationScriptUpdated(_initializationScript);
    }

    function setSafeSingleton(address _safeSingleton) public onlyOwner {
        safeSingleton = _safeSingleton;
        emit SafeSingletonUpdated(_safeSingleton);
    }

    function setProxyFactory(ISafeProxyFactory _proxyFactory) public onlyOwner {
        proxyFactory = _proxyFactory;
        emit ProxyFactoryUpdated(address(_proxyFactory));
    }

    /**
     * @dev Pauses wallet creation. Can only be called by the owner.
     */
    function pauseWalletCreation() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses wallet creation. Can only be called by the owner.
     */
    function unpauseWalletCreation() public onlyOwner {
        _unpause();
    }
}
