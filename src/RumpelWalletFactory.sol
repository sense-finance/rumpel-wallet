// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

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
    error InvalidSaltNonce(uint256 expected, uint256 provided);

    constructor(
        ISafeProxyFactory _proxyFactory,
        address _compatibilityFallback,
        address _safeSingleton,
        address _rumpelModule,
        address _rumpelGuard,
        address _initializationScript,
        address owner_
    ) Ownable(owner_) {
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
        InitializationScript.InitCall[] calldata initCalls
    ) external whenNotPaused returns (address) {
        uint256 currentSaltNonce = saltNonce[msg.sender];
        address safe = _createWallet(msg.sender, currentSaltNonce, owners, threshold, initCalls);
        unchecked {
            saltNonce[msg.sender] = currentSaltNonce + 1;
        }
        return safe;
    }

    function createWalletFor(
        address saltOwner,
        uint256 targetSaltNonce,
        address[] calldata owners,
        uint256 threshold,
        InitializationScript.InitCall[] calldata initCalls
    ) external onlyOwner whenNotPaused returns (address) {
        uint256 expectedSaltNonce = saltNonce[saltOwner];
        if (targetSaltNonce != expectedSaltNonce) revert InvalidSaltNonce(expectedSaltNonce, targetSaltNonce);

        address safe = _createWallet(saltOwner, targetSaltNonce, owners, threshold, initCalls);

        unchecked {
            saltNonce[saltOwner] = expectedSaltNonce + 1;
        }

        return safe;
    }

    function precomputeAddress(bytes memory _initializer, address _saltOwner, uint256 _saltNonce)
        external
        view
        returns (address)
    {
        bytes32 salt = keccak256(
            abi.encodePacked(keccak256(_initializer), uint256(keccak256(abi.encodePacked(_saltOwner, _saltNonce))))
        );

        bytes memory deploymentData =
            abi.encodePacked(proxyFactory.proxyCreationCode(), uint256(uint160(safeSingleton)));

        bytes32 deploymentHash =
            keccak256(abi.encodePacked(bytes1(0xff), address(proxyFactory), salt, keccak256(deploymentData)));

        return address(uint160(uint256(deploymentHash)));
    }

    function _createWallet(
        address saltOwner,
        uint256 saltOwnerNonce,
        address[] calldata owners,
        uint256 threshold,
        InitializationScript.InitCall[] calldata initCalls
    ) internal returns (address) {
        uint256 salt = uint256(keccak256(abi.encodePacked(saltOwner, saltOwnerNonce)));

        address safe = proxyFactory.createProxyWithNonce(
            safeSingleton,
            abi.encodeWithSelector(
                ISafe.setup.selector,
                owners,
                threshold,
                initializationScript,
                abi.encodeWithSelector(InitializationScript.initialize.selector, rumpelModule, rumpelGuard, initCalls),
                compatibilityFallback,
                address(0),
                0,
                address(0)
            ),
            salt
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
        else if (what == "COMPATIBILITY_FALLBACK") compatibilityFallback = data;
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
