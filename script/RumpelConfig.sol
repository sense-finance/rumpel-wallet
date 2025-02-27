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

    address public constant MAINNET_SYMBIOTIC_METH_COLLATERAL = 0x475D3Eb031d250070B63Fa145F0fCFC5D97c304a;
    address public constant MAINNET_SYMBIOTIC_WBTC_COLLATERAL = 0x971e5b5D4baa5607863f3748FeBf287C7bf82618;
    address public constant MAINNET_SYMBIOTIC_RETH_COLLATERAL = 0x03Bf48b8A1B37FBeAd1EcAbcF15B98B924ffA5AC;
    address public constant MAINNET_SYMBIOTIC_CBETH_COLLATERAL = 0xB26ff591F44b04E78de18f43B46f8b70C6676984;
    address public constant MAINNET_SYMBIOTIC_ENA_COLLATERAL = 0xe39B5f5638a209c1A6b6cDFfE5d37F7Ac99fCC84;
    address public constant MAINNET_SYMBIOTIC_WBETH_COLLATERAL = 0x422F5acCC812C396600010f224b320a743695f85;
    address public constant MAINNET_SYMBIOTIC_SWELL_SWBTC_COLLATERAL = 0x9e405601B645d3484baeEcf17bBF7aD87680f6e8;
    address public constant MAINNET_SYMBIOTIC_SWETH_COLLATERAL = 0x38B86004842D3FA4596f0b7A0b53DE90745Ab654;
    address public constant MAINNET_SYMBIOTIC_LSETH_COLLATERAL = 0xB09A50AcFFF7D12B7d18adeF3D1027bC149Bad1c;
    address public constant MAINNET_SYMBIOTIC_OSETH_COLLATERAL = 0x52cB8A621610Cc3cCf498A1981A8ae7AD6B8AB2a;
    address public constant MAINNET_SYMBIOTIC_MEV_CAPITAL_WSTETH_COLLATERAL = 0x4e0554959A631B3D3938ffC158e0a7b2124aF9c5;
    address public constant MAINNET_SYMBIOTIC_SFRXETH_COLLATERAL = 0x5198CB44D7B2E993ebDDa9cAd3b9a0eAa32769D2;
    address public constant MAINNET_SYMBIOTIC_GUANTLET_RESTAKED_SWETH_COLLATERAL =
        0x65B560d887c010c4993C8F8B36E595C171d69D63;
    address public constant MAINNET_SYMBIOTIC_ETHFI_COLLATERAL = 0x21DbBA985eEA6ba7F27534a72CCB292eBA1D2c7c;
    address public constant MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_CBETH_COLLATERAL =
        0xB8Fd82169a574eB97251bF43e443310D33FF056C;
    address public constant MAINNET_SYMBIOTIC_FXS_COLLATERAL = 0x940750A267c64f3BBcE31B948b67CD168f0843fA;
    address public constant MAINNET_SYMBIOTIC_TBTC_COLLATERAL = 0x0C969ceC0729487d264716e55F232B404299032c;
    address public constant MAINNET_SYMBIOTIC_MANTA_COLLATERAL = 0x594380c06552A4136E2601F89E50b3b9Ad17bd4d;
    address public constant MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_WSTETH_COLLATERAL =
        0xc10A7f0AC6E3944F4860eE97a937C51572e3a1Da;

    address public constant MAINNET_SYMBIOTIC_COLLATERAL_MIGRATOR = 0x8F152FEAA99eb6656F902E94BD4E7bCf563D4A43;
    address public constant MAINNET_KARAK_VAULT_SUPERVISOR = 0x54e44DbB92dBA848ACe27F44c0CB4268981eF1CC;
    address public constant MAINNET_KARAK_DELEGATION_SUPERVISOR = 0xAfa904152E04aBFf56701223118Be2832A4449E0;
    address public constant MAINNET_ETHENA_LP_STAKING = 0x8707f238936c12c309bfc2B9959C35828AcFc512;
    address public constant MAINNET_FLUID_VAULT_WEETH_WSTETH = 0xeAEf563015634a9d0EE6CF1357A3b205C35e028D;
    address public constant MAINNET_FLUID_VAULT_FACTORY = 0x324c5Dc1fC42c7a4D43d92df1eBA58a54d13Bf2d;
    address public constant MAINNET_FLUID_VAULT_WEETHS_WSTETH = 0x1c6068eC051f0Ac1688cA1FE76810FA9c8644278;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDC = 0x3996464c0fCCa8183e13ea5E5e74375e2c8744Dd;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDT = 0xBc345229C1b52e4c30530C614BB487323BA38Da5;
    address public constant MAINNET_FLUID_VAULT_SUSDE_GHO = 0x2F3780e21cAba1bEdFB24E37C97917def304dFFA;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDT_USDT = 0x7503b58Bb29937e7E2980f70D3FD021B7ebeA6d0;
    address public constant MAINNET_FLUID_VAULT_SUSDE_USDC_USDT = 0xe210d8ded13Abe836a10E8Aa956dd424658d0034;
    address public constant MAINNET_FLUID_VAULT_USDE_USDT_USDT = 0x989a44CB4dBb7eBe20e0aBf3C1E1d727BF90F881;
    address public constant MAINNET_ETHERFI_LRT2_CLAIM = 0x6Db24Ee656843E3fE03eb8762a54D86186bA6B64;
    address public constant MAINNET_EULER_VAULT_CONNECTOR = 0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383;

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
    address public constant MAINNET_METH = 0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa;
    address public constant MAINNET_RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address public constant MAINNET_CBETH = 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704;

    address public constant MAINNET_WBETH = 0xa2E3356610840701BDf5611a53974510Ae27E2e1;
    address public constant MAINNET_SWETH = 0xf951E335afb289353dc249e82926178EaC7DEd78;
    address public constant MAINNET_LSETH = 0x8c1BEd5b9a0928467c9B1341Da1D7BD5e10b6549;
    address public constant MAINNET_OSETH = 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38;
    address public constant MAINNET_SFRX = 0xac3E018457B222d93114458476f3E3416Abbe38F;
    address public constant MAINNET_FXS = 0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0;
    address public constant MAINNET_MANTA = 0x95CeF13441Be50d20cA4558CC0a27B601aC544E5;

    address public constant MAINNET_RE7LRT = 0x84631c0d0081FDe56DeB72F6DE77abBbF6A9f93a;
    address public constant MAINNET_RE7RWBTC = 0x7F43fDe12A40dE708d908Fb3b9BFB8540d9Ce444;
    address public constant MAINNET_WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    address public constant MAINNET_USR = 0x66a1E37c9b0eAddca17d3662D6c05F4DECf3e110;
    address public constant MAINNET_RLP = 0x4956b52aE2fF65D74CA2d61207523288e4528f96;
    address public constant MAINNET_STUSR = 0x6c8984bc7DBBeDAf4F6b2FD766f16eBB7d10AAb4;
    address public constant MAINNET_WSTUSR = 0x1202F5C7b4B9E47a1A484E8B270be34dbbC75055;

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
    address public constant MAINNET_YT_WSTUSR_26MAR2025 = 0xe0e034AfF49755e80b15594ce3A16d74d1a09b2F;

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
    // Mellow: MEV Capital Lidov3 stVault x Kiln
    address public constant MAINNET_MELLOW_MEVKSTETH = 0x0F37f1ff51Fc2f8a9907eF3e226A12fDC47de4aD;
    // Mellow: MEV Capital Lidov3 stVault x Nodeinfra
    address public constant MAINNET_MELLOW_MEVNOETH = 0x73D596efEAe0A6833079e4fc999FD5ceE55770A5;
    // Mellow: MEV Capital Lidov3 stVault x Blockscape
    address public constant MAINNET_MELLOW_MEVBLETH = 0x70558848f6b31AE03AD5a25868cD3d25E0fE8506;
    // Mellow: MEV Capital Lidov3 stVault x Alchemy
    address public constant MAINNET_MELLOW_ALSTETH = 0x1af14EBC81e8F92E0DA13D2912091d556a4Ac47B;
    // Mellow: Stakefish Lido v3 Restaked ETH
    address public constant MAINNET_MELLOW_SFETH = 0xb11C95eeB53FF748B6Dd4e2F9f4294F8F4030aF0;
    // Mellow: A41 Vault
    address public constant MAINNET_MELLOW_A41ETH = 0x1EC4C1f8CDd7cb2Da5903701bFbD64f03ed33244;
    // Mellow: Marlin POND LRT
    address public constant MAINNET_MELLOW_RSPOND = 0x4d12fA40e9608298be8F62Bd3627C152d8566B49;

    address public constant MAINNET_POND = 0x57B946008913B82E4dF85f501cbAeD910e58D26C;

    // YT Yield Claiming
    address public constant MAINNET_SY_SUSDE = 0xD288755556c235afFfb6316702719C32bD8706e8;
    address public constant MAINNET_PENDLE_ROUTERV4 = 0x888888888889758F76e7103c6CbF23ABbF58F946;
    address public constant MAINNET_SY_RSUSDE = 0xBCD9522EEf626dD0363347BDE6cAB105c2C7797e;
    address public constant MAINNET_SY_KARAK_SUSDE_30JAN2025 = 0x1b641894e66aec7Bf5ab86517e8D81763Cc8e19E;
    address public constant MAINNET_SY_SUSDE_27MAR2025 = 0x3Ee118EFC826d30A29645eAf3b2EaaC9E8320185;
    address public constant MAINNET_SY_SUSDE_29MAY2025 = 0xE877B2A8a53763C8B0534a15e87da28f3aC1257e;
    address public constant MAINNET_SY_WSTUSR_26MAR2025 = 0x6c78661c00D797C9c7fCBE4BCacbD9612A61C07f;

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
        } else if (tagHash == keccak256(bytes("initial-resolv-strategies"))) {
            return getInitialResolvStrategyProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-1"))) {
            return getSymbioticExpansionBatch1ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-2"))) {
            return getSymbioticExpansionBatch2ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-3"))) {
            return getSymbioticExpansionBatch3ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-4"))) {
            return getSymbioticExpansionBatch4ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return getMellowVaultsGuardProtocolConfigs();
        } else if (tagHash == keccak256(bytes("add-additional-mellow-vaults"))) {
            return getAdditionalMellowVaultsGuardProtocolConfigs();
        } else if (tagHash == keccak256(bytes("fluid-loop-usde-smart-vaults"))) {
            return getFluidLoopUSDeSmartVaultsConfigs();
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
        } else if (tagHash == keccak256(bytes("initial-resolv-strategies"))) {
            return getInitialResolvStrategyTokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-1"))) {
            return getSymbioticExpansionBatch1TokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-2"))) {
            return getSymbioticExpansionBatch2TokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-3"))) {
            return getSymbioticExpansionBatch3TokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-4"))) {
            return getSymbioticExpansionBatch4TokenGuardConfigs();
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return getMellowVaultsGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("add-additional-mellow-vaults"))) {
            return getAdditionalMellowVaultsGuardTokenConfigs();
        } else if (tagHash == keccak256(bytes("fluid-loop-usde-smart-vaults"))) {
            return new TokenGuardConfig[](0);
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
        } else if (tagHash == keccak256(bytes("initial-resolv-strategies"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-1"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-2"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-3"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-4"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-additional-mellow-vaults"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-usde-smart-vaults"))) {
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
        } else if (tagHash == keccak256(bytes("initial-resolv-strategies"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-1"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-2"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-3"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("symbiotic-expansion-batch-4"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-mellow-vaults"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("add-additional-mellow-vaults"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-loop-usde-smart-vaults"))) {
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
        configs[2].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // Symbiotic SUSDe Collateral
        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_SUSDE_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[3].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
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

    function getProtocolGuardConfigMellowSymbiotic(address vault, bool hasClaim)
        internal
        pure
        returns (ProtocolGuardConfig memory config)
    {
        config = ProtocolGuardConfig({target: vault, selectorStates: new SelectorState[](hasClaim ? 4 : 3)});
        config.selectorStates[0] =
            SelectorState({selector: IERC4626Mellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        config.selectorStates[1] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        config.selectorStates[2] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        if (hasClaim) {
            config.selectorStates[3] =
                SelectorState({selector: IMellowSymbioticVault.claim.selector, state: RumpelGuard.AllowListState.ON});
        }
    }

    // Mellow Vaults ----
    function getMellowVaultsGuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](17);

        // Mellow Simple Lido DV
        configs[0] = ProtocolGuardConfig({target: MAINNET_MELLOW_DVSTETH, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMellowT1.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IMellowT1.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow pzETH
        configs[1] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_RENZO_PZETH, true);

        // Mellow rsENA
        configs[2] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_RSENA, true);

        // Mellow amphrBTC
        configs[3] = ProtocolGuardConfig({target: MAINNET_MELLOW_AMPHRBTC, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow steakLRT
        configs[4] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_STEAKLRT, true);

        // Mellow HYVEX
        configs[5] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_HYVEX, true);

        // Mellow Re7rtBTC
        configs[6] = ProtocolGuardConfig({target: MAINNET_MELLOW_RE7RTBTC, selectorStates: new SelectorState[](2)});
        configs[6].selectorStates[0] =
            SelectorState({selector: IMellow.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[6].selectorStates[1] =
            SelectorState({selector: IMellow.registerWithdrawal.selector, state: RumpelGuard.AllowListState.ON});

        // Mellow ifsETH
        configs[7] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_IFSETH, true);

        // Mellow cp0xLRT
        configs[8] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_CP0XLRT, true);

        // Mellow urLRT
        configs[9] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_URLRT, true);

        // Mellow coETH
        configs[10] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_COETH, true);

        // Mellow hcETH
        configs[11] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_HCETH, true);

        // Mellow isETH
        configs[12] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_ISETH, true);

        // Mellow siBTC
        configs[13] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_SIBTC, true);

        // Mellow LUGAETH
        configs[14] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_LUGAETH, true);

        // Mellow roETH
        configs[15] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_ROETH, true);

        // Mellow rsuniBTC
        configs[16] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_RSUNIBTC, true);

        return configs;
    }

    function getAdditionalMellowVaultsGuardProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](7);

        // Mellow mevkstETH
        configs[0] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_MEVKSTETH, false);

        // Mellow mevnoETH
        configs[1] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_MEVNOETH, false);

        // Mellow mevblETH
        configs[2] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_MEVBLETH, false);

        // Mellow ALstETH
        configs[3] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_ALSTETH, false);

        // Mellow sfETH
        configs[4] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_SFETH, false);

        // Mellow a41ETH
        configs[5] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_A41ETH, false);

        // Mellow rsPOND
        configs[6] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_RSPOND, true);

        return configs;
    }

    function getMellowVaultsGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](20);

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

    function getAdditionalMellowVaultsGuardTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](8);

        configs[0] = TokenGuardConfig({
            token: MAINNET_POND,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_MELLOW_MEVKSTETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_MELLOW_MEVNOETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_MELLOW_MEVBLETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_MELLOW_ALSTETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_MELLOW_SFETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_MELLOW_A41ETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_MELLOW_RSPOND,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
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

    function getInitialResolvStrategyProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_EULER_VAULT_CONNECTOR, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IEthereumVaultConnector.batch.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_SY_WSTUSR_26MAR2025, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getInitialResolvStrategyTokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](6);

        configs[0] = TokenGuardConfig({
            token: MAINNET_USR,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_RLP,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_STUSR,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[3] = TokenGuardConfig({
            token: MAINNET_WSTUSR,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[4] = TokenGuardConfig({
            token: MAINNET_YT_WSTUSR_26MAR2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[5] = TokenGuardConfig({
            token: MAINNET_SY_WSTUSR_26MAR2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch1ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](5);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_METH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_WBTC_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_RETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[2].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_CBETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[3].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // skip deposit and withdraw of ENA -- only allow asset receipt asset transfer

        configs[4] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_COLLATERAL_MIGRATOR, selectorStates: new SelectorState[](1)});
        configs[4].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateralMigrator.migrate.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch1TokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](8);

        configs[0] = TokenGuardConfig({
            token: MAINNET_METH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_RETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_CBETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // include approvals for migration functionality
        configs[3] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_METH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[4] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_WBTC_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[5] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_RETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[6] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_CBETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[7] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_ENA_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch2ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](5);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_WBETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_SYMBIOTIC_SWELL_SWBTC_COLLATERAL,
            selectorStates: new SelectorState[](2)
        });
        configs[1].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_SWETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[2].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_LSETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[3].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[4] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_OSETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[4].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[4].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch2TokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](8);

        // underlying
        configs[0] = TokenGuardConfig({
            token: MAINNET_WBETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_SWETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_LSETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_OSETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // symbiotic default collateral
        configs[4] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_WBETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_SWETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_LSETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_OSETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch3ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        // ETHFI skipped as reward token - only transfer enabled

        configs[0] = ProtocolGuardConfig({
            target: MAINNET_SYMBIOTIC_MEV_CAPITAL_WSTETH_COLLATERAL,
            selectorStates: new SelectorState[](2)
        });
        configs[0].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_SFRXETH_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] = ProtocolGuardConfig({
            target: MAINNET_SYMBIOTIC_GUANTLET_RESTAKED_SWETH_COLLATERAL,
            selectorStates: new SelectorState[](2)
        });
        configs[2].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch3TokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](4);

        // underlying
        // wstETH already added
        // swETH added in symbiotic-batch-2
        // ETHFI skipped as reward token
        configs[0] = TokenGuardConfig({
            token: MAINNET_SFRX,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // collateral tokens
        configs[1] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_SFRXETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_GUANTLET_RESTAKED_SWETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_ETHFI_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch4ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](5);

        configs[0] = ProtocolGuardConfig({
            target: MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_CBETH_COLLATERAL,
            selectorStates: new SelectorState[](2)
        });
        configs[0].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_FXS_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_TBTC_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[2].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[3] =
            ProtocolGuardConfig({target: MAINNET_SYMBIOTIC_MANTA_COLLATERAL, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[3].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[4] = ProtocolGuardConfig({
            target: MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_WSTETH_COLLATERAL,
            selectorStates: new SelectorState[](2)
        });
        configs[4].selectorStates[0] = SelectorState({
            selector: ISymbioticDefaultCollateral.deposit.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[4].selectorStates[1] = SelectorState({
            selector: ISymbioticDefaultCollateral.withdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getSymbioticExpansionBatch4TokenGuardConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](8);

        // underlying
        configs[0] = TokenGuardConfig({
            token: MAINNET_FXS,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_TBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_MANTA,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // vaults
        configs[3] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_CBETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_FXS_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_TBTC_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_MANTA_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_SYMBIOTIC_GAUNTLET_RESTAKED_WSTETH_COLLATERAL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getFluidLoopUSDeSmartVaultsConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDT_USDT, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_SUSDE_USDC_USDT, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] =
            ProtocolGuardConfig({target: MAINNET_FLUID_VAULT_USDE_USDT_USDT, selectorStates: new SelectorState[](1)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT1.operate.selector, state: RumpelGuard.AllowListState.ON});

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

interface ISymbioticDefaultCollateral {
    function deposit(address recipient, uint256 amount) external returns (uint256);
    function withdraw(address recipient, uint256 amount) external;
}

interface ISymbioticDefaultCollateralMigrator {
    function migrate(address collateral, address vault, address onBehalfOf, uint256 amount)
        external
        returns (uint256 depositedAmount, uint256 mintedShares);
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

interface IMellowT1 {
    function deposit(address to, uint256[] memory amounts, uint256 minLpAmount, uint256 deadline, uint256 referralCode)
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

interface IERC4626Mellow {
    function deposit(uint256 assets, address receiver, address referral) external returns (uint256 shares);
}

interface IMellowSymbioticVault {
    function claim(address account, address recipient, uint256 maxAmount) external returns (uint256);
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

interface IEthereumVaultConnector {
    struct BatchItem {
        address targetContract;
        address onBehalfOfAccount;
        uint256 value;
        bytes data;
    }

    function batch(BatchItem[] calldata items) external payable;
}

interface Safe {
    function swapOwner(address prevOwner, address oldOwner, address newOwner) external;
}
