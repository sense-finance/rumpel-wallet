// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Registry for per-user timelocks on Rumpel Wallets.
/// @dev Allows users to voluntarily lock specific function calls for a duration.
/// @dev Two-tier system: auto-approved restrictions can be locked immediately, others require admin approval.
contract RumpelTimelockRegistry is Ownable {
    /// @dev safe => restrictionHash => unlocksAt timestamp
    mapping(address => mapping(bytes32 => uint256)) public timelocks;

    /// @dev restrictionHash => isAutoApproved (can be locked without admin approval)
    mapping(bytes32 => bool) public autoApprovedRestrictions;

    /// @dev proposalId => PendingTimelock
    mapping(bytes32 => PendingTimelock) public pendingProposals;

    struct TimelockConfig {
        address target;
        bytes4 selector;
        uint256 duration;
    }

    struct PendingTimelock {
        address safe;
        address target;
        bytes4 selector;
        uint256 duration;
        uint256 proposedAt;
    }

    event TimelockSet(address indexed safe, address indexed target, bytes4 indexed selector, uint256 unlocksAt);
    event TimelockCleared(address indexed safe, address indexed target, bytes4 indexed selector);
    event TimelockProposed(bytes32 indexed proposalId, address indexed safe, address indexed target, bytes4 selector, uint256 duration);
    event ProposalApproved(bytes32 indexed proposalId, address indexed safe);
    event ProposalRejected(bytes32 indexed proposalId, address indexed safe);
    event AutoApprovalSet(address indexed target, bytes4 indexed selector, bool approved);

    error CannotReduceTimelock(address target, bytes4 selector, uint256 existingUnlock, uint256 newUnlock);
    error TimelockStillActive(address target, bytes4 selector, uint256 unlocksAt);
    error RequiresApproval(address target, bytes4 selector);
    error ProposalNotFound(bytes32 proposalId);
    error ProposalExpired(bytes32 proposalId);

    uint256 public constant PROPOSAL_EXPIRY = 7 days;

    constructor() Ownable(msg.sender) {}

    /// @notice Set a timelock for a specific target and function selector.
    /// @dev Can only extend timelocks, not reduce them. Called by Safe via execTransaction.
    /// @dev If the restriction is not auto-approved, this will revert with RequiresApproval.
    /// @param target The contract address to lock
    /// @param selector The function selector to lock
    /// @param duration The duration in seconds to lock for
    function setTimelock(address target, bytes4 selector, uint256 duration) external {
        bytes32 restrictionHash = _getRestrictionHash(target, selector);

        // Check if this restriction requires approval
        if (!autoApprovedRestrictions[restrictionHash]) {
            revert RequiresApproval(target, selector);
        }

        _setTimelockInternal(msg.sender, target, selector, duration);
    }

    /// @notice Set multiple timelocks in a single transaction.
    /// @dev All configs must be auto-approved, otherwise reverts with RequiresApproval.
    /// @param configs Array of timelock configurations
    function setTimelocks(TimelockConfig[] calldata configs) external {
        for (uint256 i = 0; i < configs.length;) {
            bytes32 restrictionHash = _getRestrictionHash(configs[i].target, configs[i].selector);

            // Check if this restriction requires approval
            if (!autoApprovedRestrictions[restrictionHash]) {
                revert RequiresApproval(configs[i].target, configs[i].selector);
            }

            _setTimelockInternal(msg.sender, configs[i].target, configs[i].selector, configs[i].duration);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Propose a timelock that requires admin approval.
    /// @dev Creates a pending proposal that admin must approve before lock activates.
    /// @param target The contract address to lock
    /// @param selector The function selector to lock
    /// @param duration The duration in seconds to lock for
    /// @return proposalId The ID of the created proposal
    function proposeTimelock(address target, bytes4 selector, uint256 duration) external returns (bytes32 proposalId) {
        proposalId = keccak256(abi.encodePacked(msg.sender, target, selector, duration, block.timestamp));

        pendingProposals[proposalId] = PendingTimelock({
            safe: msg.sender,
            target: target,
            selector: selector,
            duration: duration,
            proposedAt: block.timestamp
        });

        emit TimelockProposed(proposalId, msg.sender, target, selector, duration);
    }

    /// @notice Propose multiple timelocks that require admin approval.
    /// @param configs Array of timelock configurations
    /// @return proposalIds Array of created proposal IDs
    function proposeTimelocks(TimelockConfig[] calldata configs) external returns (bytes32[] memory proposalIds) {
        proposalIds = new bytes32[](configs.length);

        for (uint256 i = 0; i < configs.length;) {
            bytes32 proposalId = keccak256(
                abi.encodePacked(msg.sender, configs[i].target, configs[i].selector, configs[i].duration, block.timestamp, i)
            );

            pendingProposals[proposalId] = PendingTimelock({
                safe: msg.sender,
                target: configs[i].target,
                selector: configs[i].selector,
                duration: configs[i].duration,
                proposedAt: block.timestamp
            });

            emit TimelockProposed(proposalId, msg.sender, configs[i].target, configs[i].selector, configs[i].duration);
            proposalIds[i] = proposalId;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Admin approves a pending timelock proposal.
    /// @param proposalId The ID of the proposal to approve
    function approveProposal(bytes32 proposalId) external onlyOwner {
        PendingTimelock memory proposal = pendingProposals[proposalId];

        if (proposal.proposedAt == 0) {
            revert ProposalNotFound(proposalId);
        }

        if (block.timestamp > proposal.proposedAt + PROPOSAL_EXPIRY) {
            revert ProposalExpired(proposalId);
        }

        _setTimelockInternal(proposal.safe, proposal.target, proposal.selector, proposal.duration);

        delete pendingProposals[proposalId];
        emit ProposalApproved(proposalId, proposal.safe);
    }

    /// @notice Admin rejects a pending timelock proposal.
    /// @param proposalId The ID of the proposal to reject
    function rejectProposal(bytes32 proposalId) external onlyOwner {
        PendingTimelock memory proposal = pendingProposals[proposalId];

        if (proposal.proposedAt == 0) {
            revert ProposalNotFound(proposalId);
        }

        delete pendingProposals[proposalId];
        emit ProposalRejected(proposalId, proposal.safe);
    }

    /// @notice Admin batch approves multiple proposals.
    /// @param proposalIds Array of proposal IDs to approve
    function batchApproveProposals(bytes32[] calldata proposalIds) external onlyOwner {
        for (uint256 i = 0; i < proposalIds.length;) {
            PendingTimelock memory proposal = pendingProposals[proposalIds[i]];

            if (proposal.proposedAt == 0) {
                revert ProposalNotFound(proposalIds[i]);
            }

            if (block.timestamp > proposal.proposedAt + PROPOSAL_EXPIRY) {
                revert ProposalExpired(proposalIds[i]);
            }

            _setTimelockInternal(proposal.safe, proposal.target, proposal.selector, proposal.duration);

            delete pendingProposals[proposalIds[i]];
            emit ProposalApproved(proposalIds[i], proposal.safe);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Set a wildcard timelock for all functions on a target contract.
    /// @dev Uses bytes4(0) as the selector to indicate a wildcard
    /// @dev If the wildcard restriction is not auto-approved, this will revert with RequiresApproval.
    /// @param target The contract address to lock
    /// @param duration The duration in seconds to lock for
    function setTargetTimelock(address target, uint256 duration) external {
        bytes32 restrictionHash = _getRestrictionHash(target, bytes4(0));

        // Check if this wildcard restriction requires approval
        if (!autoApprovedRestrictions[restrictionHash]) {
            revert RequiresApproval(target, bytes4(0));
        }

        _setTimelockInternal(msg.sender, target, bytes4(0), duration);
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

    // Admin - Auto-Approval Management ----

    /// @notice Admin sets whether a restriction can be auto-approved.
    /// @dev Auto-approved restrictions can be locked immediately without admin approval.
    /// @param target The contract address
    /// @param selector The function selector
    /// @param approved Whether this restriction is auto-approved
    function setAutoApproved(address target, bytes4 selector, bool approved) external onlyOwner {
        bytes32 restrictionHash = _getRestrictionHash(target, selector);
        autoApprovedRestrictions[restrictionHash] = approved;
        emit AutoApprovalSet(target, selector, approved);
    }

    /// @notice Admin batch sets auto-approval for multiple restrictions.
    /// @param targets Array of contract addresses
    /// @param selectors Array of function selectors
    /// @param approved Whether these restrictions are auto-approved
    function batchSetAutoApproved(address[] calldata targets, bytes4[] calldata selectors, bool approved)
        external
        onlyOwner
    {
        require(targets.length == selectors.length, "Length mismatch");

        for (uint256 i = 0; i < targets.length;) {
            bytes32 restrictionHash = _getRestrictionHash(targets[i], selectors[i]);
            autoApprovedRestrictions[restrictionHash] = approved;
            emit AutoApprovalSet(targets[i], selectors[i], approved);

            unchecked {
                ++i;
            }
        }
    }

    /// @notice Check if a restriction is auto-approved.
    /// @param target The contract address
    /// @param selector The function selector
    /// @return Whether this restriction is auto-approved
    function isAutoApproved(address target, bytes4 selector) external view returns (bool) {
        bytes32 restrictionHash = _getRestrictionHash(target, selector);
        return autoApprovedRestrictions[restrictionHash];
    }

    // Internal Functions ----

    /// @dev Internal function to set a timelock, enforcing extend-only rule.
    function _setTimelockInternal(address safe, address target, bytes4 selector, uint256 duration) internal {
        bytes32 hash = _getRestrictionHash(target, selector);
        uint256 existingUnlock = timelocks[safe][hash];
        uint256 newUnlock = block.timestamp + duration;

        // Can only extend, not reduce
        if (existingUnlock > 0 && newUnlock < existingUnlock) {
            revert CannotReduceTimelock(target, selector, existingUnlock, newUnlock);
        }

        timelocks[safe][hash] = newUnlock;
        emit TimelockSet(safe, target, selector, newUnlock);
    }

    /// @dev Internal function to generate a unique hash for each restriction
    function _getRestrictionHash(address target, bytes4 selector) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(target, selector));
    }
}
