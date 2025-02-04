// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {console} from "forge-std/console.sol";

struct SelectorState {
    bytes4 selector;
    RumpelGuard.AllowListState state;
}

struct ProtocolGuardConfig {
    address target;
    SelectorState[] selectorStates;
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
    address public constant MAINNET_ETHERFI_LRT2_CLAIM = 0x6Db24Ee656843E3fE03eb8762a54D86186bA6B64;

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
    address public constant MAINNET_KSUSDE = 0xDe5Bff0755F192C333B126A449FF944Ee2B69681;

    address public constant MAINNET_RE7LRT = 0x84631c0d0081FDe56DeB72F6DE77abBbF6A9f93a;
    address public constant MAINNET_RE7RWBTC = 0x7F43fDe12A40dE708d908Fb3b9BFB8540d9Ce444;
    address public constant MAINNET_WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    address public constant MAINNET_YTEBTC_26DEC2024 = 0xeB993B610b68F2631f70CA1cf4Fe651dB81f368e;
    address public constant MAINNET_YT_WEETHK_26DEC2024 = 0x7B64b99A1fd80b6c012E354a14ADb352b5916CE1;
    address public constant MAINNET_YT_AGETH_26DEC2024 = 0x3568f1d2e8058F6D99Daa17051Cb4a2930C83978;
    address public constant MAINNET_YT_WEETHS_26DEC2024 = 0x719B51Dd92B7809A80A2E8c91D89367BF58f1D7A;
    address public constant MAINNET_YT_SUSDE_26DEC2024 = 0xbE05538f48D76504953c5d1068898C6642937427; // sy token added
    address public constant MAINNET_YT_USDE_26DEC2024 = 0x5D8B3cd632c58D5CE75C2141C1C8b3b0C209b3ed;
    address public constant MAINNET_YT_RE7LRT_26DEC2024 = 0x89E7f4E5210A77Ac0f20511389Df71eC98ce9971;
    address public constant MAINNET_YT_RSTETH_26DEC2024 = 0x11CCff2F748a0100dBd457FF7170A54e12064Aba;
    address public constant MAINNET_YT_AMPHRETH_26DEC2024 = 0x5dB8a2391a72F1114BbaE30eFc9CD89f4a29F988;
    address public constant MAINNET_YT_KARAK_SUSDE_30JAN2025 = 0x27f6F2f5e87A383471C79296c64E4e82269877f7; // sy token added
    address public constant MAINNET_YT_CORN_LBTC_26DEC2024 = 0x1caE47aA3e10A77C55Ee32f8623D6B5ACC947344;
    address public constant MAINNET_YT_RSUSDE_27MAR2025 = 0x079F21309eB9cbD2a387972eB2168d57C8542e32; // sy token added
    address public constant MAINNET_YT_SUSDE_27MAR2025 = 0x96512230bF0Fa4E20Cf02C3e8A7d983132cd2b9F;
    address public constant MAINNET_YT_SUSDE_29MAY2025 = 0x1de6Ff19FDA7496DdC12f2161f6ad6427c52aBBe;

    address public constant MAINNET_PENDLE_YT_USDE_27MAR2025 = 0x4A8036EFA1307F1cA82d932C0895faa18dB0c9eE;

    address public constant MAINNET_AMPHRETH = 0x5fD13359Ba15A84B76f7F87568309040176167cd;
    address public constant MAINNET_SYMBIOTIC_LBTC = 0x9C0823D3A1172F9DdF672d438dec79c39a64f448;

    address public constant MAINNET_TBTC = 0x18084fbA666a33d37592fA2633fD49a74DD93a88;
    address public constant MAINNET_UNIBTC = 0x004E9C3EF86bc1ca1f0bB5C7662861Ee93350568;
    address public constant MAINNET_IBTC = 0x20157DBAbb84e3BBFE68C349d0d44E48AE7B5AD2;
    
