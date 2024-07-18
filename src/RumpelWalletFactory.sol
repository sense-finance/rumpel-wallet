// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";
import {ISafeProxyFactory} from "./interfaces/external/ISafeProxyFactory.sol";
import {InitializationScript} from "./InitializationScript.sol";

/// @notice Factory to create Rumpel Wallets; Safes with the Rumpel Guard and Rumpel Module added on.
contract RumpelWalletFactory is Ownable, Pausable {
    mapping(address => uint256) public saltNonce;

    ISafeProxyFactory public proxyFactory;
    address public compatibilityFallback;
    address public safeSingleton;
    address public rumpelModule;
    address public rumpelGuard;
    address public initializationScript;

    event SafeCreated(address indexed safe, address[] indexed owners, uint256 threshold);
    event ParamChanged(bytes32 what, address data);

    error UnrecognizedParam(bytes32 what);

    constructor(
        ISafeProxyFactory _proxyFactory,
        address _compatibilityFallback,
        address _safeSingleton,
        address _rumpelModule,
        address _rumpelGuard,
        address _initializationScript
    ) Ownable(msg.sender) {
        proxyFactory = _proxyFactory;
        compatibilityFallback = _compatibilityFallback;
        safeSingleton = _safeSingleton;
        rumpelModule = _rumpelModule;
        rumpelGuard = _rumpelGuard;
        initializationScript = _initializationScript;
    }

    /// @notice Create a Safe with the Rumpel Module and Rumpel Guard added.
    function createWallet(
        address[] calldata owners,
        uint256 threshold,
        InitializationScript.CallHook[] calldata callHooks
    ) external whenNotPaused returns (address) {
        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector(
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript, // Contract with initialization logic
                abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard, callHooks), // Add module and guard + initial calls
                compatibilityFallback, // fallbackHandler
                address(0), // paymentToken
                0, // payment
                address(0) // paymentReceiver
            ),
            saltNonce[msg.sender]++ // For deterministic address generation
        );

        emit SafeCreated(safe, owners, threshold);

        return safe;
    }

    // Admin ----

    /// @notice Set admin params, only callable by the owner.
    /// @dev These changes will only apply to future Safes deployed with this factory.
    function setParam(bytes32 what, address data) external onlyOwner {
        if (what == "PROXY_FACTORY") proxyFactory = ISafeProxyFactory(data);
        else if (what == "SAFE_SINGLETON") safeSingleton = data;
        else if (what == "RUMPEL_MODULE") rumpelModule = data;
        else if (what == "RUMPEL_GUARD") rumpelGuard = data;
        else if (what == "INITIALIZATION_SCRIPT") initializationScript = data;
        else revert UnrecognizedParam(what);
        emit ParamChanged(what, data);
    }

    function pauseWalletCreation() external onlyOwner {
        _pause();
    }

    function unpauseWalletCreation() external onlyOwner {
        _unpause();
    }
}
