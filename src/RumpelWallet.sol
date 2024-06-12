// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// singleton vs proxies?

library Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

contract RumpelGuard {
    constructor() {}

    function setUp() public {}

    mapping(address => mapping(bytes4 => bool)) public allowedTargets;

    function setCallAllowed(address target, bytes4 functionSig, bool allow) public {
        allowedTargets[target][functionSig] = allow;
    }

    function isAllowedCall(address target, bytes4 functionSig) public view returns (bool) {
        return (allowedTargets[target][functionSig]);
    }

    fallback() external {
        // Don't revert on fallback to avoid issues in case of a Safe upgrade
    }

    function checkTransaction(
        address to,
        uint256,
        bytes memory data,
        Enum.Operation,
        uint256,
        uint256,
        uint256,
        address,
        address payable,
        bytes memory,
        address
    ) external view {
        require(allowedTargets[to][bytes4(data)], "Call is not allowed");
    }

    function checkAfterExecution(bytes32, bool) external view {}
}

contract SafeModule {
    uint256 public number;

    function exec(IGnosisSafe safe, address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        virtual
        returns (bool success)
    {
        // require(auth)
        safe.execTransactionFromModule(to, value, data, operation);
    }
}

interface IGnosisSafeProxyFactory {
    function createProxyWithNonce(address _singleton, bytes memory _initializer, uint256 _saltNonce)
        external
        returns (address);
}

interface IGnosisSafe {
    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;
}

contract RumpelWalletFactory {
    IGnosisSafeProxyFactory public immutable proxyFactory;
    address public immutable singleton;
    uint256 public saltNonce;

    constructor(IGnosisSafeProxyFactory _proxyFactory, address _singleton) {
        proxyFactory = _proxyFactory;
        singleton = _singleton;
    }

    function createWallet(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver,
        address[] calldata modules
    ) public returns (address) {
        address[] memory _tempOwners = new address[](1);
        _tempOwners[0] = address(this);

        uint256 _tempThreshold = 1;

        bytes memory initializer = encodeSetupCallData(
            _tempOwners, _tempThreshold, to, data, fallbackHandler, paymentToken, payment, paymentReceiver, modules
        );

        address safe = proxyFactory.createProxyWithNonce(singleton, initializer, saltNonce++);

        // set guard
        // set owner and threshold

        return safe;
    }

    function encodeSetupCallData(
        address[] memory _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver,
        address[] calldata modules
    ) public pure returns (bytes memory) {
        bytes memory modulesData;
        for (uint256 i = 0; i < modules.length; i++) {
            modulesData = abi.encodePacked(modulesData, abi.encodeWithSignature("enableModule(address)", modules[i]));
        }

        return abi.encodeWithSelector(
            IGnosisSafe.setup.selector,
            _owners,
            _threshold,
            to,
            abi.encodePacked(data, modulesData),
            fallbackHandler,
            paymentToken,
            payment,
            paymentReceiver
        );
    }
}