    address public constant MAINNET_MELLOW_DVSTETH = 0x5E362eb2c0706Bd1d134689eC75176018385430B;
    address public constant MAINNET_MELLOW_RENZO_PZETH = 0x8c9532a60E0E7C6BbD2B2c1303F63aCE1c3E9811;
    address public constant MAINNET_MELLOW_RSENA = 0xc65433845ecD16688eda196497FA9130d6C47Bd8;
    address public constant MAINNET_MELLOW_AMPHRBTC = 0x64047dD3288276d70A4F8B5Df54668c8403f877F;
    address public constant MAINNET_MELLOW_STEAKLRT = 0xBEEF69Ac7870777598A04B2bd4771c71212E6aBc;
    address public constant MAINNET_MELLOW_HYVEX = 0x24183535a24CF0272841B05047A26e200fFAB696;
    address public constant MAINNET_MELLOW_RE7RTBTC = 0x3a828C183b3F382d030136C824844Ea30145b4c7;
    address public constant MAINNET_MELLOW_IFSETH = 0x49cd586dd9BA227Be9654C735A659a1dB08232a9;
    address public constant MAINNET_MELLOW_CP0XLRT = 0xB908c9FE885369643adB5FBA4407d52bD726c72d;
    address public constant MAINNET_MELLOW_URLRT = 0x4f3Cc6359364004b245ad5bE36E6ad4e805dC961;
    address public constant MAINNET_MELLOW_COETH = 0xd6E09a5e6D719d1c881579C9C8670a210437931b;
    address public constant MAINNET_MELLOW_HCETH = 0x375A8eE22280076610cA2B4348d37cB1bEEBeba0;
    address public constant MAINNET_MELLOW_ISETH = 0xcC36e5272c422BEE9A8144cD2493Ac472082eBaD;
    address public constant MAINNET_MELLOW_SIBTC = 0xE4357bDAE017726eE5E83Db3443bcd269BbF125d;
    address public constant MAINNET_MELLOW_LUGAETH = 0x82dc3260f599f4fC4307209A1122B6eAa007163b;
    address public constant MAINNET_MELLOW_ROETH = 0x7b31F008c48EFb65da78eA0f255EE424af855249;
    address public constant MAINNET_MELLOW_RSUNIBTC = 0x08F39b3d75712148dacDB2669C3EAcc7F1152547;


    // YT Yield Claiming
    address public constant MAINNET_SY_SUSDE = 0xD288755556c235afFfb6316702719C32bD8706e8;
    address public constant MAINNET_PENDLE_ROUTERV4 = 0x888888888889758F76e7103c6CbF23ABbF58F946;
    address public constant MAINNET_SY_RSUSDE = 0xBCD9522EEf626dD0363347BDE6cAB105c2C7797e;
    address public constant MAINNET_SY_KARAK_SUSDE_30JAN2025 = 0x1b641894e66aec7Bf5ab86517e8D81763Cc8e19E;
    address public constant MAINNET_SY_SUSDE_27MAR2025 = 0x3Ee118EFC826d30A29645eAf3b2EaaC9E8320185;
    address public constant MAINNET_SY_SUSDE_29MAY2025 = 0xE877B2A8a53763C8B0534a15e87da28f3aC1257e;

