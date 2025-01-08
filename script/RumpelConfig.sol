// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {console} from "forge-std/console.sol";

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

struct ProtocolModuleConfig {
    address target;
    bytes4[] blockedSelectors;
}

library RumpelConfig {
    // Protocols
    address public constant MAINNET_MORPHO_BUNDLER = 0x4095F064B8d3c3548A3bebfd0Bbfd04750E30077;
    address public constant MAINNET_MORPHO_BASE = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;
    address public constant MAINNET_ZIRCUIT_RESTAKING_POOL = 0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6;
    address public constant MAINNET_SYMBIOTIC_WSTETH_COLLATERAL = 0xC329400492c6ff2438472D4651Ad17389fCb843a;
    address public constant MAINNET_SYMBIOTIC_SUSDE_COLLATERAL = 0x19d0D8e6294B7a04a2733FE433444704B791939A;
    address public constant MAINNET_KARAK_VAULT_SUPERVISOR = 0x54e44DbB92dBA848ACe27F44c0CB4268981eF1CC;
    address public constant MAINNET_KARAK_DELEGATION_SUPERVISOR = 0xAfa904152E04aBFf56701223118Be2832A4449E0;
    address public constant MAINNET_ETHENA_LP_STAKING = 0x8707f238936c12c309bfc2B9959C35828AcFc512;
    address public constant MAINNET_FLUID_VAULT_WEETH_WSTETH = 0xeAEf563015634a9d0EE6CF1357A3b205C35e028D;
    address public constant MAINNET_FLUID_VAULT_FACTORY = 0x324c5Dc1fC42c7a4D43d92df1eBA58a54d13Bf2d;
    address public constant MAINNET_FLUID_VAULT_WEETHS_WSTETH = 0x1c6068eC051f0Ac1688cA1FE76810FA9c8644278;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDC = 0x3996464c0fCCa8183e13ea5E5e74375e2c8744Dd;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDT = 0xBc345229C1b52e4c30530C614BB487323BA38Da5;
    address public constant MAINNET_FLUID_VAULT_SUSDE_GHO = 0x2F3780e21cAba1bEdFB24E37C97917def304dFFA;

    // Tokens
    address public constant MAINNET_RSUSDE = 0x82f5104b23FF2FA54C2345F821dAc9369e9E0B26;
    address public constant MAINNET_RSTETH = 0x7a4EffD87C2f3C55CA251080b1343b605f327E3a;
    address public constant MAINNET_AGETH = 0xe1B4d34E8754600962Cd944B535180Bd758E6c2e;
    address public constant MAINNET_SUSDE = 0x9D39A5DE30e57443BfF2A8307A4256c8797A3497;
    address public constant MAINNET_USDE = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address public constant MAINNET_WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address public constant MAINNET_KUSDE = 0xBE3cA34D0E877A1Fc889BD5231D65477779AFf4e;
    address public constant MAINNET_KWEETH = 0x2DABcea55a12d73191AeCe59F508b191Fb68AdaC;
    address public constant MAINNET_WEETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address public constant MAINNET_WEETHS = 0x917ceE801a67f933F2e6b33fC0cD1ED2d5909D88;
    address public constant MAINNET_MSTETH = 0x49446A0874197839D15395B908328a74ccc96Bc0;
    address public constant MAINNET_USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant MAINNET_GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;

    address public constant MAINNET_RE7LRT = 0x84631c0d0081FDe56DeB72F6DE77abBbF6A9f93a;
    address public constant MAINNET_RE7RWBTC = 0x7F43fDe12A40dE708d908Fb3b9BFB8540d9Ce444;
    address public constant MAINNET_WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    address public constant MAINNET_YTEBTC_26DEC2024 = 0xeB993B610b68F2631f70CA1cf4Fe651dB81f368e;
    address public constant MAINNET_YT_WEETHK_26DEC2024 = 0x7B64b99A1fd80b6c012E354a14ADb352b5916CE1;
    address public constant MAINNET_YT_AGETH_26DEC2024 = 0x3568f1d2e8058F6D99Daa17051Cb4a2930C83978;
    address public constant MAINNET_YT_WEETHS_26DEC2024 = 0x719B51Dd92B7809A80A2E8c91D89367BF58f1D7A;
    address public constant MAINNET_YT_SUSDE_26DEC2024 = 0xbE05538f48D76504953c5d1068898C6642937427;
    address public constant MAINNET_YT_USDE_26DEC2024 = 0x5D8B3cd632c58D5CE75C2141C1C8b3b0C209b3ed;
    address public constant MAINNET_YT_RE7LRT_26DEC2024 = 0x89E7f4E5210A77Ac0f20511389Df71eC98ce9971;
    address public constant MAINNET_YT_RSTETH_26DEC2024 = 0x11CCff2F748a0100dBd457FF7170A54e12064Aba;
    address public constant MAINNET_YT_AMPHRETH_26DEC2024 = 0x5dB8a2391a72F1114BbaE30eFc9CD89f4a29F988;
    address public constant MAINNET_YT_KARAK_SUSDE_30JAN2025 = 0x27f6F2f5e87A383471C79296c64E4e82269877f7;
    address public constant MAINNET_YT_CORN_LBTC_26DEC2024 = 0x1caE47aA3e10A77C55Ee32f8623D6B5ACC947344;
    address public constant MAINNET_YT_RSUSDE_27MAR2025 = 0x079F21309eB9cbD2a387972eB2168d57C8542e32;

    address public constant MAINNET_AMPHRETH = 0x5fD13359Ba15A84B76f7F87568309040176167cd;
    address public constant MAINNET_SYMBIOTIC_LBTC = 0x9C0823D3A1172F9DdF672d438dec79c39a64f448;

    // YT Yield Claiming
    address public constant MAINNET_SY_SUSDE = 0xD288755556c235afFfb6316702719C32bD8706e8;
    address public constant MAINNET_PENDLE_ROUTERV4 = 0x888888888889758F76e7103c6CbF23ABbF58F946;
    address public constant MAINNET_SY_RSUSDE = 0xBCD9522EEf626dD0363347BDE6cAB105c2C7797e;

    function updateGuardAllowlist(RumpelGuard rumpelGuard, string memory tag) internal {
        setupGuardProtocols(rumpelGuard, tag);
        setupGuardTokens(rumpelGuard, tag);
    }

    function updateModuleBlocklist(RumpelModule rumpelModule, string memory tag) internal {
        setupModuleTokens(rumpelModule, tag);
        setupModuleProtocols(rumpelModule, tag);
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
                if (rumpelModule.blockedModuleCalls(config.token, ERC20.transfer.selector) != true) {
                    rumpelModule.addBlockedModuleCall(config.token, ERC20.transfer.selector);
                } else {
                    console.log("Transfer already blocked");
                }
            }
            if (config.blockApprove) {
                if (rumpelModule.blockedModuleCalls(config.token, ERC20.approve.selector) != true) {
                    rumpelModule.addBlockedModuleCall(config.token, ERC20.approve.selector);
                } else {
                    console.log("Approve already blocked");
                }
            }
        }
    }

    function setupModuleProtocols(RumpelModule rumpelModule, string memory tag) internal {
        ProtocolModuleConfig[] memory protocols = getModuleProtocolConfigs(tag);
        for (uint256 i = 0; i < protocols.length; i++) {
            ProtocolModuleConfig memory config = protocols[i];
            for (uint256 j = 0; j < config.blockedSelectors.length; j++) {
                if (rumpelModule.blockedModuleCalls(config.target, config.blockedSelectors[j]) != true) {
                    rumpelModule.addBlockedModuleCall(config.target, config.blockedSelectors[j]);
                } else {
                    console.log("Selector already blocked");
                }
            }
        }
    }

    // Allowlist ----
    function getGuardProtocolConfigs(string memory tag) internal pure returns (ProtocolGuardConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("initial"))) {
            return getInitialGuardProtocolConfigs();
        } else if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7GuardProtocolConfigs();
        } else if (tagHash == keccak256(bytes("initial-yts-amphrETH-and-LBTC-09oct24"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("first-pass-blocklist-policy-16oct24"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("morpho-set-auth-28oct24"))) {
            return getMorphoGuardSetAuthProtocolConfigs();
        } else if (tagHash == keccak256(bytes("fluid-loop-weETH-and-wstETH-10nov24"))) {
            return getFluidLoopWeETHAndWstEthConfigs();
        } else if (tagHash == keccak256(bytes("fluid-nft-transfer-11nov24"))) {
            return getFluidNftTransferCongfigs();
        } else if (tagHash == keccak256(bytes("fluid-loop-weETHs-and-wstETH-15nov24"))) {
            return getFluidLoopWeETHsAndWstEthConfigs();
        } else if (tagHash == keccak256(bytes("fluid-susde-and-yts-26nov24"))) {
            return getFluidSusdeAndYTsProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("claim-yt-yield-susde"))) {
            return getClaimYTYieldProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("alternative-yt-yield-claiming"))) {
            return getAlternativeYTYieldClaimingProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("sYsUSDe-token-approve"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("ethena-staking-lp-withdraw"))) {
            return getEthenaStakingLPWithdrawProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("claim-rsusde-yield"))) {
            return getClaimRSUSDeYieldProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("fluid-asset-blocklist"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("stables-guard"))) {
            return new ProtocolGuardConfig[](0);
        }

        revert("Unsupported tag");
    }

    function getGuardTokenConfigs(string memory tag) internal pure returns (TokenGuardConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("initial"))) {
            return getInitialGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7GuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("initial-yts-amphrETH-and-LBTC-09oct24"))) {
            return getInitialYTsAndAmphrETHGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("first-pass-blocklist-policy-16oct24"))) {
            return getFirstPassBlocklistPolicyGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("morpho-set-auth-28oct24"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETH-and-wstETH-10nov24"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-nft-transfer-11nov24"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETHs-and-wstETH-15nov24"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-susde-and-yts-26nov24"))) {
            return getFluidSusdeAndYTsTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("claim-yt-yield-susde"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("alternative-yt-yield-claiming"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("sYsUSDe-token-approve"))) {
            return getSYsUSDeApproveTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("ethena-staking-lp-withdraw"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("claim-rsusde-yield"))) {
            return getClaimRSUSDeYieldTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("fluid-asset-blocklist"))) {
            return getInitialFluidAssetTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("stables-guard"))) {
            return getStablesTokenGuardConfigs();
        }

        revert("Unsupported tag");
    }

    // Blocklist ----
    function getModuleTokenConfigs(string memory tag) internal pure returns (TokenModuleConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("mellow-re7"))) {
            return getMellowRe7ModuleTokenConfigs();
        } else if (tagHash == keccak256(bytes("first-pass-blocklist-policy-16oct24"))) {
            return getFirstPassBlocklistPolicyModuleTokenConfigs();
        } else if (tagHash == keccak256(bytes("morpho-set-auth-28oct24"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETH-and-wstETH-10nov24"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-nft-transfer-11nov24"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETHs-and-wstETH-15nov24"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-susde-and-yts-26nov24"))) {
            return getFluidSusdeAndYTsModuleTokenConfigs();
        } else if (tagHash == keccak256(bytes("claim-yt-yield-susde"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("alternative-yt-yield-claiming"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("sYsUSDe-token-approve"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethena-staking-lp-withdraw"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("claim-rsusde-yield"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-asset-blocklist"))) {
            return getInitialFluidAssetTokenModuleConfigs();
        } else if (tagHash == keccak256(bytes("stables-guard"))) {
            return new TokenModuleConfig[](0);
        }

        revert("Unsupported tag");
    }

    function getModuleProtocolConfigs(string memory tag) internal pure returns (ProtocolModuleConfig[] memory) {
        bytes32 tagHash = keccak256(bytes(tag));

        if (tagHash == keccak256(bytes("first-pass-blocklist-policy-16oct24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("morpho-set-auth-28oct24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETH-and-wstETH-10nov24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-nft-transfer-11nov24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-weETHs-and-wstETH-15nov24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-susde-and-yts-26nov24"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("claim-yt-yield-susde"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("alternative-yt-yield-claiming"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("sYsUSDe-token-approve"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethena-staking-lp-withdraw"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("claim-rsusde-yield"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-asset-blocklist"))) {
            return getInitialFluidAssetProtocolModuleConfigs();
        } else if (tagHash == keccak256(bytes("stables-guard"))) {
            return new ProtocolModuleConfig[](0);
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

    function getInitialYTsAndAmphrETHGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](11);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YTEBTC_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_WEETHK_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_YT_AGETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[3] = TokenGuardConfig({
            token: MAINNET_YT_WEETHS_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[4] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[5] = TokenGuardConfig({
            token: MAINNET_YT_USDE_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[6] = TokenGuardConfig({
            token: MAINNET_YT_RE7LRT_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[7] = TokenGuardConfig({
            token: MAINNET_YT_RSTETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[8] = TokenGuardConfig({
            token: MAINNET_YT_AMPHRETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[9] = TokenGuardConfig({
            token: MAINNET_AMPHRETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[10] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_LBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getFirstPassBlocklistPolicyGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](18);

        configs[0] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_RSUSDE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_RSTETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_AGETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_KUSDE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_KWEETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_YTEBTC_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[8] = TokenGuardConfig({
            token: MAINNET_YT_WEETHK_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[9] = TokenGuardConfig({
            token: MAINNET_YT_AGETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[10] = TokenGuardConfig({
            token: MAINNET_YT_WEETHS_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[11] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[12] = TokenGuardConfig({
            token: MAINNET_YT_USDE_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[13] = TokenGuardConfig({
            token: MAINNET_YT_RE7LRT_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[14] = TokenGuardConfig({
            token: MAINNET_YT_RSTETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[15] = TokenGuardConfig({
            token: MAINNET_YT_AMPHRETH_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[16] = TokenGuardConfig({
            token: MAINNET_AMPHRETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[17] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_LBTC,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getFirstPassBlocklistPolicyModuleTokenConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](18);

        configs[0] =
            TokenModuleConfig({token: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL, blockTransfer: true, blockApprove: true});
        configs[1] =
            TokenModuleConfig({token: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL, blockTransfer: true, blockApprove: true});
        configs[2] = TokenModuleConfig({token: MAINNET_RSUSDE, blockTransfer: true, blockApprove: true});
        configs[3] = TokenModuleConfig({token: MAINNET_RSTETH, blockTransfer: true, blockApprove: true});
        configs[4] = TokenModuleConfig({token: MAINNET_AGETH, blockTransfer: true, blockApprove: true});
        configs[5] = TokenModuleConfig({token: MAINNET_KUSDE, blockTransfer: true, blockApprove: true});
        configs[6] = TokenModuleConfig({token: MAINNET_KWEETH, blockTransfer: true, blockApprove: true});
        configs[7] = TokenModuleConfig({token: MAINNET_YTEBTC_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[8] = TokenModuleConfig({token: MAINNET_YT_WEETHK_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[9] = TokenModuleConfig({token: MAINNET_YT_AGETH_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[10] = TokenModuleConfig({token: MAINNET_YT_WEETHS_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[11] = TokenModuleConfig({token: MAINNET_YT_SUSDE_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[12] = TokenModuleConfig({token: MAINNET_YT_USDE_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[13] = TokenModuleConfig({token: MAINNET_YT_RE7LRT_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[14] = TokenModuleConfig({token: MAINNET_YT_RSTETH_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[15] = TokenModuleConfig({token: MAINNET_YT_AMPHRETH_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[16] = TokenModuleConfig({token: MAINNET_AMPHRETH, blockTransfer: true, blockApprove: true});
        configs[17] = TokenModuleConfig({token: MAINNET_SYMBIOTIC_LBTC, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getMorphoGuardSetAuthProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_MORPHO_BASE, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IMorphoBase.setAuthorization.selector;

        return configs;
    }

    function getFluidLoopWeETHAndWstEthConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_WEETH_WSTETH, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[1] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, allowedSelectors: new bytes4[](1)});
        configs[1].allowedSelectors[0] = IFluidVaultFactory.safeTransferFrom.selector;

        return configs;
    }

    function getFluidNftTransferCongfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IFluidVaultFactory.transferFrom.selector;

        configs[1] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, allowedSelectors: new bytes4[](1)});
        configs[1].allowedSelectors[0] = IFluidVaultFactory_.safeTransferFrom.selector;

        return configs;
    }

    function getFluidLoopWeETHsAndWstEthConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_WEETHS_WSTETH, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IFluidVaultT1.operate.selector;

        return configs;
    }

    function getFluidSusdeAndYTsProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDC, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[1] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDT, allowedSelectors: new bytes4[](1)});
        configs[1].allowedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[2] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_GHO, allowedSelectors: new bytes4[](1)});
        configs[2].allowedSelectors[0] = IFluidVaultT1.operate.selector;

        return configs;
    }

    function getFluidSusdeAndYTsTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_KARAK_SUSDE_30JAN2025,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_CORN_LBTC_26DEC2024,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_YT_RSUSDE_27MAR2025,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getFluidSusdeAndYTsModuleTokenConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](3);

        configs[0] =
            TokenModuleConfig({token: MAINNET_YT_KARAK_SUSDE_30JAN2025, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: MAINNET_YT_CORN_LBTC_26DEC2024, blockTransfer: true, blockApprove: true});
        configs[2] = TokenModuleConfig({token: MAINNET_YT_RSUSDE_27MAR2025, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getClaimYTYieldProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IPendleRouterV4.redeemDueInterestAndRewards.selector;

        configs[1] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE, allowedSelectors: new bytes4[](1)});
        configs[1].allowedSelectors[0] = IStandardizedYield.redeem.selector;

        return configs;
    }

    function getAlternativeYTYieldClaimingProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IPendleRouterV4.redeemDueInterestAndRewardsV2.selector;

        return configs;
    }

    function getSYsUSDeApproveTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        return configs;
    }

    function getEthenaStakingLPWithdrawProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_ETHENA_LP_STAKING, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IEthenaLpStaking.withdraw.selector;

        return configs;
    }

    function getClaimRSUSDeYieldProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_RSUSDE, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IStandardizedYield.redeem.selector;

        return configs;
    }

    function getClaimRSUSDeYieldTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_SY_RSUSDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getInitialFluidAssetTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        configs[0] = TokenGuardConfig({
            token: MAINNET_WEETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_WEETHS,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_WSTETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        return configs;
    }

    function getInitialFluidAssetTokenModuleConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](3);

        configs[0] = TokenModuleConfig({token: MAINNET_WEETH, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: MAINNET_WEETHS, blockTransfer: true, blockApprove: true});
        configs[2] = TokenModuleConfig({token: MAINNET_WSTETH, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getInitialFluidAssetProtocolModuleConfigs() internal pure returns (ProtocolModuleConfig[] memory) {
        ProtocolModuleConfig[] memory configs = new ProtocolModuleConfig[](8);

        configs[0] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_WEETH_WSTETH, blockedSelectors: new bytes4[](1)});
        configs[0].blockedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[1] =
            ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_WEETHS_WSTETH, blockedSelectors: new bytes4[](1)});
        configs[1].blockedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[2] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDC, blockedSelectors: new bytes4[](1)});
        configs[2].blockedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[3] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDT, blockedSelectors: new bytes4[](1)});
        configs[3].blockedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[4] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_SUSDE_GHO, blockedSelectors: new bytes4[](1)});
        configs[4].blockedSelectors[0] = IFluidVaultT1.operate.selector;

        configs[5] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_FACTORY, blockedSelectors: new bytes4[](1)});
        configs[5].blockedSelectors[0] = IFluidVaultFactory.transferFrom.selector;

        configs[6] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_FACTORY, blockedSelectors: new bytes4[](1)});
        configs[6].blockedSelectors[0] = IFluidVaultFactory_.safeTransferFrom.selector;

        configs[7] = ProtocolModuleConfig({target: MAINNET_FLUID_VAULT_FACTORY, blockedSelectors: new bytes4[](1)});
        configs[7].blockedSelectors[0] = IFluidVaultFactory.safeTransferFrom.selector;

        return configs;
    }

    function getStablesTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](2);

        configs[0] = TokenGuardConfig({
            token: MAINNET_USDT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_GHO,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }
}

interface IMorphoBundler {
    function multicall(bytes[] memory data) external;
}

interface IMorphoBase {
    function setAuthorization(address authorized, bool newIsAuthorized) external;
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
    function withdraw(address token, uint104 amount) external;
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

interface IFluidVaultT1 {
    function operate(uint256 nftId_, int256 newCol_, int256 newDebt_, address to_) external;
}

interface IFluidVaultFactory {
    function safeTransferFrom(address from_, address to_, uint256 id_, bytes calldata data_) external;
    function transferFrom(address from_, address to_, uint256 id_) external;
}

interface IFluidVaultFactory_ {
    function safeTransferFrom(address from_, address to_, uint256 id_) external;
}

// @dev actually a function in ActionMiscV3 called through the RouterProxy
contract IPendleRouterV4 {
    struct RedeemYtIncomeToTokenStruct {
        IPYieldToken yt;
        bool doRedeemInterest;
        bool doRedeemRewards;
        address tokenRedeemSy;
        uint256 minTokenRedeemOut;
    }

    struct SwapData {
        SwapType swapType;
        address extRouter;
        bytes extCalldata;
        bool needScale;
    }

    struct SwapDataExtra {
        address tokenIn;
        address tokenOut;
        uint256 minOut;
        SwapData swapData;
    }

    enum SwapType {
        NONE,
        KYBERSWAP,
        ONE_INCH,
        // ETH_WETH not used in Aggregator
        ETH_WETH
    }

    function redeemDueInterestAndRewards(
        address user,
        address[] calldata sys,
        address[] calldata yts,
        address[] calldata markets
    ) external {}

    // redeemDueInterestAndRewardsV2(IStandardizedYield[],RedeemYtIncomeToTokenStruct[],IPMarket[],IPSwapAggregator,SwapDataExtra[])
    function redeemDueInterestAndRewardsV2(
        IStandardizedYield[] calldata SYs,
        RedeemYtIncomeToTokenStruct[] calldata YTs,
        IPMarket[] calldata markets,
        IPSwapAggregator pendleSwap,
        SwapDataExtra[] calldata swaps
    ) external returns (uint256[] memory netOutFromSwaps, uint256[] memory netInterests) {}
}

interface IStandardizedYield {
    function redeem(
        address receiver,
        uint256 amountSharesToRedeem,
        address tokenOut,
        uint256 minTokenOut,
        bool burnFromInternalBalance
    ) external;
}

interface IPYieldToken {}

interface IPMarket {}

interface IPSwapAggregator {}

interface SwapDataExtra {}
