// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ISafe, Enum} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";
import {RumpelModule} from "./RumpelModule.sol";

// delegate claiming fnc in the vault?

contract RumpelWalletFactory is Ownable {
    uint256 public saltNonce;

    address public rumpelGuard;
    address public rumpelModule;

    address public initializationScript;
    address public singleton;
    ISafeProxyFactory public proxyFactory;

    constructor(
        ISafeProxyFactory _proxyFactory,
        address _singleton,
        address _initializationScript,
        address _rumpelModule,
        address _rumpelGuard
    ) Ownable(msg.sender) {
        proxyFactory = _proxyFactory;
        singleton = _singleton;
        initializationScript = _initializationScript;

        rumpelModule = _rumpelModule;
        rumpelGuard = _rumpelGuard;
    }

    function createWallet(
        address[] calldata owners,
        uint256 threshold,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) public returns (address) {
        bytes memory initializer = abi.encodeWithSelector(
            ISafe.setup.selector,
            owners,
            threshold,
            initializationScript, // Target contract we delegatecall to for initialization
            abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard), // Initializing call to enable module and guard
            fallbackHandler,
            paymentToken,
            payment,
            paymentReceiver
        );

        return proxyFactory.createProxyWithNonce(singleton, initializer, saltNonce++); // TODO: do we want to limit each owner to one wallet via nonce?
    }

    // Admin ---

    function setRumpelGuard(address _rumpelGuard) public onlyOwner {
        rumpelGuard = _rumpelGuard;
    }

    function setRumpelModule(address _rumpelModule) public onlyOwner {
        rumpelModule = _rumpelModule;
    }

    function setInitializationScript(address _initializationScript) public onlyOwner {
        initializationScript = _initializationScript;
    }

    function setSingleton(address _singleton) public onlyOwner {
        singleton = _singleton;
    }

    function setProxyFactory(ISafeProxyFactory _proxyFactory) public onlyOwner {
        proxyFactory = _proxyFactory;
    }
}