    // Additional Reward Assets
    address public constant MAINNET_LRT2 = 0x8F08B70456eb22f6109F57b8fafE862ED28E6040;

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
            for (uint256 j = 0; j < config.selectorStates.length; j++) {
                address target = config.target;
                bytes4 selector = config.selectorStates[j].selector;
                RumpelGuard.AllowListState desiredState = config.selectorStates[j].state;
                RumpelGuard.AllowListState currentState = rumpelGuard.allowedCalls(target, selector);

                if (
                    currentState == RumpelGuard.AllowListState.OFF
                        && desiredState == RumpelGuard.AllowListState.PERMANENTLY_ON
                ) {
                    revert("cannot go from OFF to PERMANENTLY_ON");
                }

                if (currentState == desiredState) {
                    console.log("Selector already set");
                } else {
                    rumpelGuard.setCallAllowed(target, selector, desiredState);
                }
            }
        }
    }

    function setupGuardTokens(RumpelGuard rumpelGuard, string memory tag) internal {
        TokenGuardConfig[] memory tokens = getGuardTokenConfigs(tag);
        for (uint256 i = 0; i < tokens.length; i++) {
            TokenGuardConfig memory config = tokens[i];
            RumpelGuard.AllowListState currentTransferAllowState =
                rumpelGuard.allowedCalls(config.token, ERC20.transfer.selector);
            RumpelGuard.AllowListState currentApproveAllowState =
                rumpelGuard.allowedCalls(config.token, ERC20.approve.selector);

            if (
                currentTransferAllowState == RumpelGuard.AllowListState.OFF
                    && config.transferAllowState == RumpelGuard.AllowListState.PERMANENTLY_ON
            ) {
                revert("cannot go from OFF to PERMANENTLY_ON");
            }
            if (
                currentApproveAllowState == RumpelGuard.AllowListState.OFF
                    && config.approveAllowState == RumpelGuard.AllowListState.PERMANENTLY_ON
            ) {
                revert("cannot go from OFF to PERMANENTLY_ON");
            }

            if (config.transferAllowState != currentTransferAllowState) {
                rumpelGuard.setCallAllowed(config.token, ERC20.transfer.selector, config.transferAllowState);
            }
            if (config.approveAllowState != currentApproveAllowState) {
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
        } else if (tagHash == keccak256(bytes("add-karak-pendle-sy-token"))) {
            return getAddKarakPendleSYProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("lrt2-claiming"))) {
            return getClaimLRT2ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-march-may-2025-susde-yts"))) {
            return getMarchAndMay2025SusdeYTsProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-ksusde-transfer"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("remove-lrt2-claiming"))) {
            return getRemoveLRT2ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("perm-allow-march-may-2025-susde-yts"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("pendle-usde-yts"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("enable-swap-owner"))) {
            return getEnableSwapOwnerProtocolGuard();
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return getMellowVaultsGuardProtocolConfigs();
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
        } else if (tagHash == keccak256(bytes("add-karak-pendle-sy-token"))) {
            return getAddKarakPendleSYTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("lrt2-claiming"))) {
            return getClaimLRT2AssetTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-march-may-2025-susde-yts"))) {
            return getMarchAndMay2025SusdeYTsTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-ksusde-transfer"))) {
            return getAddKsusdeTransferTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("remove-lrt2-claiming"))) {
            return getRemoveLRT2AssetTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("perm-allow-march-may-2025-susde-yts"))) {
            return getPermAllowMarchAndMay2025SusdeYTsTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("pendle-usde-yts"))) {
            return getPendleUSDEYTsTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("enable-swap-owner"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return getMellowVaultsGuardTokenConfigs();
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
        } else if (tagHash == keccak256(bytes("add-karak-pendle-sy-token"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("lrt2-claiming"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-march-may-2025-susde-yts"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-ksusde-transfer"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("remove-lrt2-claiming"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("perm-allow-march-may-2025-susde-yts"))) {
            return getMarchAndMay20252025SusdeYTsTokenModuleConfigs();
        } else if (tagHash == keccak256(bytes("pendle-usde-yts"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("enable-swap-owner"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
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
        } else if (tagHash == keccak256(bytes("add-karak-pendle-sy-token"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("lrt2-claiming"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-march-may-2025-susde-yts"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-ksusde-transfer"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("remove-lrt2-claiming"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("perm-allow-march-may-2025-susde-yts"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("pendle-usde-yts"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("enable-swap-owner"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return new ProtocolModuleConfig[](0);
        }

        revert("Unsupported tag");
    }

    // Initial ----
    function getInitialGuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](10);

        // Morpho Bundler (supply, withdraw, borrow, repay)
        configs[0] = ProtocolGuardConfig({target: MAINNET_MORPHO_BUNDLER, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMorphoBundler.multicall.selector, state: RumpelGuard.AllowListState.ON});

        // Zircuit Restaking Pool
        configs[1] =
            ProtocolGuardConfig({target: MAINNET_ZIRCUIT_RESTAKING_POOL, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IZircuitRestakingPool.depositFor.selector, state: RumpelGuard.AllowListState.ON});
        configs[1].selectorStates[1] =
            SelectorState({selector: IZircuitRestakingPool.withdraw.selector, state: RumpelGuard.AllowListState.ON});

        // Symbiotic WstETH Collateral
        configs[2] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[2].selectorStates[0] =
            SelectorState({selector: ISymbioticWstETHCollateral.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticWstETHCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // Symbiotic SUSDe Collateral
        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] =
            SelectorState({selector: ISymbioticWstETHCollateral.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[1] = SelectorState({
            selector: ISymbioticWstETHCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // Karak Vault Supervisor
        configs[4] =
            ProtocolGuardConfig({target: MAINNET_KARAK_VAULT_SUPERVISOR, selectorStates: new SelectorState[](4)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IKarakVaultSupervisor.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[1] =
            SelectorState({selector: IKarakVaultSupervisor.gimmieShares.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[2] =
            SelectorState({selector: IKarakVaultSupervisor.returnShares.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[3] = SelectorState({
            selector: IKarakVaultSupervisor.depositAndGimmie.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // Karak Delegation Supervisor
        configs[5] =
            ProtocolGuardConfig({target: MAINNET_KARAK_DELEGATION_SUPERVISOR, selectorStates: new SelectorState[](2)});
        configs[5].selectorStates[0] =
            SelectorState({selector: bytes4(0x92dca407), state: RumpelGuard.AllowListState.ON}); // bytes4(0x92dca407) = startWithdraw(tuple[] withdrawalRequests)
        configs[5].selectorStates[1] =
            SelectorState({selector: bytes4(0x86e9a1f7), state: RumpelGuard.AllowListState.ON}); // bytes4(0x86e9a1f7) = finishWithdraw(tuple[] startedWithdrawals)

        // Mellow Ethena LRT Vault sUSDe
        configs[6] = ProtocolGuardConfig({target: MAINNET_RSUSDE, selectorStates: new SelectorState[](2)});
        configs[6].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[6].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // KELP Airdrop Gain Vault
        configs[7] = ProtocolGuardConfig({target: MAINNET_AGETH, selectorStates: new SelectorState[](4)});
        configs[7].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[7].selectorStates[1] =
            SelectorState({selector: IERC4626.mint.selector, state: RumpelGuard.AllowListState.ON});
        configs[7].selectorStates[2] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        configs[7].selectorStates[3] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        // Ethena USDe staking
        configs[8] = ProtocolGuardConfig({target: MAINNET_SUSDE, selectorStates: new SelectorState[](7)});
        configs[8].selectorStates[0] =
            SelectorState({selector: ISUSDE.unstake.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[1] =
            SelectorState({selector: ISUSDE.cooldownAssets.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[2] =
            SelectorState({selector: ISUSDE.cooldownShares.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[3] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[4] =
            SelectorState({selector: IERC4626.mint.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[5] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[6] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        // Ethena USDe locking
        configs[9] = ProtocolGuardConfig({target: MAINNET_ETHENA_LP_STAKING, selectorStates: new SelectorState[](2)});
        configs[9].selectorStates[0] =
            SelectorState({selector: IEthenaLpStaking.stake.selector, state: RumpelGuard.AllowListState.ON});
        configs[9].selectorStates[1] =
            SelectorState({selector: IEthenaLpStaking.unstake.selector, state: RumpelGuard.AllowListState.ON});

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
        configs[0] = ProtocolGuardConfig({target: MAINNET_RE7LRT, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow WBTC Vault re7RWBTC
        configs[1] = ProtocolGuardConfig({target: MAINNET_RE7RWBTC, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[1].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

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

    // Mellow Vaults ----
    function getMellowVaultsGuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](17);

        // Mellow Simple Lido DV
        configs[0] = ProtocolGuardConfig({target: MAINNET_MELLOW_DVSTETH, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow pzETH
        configs[1] = ProtocolGuardConfig({target: MAINNET_MELLOW_RENZO_PZETH, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[1].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow rsENA
        configs[2] = ProtocolGuardConfig({target: MAINNET_MELLOW_RSENA, selectorStates: new SelectorState[](2)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[2].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow amphrBTC
        configs[3] = ProtocolGuardConfig({target: MAINNET_MELLOW_AMPHRBTC, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow steakLRT
        configs[4] = ProtocolGuardConfig({target: MAINNET_MELLOW_STEAKLRT, selectorStates: new SelectorState[](2)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow HYVEX
        configs[5] = ProtocolGuardConfig({target: MAINNET_MELLOW_HYVEX, selectorStates: new SelectorState[](2)});
        configs[5].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[5].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});
        
        // Mellow Re7rtBTC
        configs[6] = ProtocolGuardConfig({target: MAINNET_MELLOW_RE7RTBTC, selectorStates: new SelectorState[](2)});
        configs[6].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[6].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow ifsETH
        configs[7] = ProtocolGuardConfig({target: MAINNET_MELLOW_IFSETH, selectorStates: new SelectorState[](2)});
        configs[7].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[7].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow cp0xLRT
        configs[8] = ProtocolGuardConfig({target: MAINNET_MELLOW_CP0XLRT, selectorStates: new SelectorState[](2)});
        configs[8].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[8].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow urLRT
        configs[9] = ProtocolGuardConfig({target: MAINNET_MELLOW_URLRT, selectorStates: new SelectorState[](2)});
        configs[9].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[9].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow coETH
        configs[10] = ProtocolGuardConfig({target: MAINNET_MELLOW_COETH, selectorStates: new SelectorState[](2)});
        configs[10].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[10].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow hcETH
        configs[11] = ProtocolGuardConfig({target: MAINNET_MELLOW_HCETH, selectorStates: new SelectorState[](2)});
        configs[11].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[11].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow isETH
        configs[12] = ProtocolGuardConfig({target: MAINNET_MELLOW_ISETH, selectorStates: new SelectorState[](2)});
        configs[12].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[12].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow siBTC
        configs[13] = ProtocolGuardConfig({target: MAINNET_MELLOW_SIBTC, selectorStates: new SelectorState[](2)});
        configs[13].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[13].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow LUGAETH
        configs[14] = ProtocolGuardConfig({target: MAINNET_MELLOW_LUGAETH, selectorStates: new SelectorState[](2)});
        configs[14].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[14].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow roETH
        configs[15] = ProtocolGuardConfig({target: MAINNET_MELLOW_ROETH, selectorStates: new SelectorState[](2)});
        configs[15].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[15].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow rsuniBTC
        configs[16] = ProtocolGuardConfig({target: MAINNET_MELLOW_RSUNIBTC, selectorStates: new SelectorState[](2)});
        configs[16].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[16].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getMellowVaultsGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](21);

        configs[0] = TokenGuardConfig({
            token: MAINNET_MELLOW_DVSTETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_MELLOW_RENZO_PZETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_MELLOW_RSENA,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_MELLOW_AMPHRBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_MELLOW_STEAKLRT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_MELLOW_HYVEX,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_MELLOW_RE7RTBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_MELLOW_IFSETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[8] = TokenGuardConfig({
            token: MAINNET_MELLOW_CP0XLRT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[9] = TokenGuardConfig({
            token: MAINNET_MELLOW_URLRT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[10] = TokenGuardConfig({
            token: MAINNET_MELLOW_COETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[11] = TokenGuardConfig({
            token: MAINNET_MELLOW_HCETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[12] = TokenGuardConfig({
            token: MAINNET_MELLOW_ISETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[13] = TokenGuardConfig({
            token: MAINNET_MELLOW_SIBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[14] = TokenGuardConfig({
            token: MAINNET_MELLOW_LUGAETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[15] = TokenGuardConfig({
            token: MAINNET_MELLOW_ROETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[16] = TokenGuardConfig({
            token: MAINNET_MELLOW_RSUNIBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[17] = TokenGuardConfig({
            token: MAINNET_TBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[18] = TokenGuardConfig({
            token: MAINNET_UNIBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[19] = TokenGuardConfig({
            token: MAINNET_IBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

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

        configs[0] = ProtocolGuardConfig({target: MAINNET_MORPHO_BASE, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMorphoBase.setAuthorization.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getFluidLoopWeETHAndWstEthConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_WEETH_WSTETH, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] = SelectorState({
            selector: IFluidVaultFactory.safeTransferFrom.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getFluidNftTransferCongfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultFactory.transferFrom.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_FACTORY, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] = SelectorState({
            selector: IFluidVaultFactory_.safeTransferFrom.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getFluidLoopWeETHsAndWstEthConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_WEETHS_WSTETH, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getFluidSusdeAndYTsProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDC, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDT, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_GHO, selectorStates: new SelectorState[](1)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

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

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] = SelectorState({
            selector: IPendleRouterV4.redeemDueInterestAndRewards.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getAlternativeYTYieldClaimingProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] = SelectorState({
            selector: IPendleRouterV4.redeemDueInterestAndRewardsV2.selector,
            state: RumpelGuard.AllowListState.ON
        });

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

        configs[0] = ProtocolGuardConfig({target: MAINNET_ETHENA_LP_STAKING, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IEthenaLpStaking.withdraw.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getClaimRSUSDeYieldProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_RSUSDE, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

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

    function getAddKarakPendleSYProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_SY_KARAK_SUSDE_30JAN2025, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getAddKarakPendleSYTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_SY_KARAK_SUSDE_30JAN2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getPendleUSDEYTsTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_PENDLE_YT_USDE_27MAR2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getClaimLRT2ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_ETHERFI_LRT2_CLAIM, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: ILRT2Claim.claim.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getClaimLRT2AssetTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_LRT2,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getMarchAndMay2025SusdeYTsProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE_27MAR2025, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE_29MAY2025, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getMarchAndMay2025SusdeYTsTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](4);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_27MAR2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_29MAY2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE_27MAR2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[3] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE_29MAY2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getAddKsusdeTransferTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_KSUSDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getRemoveLRT2ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_ETHERFI_LRT2_CLAIM, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: ILRT2Claim.claim.selector, state: RumpelGuard.AllowListState.OFF});
        return configs;
    }

    function getRemoveLRT2AssetTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_LRT2,
            transferAllowState: RumpelGuard.AllowListState.OFF,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getPermAllowMarchAndMay2025SusdeYTsTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](2);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_27MAR2025,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_29MAY2025,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getMarchAndMay20252025SusdeYTsTokenModuleConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](3);

        configs[0] = TokenModuleConfig({token: MAINNET_YT_SUSDE_27MAR2025, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: MAINNET_YT_SUSDE_29MAY2025, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getEnableSwapOwnerProtocolGuard() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: address(0), selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: Safe.swapOwner.selector, state: RumpelGuard.AllowListState.ON});

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

interface ILRT2Claim {
    function claim(
        address account,
        uint256 cumulativeAmount,
        bytes32 expectedMerkleRoot,
        bytes32[] calldata merkleProof
    ) external;
}

interface Safe {
    function swapOwner(address prevOwner, address oldOwner, address newOwner) external;
}
