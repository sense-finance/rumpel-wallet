// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Registry for per-user timelocks on Rumpel Wallets.
/// @dev Allows users to voluntarily lock specific function calls for a duration.
contract RumpelTimelockRegistry is Ownable {
    /// @dev safe => restrictionHash => unlocksAt timestamp
    mapping(address => mapping(bytes32 => uint256)) public timelocks;

    struct TimelockConfig {
        address target;
        bytes4 selector;
        uint256 duration;
    }

    event TimelockSet(address indexed safe, address indexed target, bytes4 indexed selector, uint256 unlocksAt);
    event TimelockCleared(address indexed safe, address indexed target, bytes4 indexed selector);

    error CannotReduceTimelock(address target, bytes4 selector, uint256 existingUnlock, uint256 newUnlock);
    error TimelockStillActive(address target, bytes4 selector, uint256 unlocksAt);

    constructor() Ownable(msg.sender) {}

    /// @notice Set a timelock for a specific target and function selector.
    /// @dev Can only extend timelocks, not reduce them. Called by Safe via execTransaction.
    /// @param target The contract address to lock
    /// @param selector The function selector to lock
    /// @param duration The duration in seconds to lock for
    function setTimelock(address target, bytes4 selector, uint256 duration) external {
        bytes32 hash = _getRestrictionHash(target, selector);
        uint256 existingUnlock = timelocks[msg.sender][hash];
        uint256 newUnlock = block.timestamp + duration;

        // Can only extend, not reduce
        if (existingUnlock > 0 && newUnlock < existingUnlock) {
            revert CannotReduceTimelock(target, selector, existingUnlock, newUnlock);
        }

        timelocks[msg.sender][hash] = newUnlock;
        emit TimelockSet(msg.sender, target, selector, newUnlock);
    }

    /// @notice Set multiple timelocks in a single transaction.
    /// @param configs Array of timelock configurations
    function setTimelocks(TimelockConfig[] calldata configs) external {
        for (uint256 i = 0; i < configs.length;) {
            bytes32 hash = _getRestrictionHash(configs[i].target, configs[i].selector);
            uint256 existingUnlock = timelocks[msg.sender][hash];
            uint256 newUnlock = block.timestamp + configs[i].duration;

            // Can only extend, not reduce
            if (existingUnlock > 0 && newUnlock < existingUnlock) {
                revert CannotReduceTimelock(configs[i].target, configs[i].selector, existingUnlock, newUnlock);
            }

            timelocks[msg.sender][hash] = newUnlock;
            emit TimelockSet(msg.sender, configs[i].target, configs[i].selector, newUnlock);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Set a wildcard timelock for all functions on a target contract.
    /// @dev Uses bytes4(0) as the selector to indicate a wildcard
    /// @param target The contract address to lock
    /// @param duration The duration in seconds to lock for
    function setTargetTimelock(address target, uint256 duration) external {
        bytes32 hash = _getRestrictionHash(target, bytes4(0));
        uint256 existingUnlock = timelocks[msg.sender][hash];
        uint256 newUnlock = block.timestamp + duration;

        // Can only extend, not reduce
        if (existingUnlock > 0 && newUnlock < existingUnlock) {
            revert CannotReduceTimelock(target, bytes4(0), existingUnlock, newUnlock);
        }

        timelocks[msg.sender][hash] = newUnlock;
        emit TimelockSet(msg.sender, target, bytes4(0), newUnlock);
    }

    /// @notice Check if a specific call is currently locked.
    /// @dev Checks both specific selector and wildcard locks
    /// @param safe The Safe wallet address
    /// @param target The contract address being called
    /// @param selector The function selector being called
    /// @return locked True if the call is currently locked
    /// @return unlocksAt The timestamp when the lock expires (0 if not locked)
    function isLocked(address safe, address target, bytes4 selector)
        external
        view
        returns (bool locked, uint256 unlocksAt)
    {
        // Check specific selector first
        bytes32 specificHash = _getRestrictionHash(target, selector);
        unlocksAt = timelocks[safe][specificHash];

        // Check wildcard for entire target if specific not found
        if (unlocksAt == 0) {
            bytes32 wildcardHash = _getRestrictionHash(target, bytes4(0));
            unlocksAt = timelocks[safe][wildcardHash];
        }

        // Return true if locked (timestamp in future)
        if (unlocksAt != 0 && block.timestamp < unlocksAt) {
            return (true, unlocksAt);
        }

        return (false, 0);
    }

    /// @notice Get the unlock timestamp for a specific restriction.
    /// @param safe The Safe wallet address
    /// @param target The contract address
    /// @param selector The function selector
    /// @return unlocksAt The timestamp when the lock expires (0 if not locked)
    function getUnlockTime(address safe, address target, bytes4 selector) external view returns (uint256 unlocksAt) {
        bytes32 hash = _getRestrictionHash(target, selector);
        return timelocks[safe][hash];
    }

    /// @notice Admin function to clear a timelock in emergency situations.
    /// @dev Only callable by owner. Use with extreme caution.
    /// @param safe The Safe wallet address
    /// @param target The contract address
    /// @param selector The function selector
    function adminClearTimelock(address safe, address target, bytes4 selector) external onlyOwner {
        bytes32 hash = _getRestrictionHash(target, selector);
        delete timelocks[safe][hash];
        emit TimelockCleared(safe, target, selector);
    }

    /// @dev Internal function to generate a unique hash for each restriction
    function _getRestrictionHash(address target, bytes4 selector) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(target, selector));
    }
}
