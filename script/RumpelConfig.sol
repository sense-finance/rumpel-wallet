// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

struct ProtocolGuardConfig {
    address target;
    bytes4[] allowedSelectors;
}

struct TokenGuardConfig {
    address token;
    RumpelGuard.AllowListState transferAllowState;
    RumpelGuard.AllowListState approveAllowState;
}

struct TokenModuleConfig {
    address token;
    bool blockTransfer;
    bool blockApprove;
}

library RumpelConfig {
    // Protocols
    address public constant MAINNET_MORPHO_BUNDLER = 0x4095F064B8d3c3548A3bebfd0Bbfd04750E30077;
    address public constant MAINNET_ZIRCUIT_RESTAKING_POOL = 0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6;
    address public constant MAINNET_SYMBIOTIC_WSTETH_COLLATERAL = 0xC329400492c6ff2438472D4651Ad17389fCb843a;
    address public constant MAINNET_SYMBIOTIC_SUSDE_COLLATERAL = 0x19d0D8e6294B7a04a2733FE433444704B791939A;
    address public constant MAINNET_KARAK_VAULT_SUPERVISOR = 0x54e44DbB92dBA848ACe27F44c0CB4268981eF1CC;
    address public constant MAINNET_KARAK_DELEGATION_SUPERVISOR = 0xAfa904152E04aBFf56701223118Be2832A4449E0;
    address public constant MAINNET_ETHENA_LP_STAKING = 0x8707f238936c12c309bfc2B9959C35828AcFc512;

    // Tokens
    address public constant MAINNET_RSUSDE = 0x82f5104b23FF2FA54C2345F821dAc9369e9E0B26;
    address public constant MAINNET_AGETH = 0xe1B4d34E8754600962Cd944B535180Bd758E6c2e;
    address public constant MAINNET_SUSDE = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;
    address public constant MAINNET_USDE = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address public constant MAINNET_WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public constant MAINNET_KUSDE = 0xBE3cA34D0E877A1Fc889BD5231D65477779AFf4e;
    address public constant MAINNET_KWEETH = 0x2DABcea55a12d73191AeCe59F508b191Fb68AdaC;
    address public constant MAINNET_WEETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address public constant MAINNET_MSTETH = 0x49446A0874197839D15395B908328a74ccc96Bc0;

    address public constant MAINNET_RE7LRT = 0x84631c0d0081FDe56DeB72F6DE77abBbF6A9f93a;
    address public constant MAINNET_RE7RWBTC = 0x7F43fDe12A40dE708d908Fb3b9BFB8540d9Ce444;
    address public constant MAINNET_WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    function updateGuardAllowlist(RumpelGuard rumpelGuard, string memory tag) internal {
        setupGuardProtocols(rumpelGuard, tag);
        setupGuardTokens(rumpelGuard, tag);
    }

    function updateModuleBlocklist(RumpelModule rumpelModule, string memory tag) internal {
        setupModuleTokens(rumpelModule, tag);
    }

    function setupGuardProtocols(RumpelGuard rumpelGuard, string memory tag) internal {
        ProtocolGuardConfig[] memory protocols = getGuardProtocolConfigs(tag);
        for (uint256 i = 0; i < protocols.length; i++) {
            ProtocolGuardConfig memory config = protocols[i];
            for (uint256 j = 0; j < config.allowedSelectors.length; j++) {
                rumpelGuard.setCallAllowed(config.target, config.allowedSelectors[j], RumpelGuard.AllowListState.ON);
            }
        }
    }

    function setupGuardTokens(RumpelGuard rumpelGuard, string memory tag) internal {
        TokenGuardConfig[] memory tokens = getGuardTokenConfigs(tag);
        for (uint256 i = 0; i < tokens.length; i++) {
            TokenGuardConfig memory config = tokens[i];
            if (config.transferAllowState != rumpelGuard.allowedCalls(config.token, ERC20.transfer.selector)) {
                rumpelGuard.setCallAllowed(config.token, ERC20.transfer.selector, config.transferAllowState);
            }
            if (config.approveAllowState != rumpelGuard.allowedCalls(config.token, ERC20.approve.selector)) {
                rumpelGuard.setCallAllowed(config.token, ERC20.approve.selector, config.approveAllowState);
            }
        }
    }

    function setupModuleTokens(RumpelModule rumpelModule, string memory tag) internal {
        TokenModuleConfig[] memory tokens = getModuleTokenConfigs(tag);
        for (uint256 i = 0; i < tokens.length; i++) {
            TokenModuleConfig memory config = tokens[i];
            if (config.blockTransfer) {
                rumpelModule.addBlockedModuleCall(config.token, ERC20.transfer.selector);
            }
            if (config.blockApprove) {
                rumpelModule.addBlockedModuleCall(config.token, ERC20.approve.selector);
            }
        }
    }

    function getGuardProtocolConfigs(string memory tag) internal pure returns (ProtocolGuardConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("initial"))) {
            return getInitialGuardProtocolConfigs();
        } else if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7GuardProtocolConfigs();
        }

        revert("Unsupported tag");
    }

    function getGuardTokenConfigs(string memory tag) internal pure returns (TokenGuardConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("initial"))) {
            return getInitialGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7GuardTokenConfigs();
        }

        revert("Unsupported tag");
    }

    function getModuleTokenConfigs(string memory tag) internal pure returns (TokenModuleConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7ModuleTokenConfigs();
        }

        revert("Unsupported tag");
    }

    // Initial ----
    function getInitialGuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](10);

        // Morpho Bundler (supply, withdraw, borrow, repay)
        configs[0] = ProtocolGuardConfig({target: MAINNET_MORPHO_BUNDLER, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IMorphoBundler.multicall.selector;

        // Zircuit Restaking Pool
        configs[1] = ProtocolGuardConfig({target: MAINNET_ZIRCUIT_RESTAKING_POOL, allowedSelectors: new bytes4[](2)});
        configs[1].allowedSelectors[0] = IZircuitRestakingPool.depositFor.selector;
        configs[1].allowedSelectors[1] = IZircuitRestakingPool.withdraw.selector;

        // Symbiotic WstETH Collateral
        configs[2] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL, allowedSelectors: new bytes4[](2)});
        configs[2].allowedSelectors[0] = ISymbioticWstETHCollateral.deposit.selector;
        configs[2].allowedSelectors[1] = ISymbioticWstETHCollateral.withdraw.selector;

        // Symbiotic SUSDe Collateral
        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL, allowedSelectors: new bytes4[](2)});
        configs[3].allowedSelectors[0] = ISymbioticWstETHCollateral.deposit.selector;
        configs[3].allowedSelectors[1] = ISymbioticWstETHCollateral.withdraw.selector;

        // Karak Vault Supervisor
        configs[4] = ProtocolGuardConfig({target: MAINNET_KARAK_VAULT_SUPERVISOR, allowedSelectors: new bytes4[](4)});
        configs[4].allowedSelectors[0] = IKarakVaultSupervisor.deposit.selector;
        configs[4].allowedSelectors[1] = IKarakVaultSupervisor.gimmieShares.selector;
        configs[4].allowedSelectors[2] = IKarakVaultSupervisor.returnShares.selector;
        configs[4].allowedSelectors[3] = IKarakVaultSupervisor.depositAndGimmie.selector;

        // Karak Delegation Supervisor
        configs[5] =
            ProtocolGuardConfig({target: MAINNET_KARAK_DELEGATION_SUPERVISOR, allowedSelectors: new bytes4[](2)});
        configs[5].allowedSelectors[0] = bytes4(0x92dca407); // startWithdraw(tuple[] withdrawalRequests)
        configs[5].allowedSelectors[1] = bytes4(0x86e9a1f7); // finishWithdraw(tuple[] startedWithdrawals)

        // Mellow Ethena LRT Vault sUSDe
        configs[6] = ProtocolGuardConfig({target: MAINNET_RSUSDE, allowedSelectors: new bytes4[](2)});
        configs[6].allowedSelectors[0] = IMellow.deposit.selector;
        configs[6].allowedSelectors[1] = IMellow.registerWithdrawal.selector;

        // KELP Airdrop Gain Vault
        configs[7] = ProtocolGuardConfig({target: MAINNET_AGETH, allowedSelectors: new bytes4[](4)});
        configs[7].allowedSelectors[0] = IERC4626.deposit.selector;
        configs[7].allowedSelectors[1] = IERC4626.mint.selector;
        configs[7].allowedSelectors[2] = IERC4626.withdraw.selector;
        configs[7].allowedSelectors[3] = IERC4626.redeem.selector;

        // Ethena USDe staking
        configs[8] = ProtocolGuardConfig({target: MAINNET_SUSDE, allowedSelectors: new bytes4[](7)});
        configs[8].allowedSelectors[0] = ISUSDE.unstake.selector;
        configs[8].allowedSelectors[1] = ISUSDE.cooldownAssets.selector;
        configs[8].allowedSelectors[2] = ISUSDE.cooldownShares.selector;
        configs[8].allowedSelectors[3] = IERC4626.deposit.selector;
        configs[8].allowedSelectors[4] = IERC4626.mint.selector;
        configs[8].allowedSelectors[5] = IERC4626.withdraw.selector;
        configs[8].allowedSelectors[6] = IERC4626.redeem.selector;

        // Ethena USDe locking
        configs[9] = ProtocolGuardConfig({target: MAINNET_ETHENA_LP_STAKING, allowedSelectors: new bytes4[](2)});
        configs[9].allowedSelectors[0] = IEthenaLpStaking.stake.selector;
        configs[9].allowedSelectors[1] = IEthenaLpStaking.unstake.selector;

        return configs;
    }

    function getInitialGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](11);

        configs[0] = TokenGuardConfig({
            token: MAINNET_SUSDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_USDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_WSTETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_KUSDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_KWEETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_WEETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_MSTETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_RSUSDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[8] = TokenGuardConfig({
            token: MAINNET_AGETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[9] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[10] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    // Mellow Re7 ----
    function getMellowRe7GuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        // Mellow LRT Vault re7LRT
        configs[0] = ProtocolGuardConfig({target: MAINNET_RE7LRT, allowedSelectors: new bytes4[](2)});
        configs[0].allowedSelectors[0] = IMellow.deposit.selector;
        configs[0].allowedSelectors[1] = IMellow.registerWithdrawal.selector;

        // Mellow WBTC Vault re7RWBTC
        configs[1] = ProtocolGuardConfig({target: MAINNET_RE7RWBTC, allowedSelectors: new bytes4[](2)});
        configs[1].allowedSelectors[0] = IMellow.deposit.selector;
        configs[1].allowedSelectors[1] = IMellow.registerWithdrawal.selector;

        return configs;
    }

    function getMellowRe7GuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        configs[0] = TokenGuardConfig({
            token: MAINNET_WBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_RE7LRT,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_RE7RWBTC,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getMellowRe7ModuleTokenConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](2);

        configs[0] = TokenModuleConfig({token: MAINNET_RE7LRT, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: MAINNET_RE7RWBTC, blockTransfer: true, blockApprove: true});

        return configs;
    }
}

interface IMorphoBundler {
    function multicall(bytes[] memory data) external;
}

interface IZircuitRestakingPool {
    function depositFor(address _token, address _for, uint256 _amount) external;
    function withdraw(address _token, uint256 _amount) external;
}

interface ISymbioticWstETHCollateral {
    function deposit(address recipient, uint256 amount) external returns (uint256);
    function withdraw(address recipient, uint256 amount) external;
}

interface IERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256);
    function mint(uint256 shares, address receiver) external returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256);
}

interface ISUSDE {
    function unstake(address receiver) external;
    function cooldownAssets(uint256 assets) external returns (uint256 shares);
    function cooldownShares(uint256 shares) external returns (uint256 assets);
}

interface IEthenaLpStaking {
    function stake(address token, uint104 amount) external;
    function unstake(address token, uint104 amount) external;
}

interface IKarakVaultSupervisor {
    function deposit(address vault, uint256 amount, uint256 minSharesOut) external;
    function gimmieShares(address vault, uint256 shares) external;
    function returnShares(address vault, uint256 shares) external;
    function depositAndGimmie(address vault, uint256 amount, uint256 minSharesOut) external;
}

interface IMellow {
    function deposit(address to, uint256[] memory amounts, uint256 minLpAmount, uint256 deadline)
        external
        returns (uint256[] memory actualAmounts, uint256 lpAmount);
    function registerWithdrawal(
        address to,
        uint256 lpAmount,
        uint256[] memory minAmounts,
        uint256 deadline,
        uint256 requestDeadline,
        bool closePrevious
    ) external;
}
