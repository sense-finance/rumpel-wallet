// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {RumpelModule} from "../src/RumpelModule.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import {console} from "forge-std/console.sol";
import {Interface as ActionMiscV3_RumpelV2} from "./dependencies/interfaces/IPendle_ActionMiscV3.sol";

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
    address public constant MAINNET_FLUID_VAULT_DEX_SUSDE_USDT_USDT = 0x7503b58Bb29937e7E2980f70D3FD021B7ebeA6d0; // sUSDe-USDT/USDT
    address public constant MAINNET_FLUID_VAULT_SUSDE_DEX_USDC_USDT = 0xe210d8ded13Abe836a10E8Aa956dd424658d0034; // sUSDe/USDC-USDT
    address public constant MAINNET_FLUID_VAULT_DEX_USDE_USDT_USDT = 0x989a44CB4dBb7eBe20e0aBf3C1E1d727BF90F881; // USDe-USDT/USDT
    address public constant MAINNET_FLUID_VAULT_DEX_EBTC_CBBTC_WBTC = 0x43d1cA906c72f09D96291B4913D7255E241F428d; // EBTC-cbBTC/WBTC
    address public constant MAINNET_FLUID_VAULT_DEX_SUDE_USDT_DEX_USDC_USDT = 0xB170B94BeFe21098966aa9905Da6a2F569463A21; // sUSDe-USDT/USDC-USDT
    address public constant MAINNET_FLUID_VAULT_DEX_UDE_USDT_DEX_USDC_USDT = 0xaEac94D417BF8d8bb3A44507100Ab8c0D3b12cA1; // USDe-USDT/USDC-USDT
    address public constant MAINNET_FLUID_VAULT_DEX_GHO_SUSDE_DEX_GHO_USDC = 0x0a90ED6964f6bA56902fD35EE11857A810Dd5543; // GHO smart debt/collateral
    address public constant MAINNET_FLUID_VAULT_DEX_SUSDE_USDT_DEX_USDC_USDT =
        0x91D5884a57E4A3718654B462B32cC628b2c6A39A; // sUSDe smart debt/collateral
    address public constant MAINNET_FLUID_VAULT_DEX_USDE_USDT_DEX_USDC_USDT = 0x4B5fa15996C2E23b35E64f0ca62d30c4945E53Cb; // USDe smart debt/collateral
    address public constant MAINNET_FLUID_VAULT_DEX_GHO_USDE_DEX_GHO = 0x4095a3A8efe779D283102377669778900212D856; // GHO-USDE/GHO
    address public constant MAINNET_FLUID_MERKLE_DISTRIBUTOR = 0xD833484b198D3d05707832cc1C2D62b520D95B8A;
    address public constant MAINNET_FLUID_TOKEN = 0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb;

    address public constant MAINNET_FLUID_VAULT_USDE_USDTB_DEX_USDT = 0x5668c53C6188BA0a311E28b54D7822771D9BDeea;
    address public constant MAINNET_FLUID_VAULT_USDE_USDTB_DEX_USDC = 0x71a3bD2B2214E51e33144590948aA88beAfF2E44;
    address public constant MAINNET_FLUID_VAULT_USDE_USDTB_DEX_GHO = 0x1e6ce96d65901E0779C17E83258e07D2f8962fa4;
    address public constant MAINNET_FLUID_VAULT_GHO_USDE_DEX_GHO_USDC = 0xe3Cac7cC6b0EeD28e16331F08be7948BbfcB5acC;

    address public constant MAINNET_ETHERFI_LRT2_CLAIM = 0x6Db24Ee656843E3fE03eb8762a54D86186bA6B64;
    address public constant MAINNET_EULER_VAULT_CONNECTOR = 0x0C9a3dd6b8F28529d72d7f9cE918D493519EE383;
    address public constant MAINNET_CONTANGO_POSITION_NFT = 0xC2462f03920D47fC5B9e2C5F0ba5D2ded058fD78;
    address public constant MAINNET_CONTANGO_MAESTRO = 0x79B2374Bd437D031A4561fac55d62aD3E6516276;

    // HyperEVM Tokens
    address public constant HYPEEVM_HYPERBEAT_VAULT_HYPE = 0x96C6cBB6251Ee1c257b2162ca0f39AA5Fa44B1FB;
    address public constant HYPEREVM_HYPERBEAT_VAULT_UBTC = 0xc061d38903b99aC12713B550C2CB44B221674F94;
    address public constant HYPEREVM_HYPERBEAT_VAULT_XUAT0 = 0x6EB6724D8D3D4FF9E24d872E8c38403169dC05f8;
    address public constant HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_XUAT0 = 0x48fb106Ef0c0C1a19EdDC9C5d27A945E66DA1C4E;
    address public constant HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_XUAT0 = 0xD26bB9B45140D17eF14FbD4fCa8Cf0d610ac50E7;
    address public constant HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0 = 0x53A333e51E96FE288bC9aDd7cdC4B1EAD2CD2FfA;
    address public constant HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE = 0xd19e3d00f8547f7d108abFD4bbb015486437B487;
    address public constant HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH = 0x0571362ba5EA9784a97605f57483f865A37dBEAA;
    address public constant HYPEEVM_SENTIMENT_POSITION_MANAGER = 0xE019Ce6e80dFe505bca229752A1ad727E14085a4;
    address public constant HYPEEVM_SENTIMENT_POOL = 0x36BFD6b40e2c9BbCfD36a6B1F1Aa65974f4fFA5D;
    address public constant HYPEEVM_HYPE_SENTIMENT_SUPER_POOL = 0x2831775cb5e64B1D892853893858A261E898FbEb;
    address public constant HYPEEVM_HYPERBEAT_VAULT_LST = 0x81e064d0eB539de7c3170EDF38C1A42CBd752A76;
    address public constant HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_LST = 0x2b158D44eEbb03a025F75B79F1d8B3004Ac97737;
    address public constant HYPEEVM_HYPERBEAT_VAULT_REDEMPTION_LST = 0x1eff01e0784ae8d06a17AF29A2300D2A9cdA5440;

    // Hyperbeat liquidHYPE Vaults were initially incorrectly named beHYPE Vaults
    address public constant HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_LIQUIDHYPE = 0xF538675D292d8b372712f44eaf306Cc66cF6d8DC;
    address public constant HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_ADAPTER_LIQUIDHYPE =
        0xf8deEFa84b87b9702474b2D198bb8d21FA03Cd2D;
    address public constant HYPEEVM_HYPERBEAT_VAULT_REDEMPTION_LIQUIDHYPE = 0x558806a80b42cAB4ED75c74bfB178EDc9087AA32;
    address public constant HYPEEVM_HYPERBEAT_VAULT_LIQUIDHYPE = 0x441794D6a8F9A3739F5D4E98a728937b33489D29;

    // Actual Hyperbeat BEHYPE Token and vaults
    address public constant HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_BEHYPE = 0xCeaD893b162D38e714D82d06a7fe0b0dc3c38E0b;
    address public constant HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_BEHYPE = 0x9d0B0877b9f2204CF414Ca7862E4f03506822538;
    address public constant HYPEREVM_HYPERBEAT_BEHYPE = 0xd8FC8F0b03eBA61F64D08B0bef69d80916E5DdA9;

    address public constant HYPEREVM_HYPERBEAT_VAULT_USDT = 0x5e105266db42f78FA814322Bce7f388B4C2e61eb;
    address public constant HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_USDT = 0xbE8A4f1a312b94A712F8E5367B02ae6E378E6F19;
    address public constant HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_USDT = 0xC898a5cbDb81F260bd5306D9F9B9A893D0FdF042;
    address public constant HYPEREVM_HYPERBEAT_VAULT_HYPERUSDT0 = 0xe5ADd96840F0B908ddeB3Bd144C0283Ac5ca7cA0;
    address public constant HYPEREVM_HYPERBEAT_BORROW = 0x68e37dE8d93d3496ae143F2E900490f6280C57cD;
    address public constant HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE = 0x92B518e1cD76dD70D3E20624AEdd7D107F332Cff;
    address public constant HYPEREVM_KINETIQ_EARN_VAULT = 0x9BA2EDc44E0A4632EB4723E81d4142353e1bB160;
    address public constant HYPEREVM_KINETIQ_EARN_VAULT_DEPOSIT = 0x29C0C36eD3788F1549b6a1fd78F40c51F0f73158;
    address public constant HYPEREVM_KINETIQ_EARN_WITHDRAW_QUEUE = 0x08a9552688F8DEC4835f5396ca3D1fd2713f79A7;

    // HyperEVM Pendle-YTs
    address public constant HYPEREVM_PENDLE_YT_BEHYPE_29OCT2025 = 0x8F454bFe03527E8a838002b5Bf7BFE5F296Aac09;
    address public constant HYPEREVM_PENDLE_YT_HBHYPE_17DEC2025 = 0x2b55b35d9bE63d016eE902d87AF29D2C4F397Dc1;
    address public constant HYPEREVM_PENDLE_YT_HBUSDT_17DEC2025 = 0x47dD54DFa68172E3354e3cBA2F59521d3dc9D9C7;
    address public constant HYPEREVM_PENDLE_YT_KHYPE_12NOV2025 = 0x3f6583Ad479AB6020297ce12c9059D7480Ab6E5A;

    // HyperEVM Pendle-SYs
    address public constant HYPEREVM_PENDLE_ROUTERV4 = 0x888888888889758F76e7103c6CbF23ABbF58F946; // 0x0741a803 --> claim header
    address public constant HYPEREVM_PENDLE_SY_BEHYPE_29OCT2025 = 0x41D81Daf401a0AA7422a769243fa933f351a0D64;
    address public constant HYPEREVM_PENDLE_SY_HBHYPE_17DEC2025 = 0x0FcDe5a369c0D71ac932840C8654DB03681912Dd;
    address public constant HYPEREVM_PENDLE_SY_HBUSDT_17DEC2025 = 0x642135Ff98C15cBA7fCF1766502bd493BE4D3492;
    address public constant HYPEREVM_PENDLE_SY_KHYPE_12NOV2025 = 0x57FC55dFF8CeCa86EE94a6bF255af2f0ED90eB9e;

    // HyperEVM Felix
    address public constant HYPEREVM_WHYPE_FELIX_STABILITY_POOL = 0x576c9c501473e01aE23748de28415a74425eFD6b;
    address public constant HYPEREVM_UBTC_FELIX_STABILITY_POOL = 0xabF0369530205aE56dD4C49629474C65d1168924;
    address public constant HYPEREVM_USDE_FELIX_METAMORPHO_VAULT = 0x835FEBF893c6DdDee5CF762B0f8e31C5B06938ab;
    address public constant HYPEREVM_USDT0_FELIX_METAMORPHO_VAULT = 0xFc5126377F0efc0041C0969Ef9BA903Ce67d151e;
    address public constant HYPEREVM_USDHL_FELIX_METAMORPHO_VAULT = 0x9c59a9389D8f72DE2CdAf1126F36EA4790E2275e;

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
    address public constant MAINNET_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant MAINNET_MORPHO = 0x58D97B57BB95320F9a05dC918Aef65434969c2B2;
    address public constant MAINNET_USDTB = 0xC139190F447e929f090Edeb554D95AbB8b18aC1C;

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
    address public constant MAINNET_EBTC = 0x657e8C867D8B37dCC18fA4Caead9C45EB088C642;
    address public constant MAINNET_CBBTC = 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf;

    address public constant MAINNET_USR = 0x66a1E37c9b0eAddca17d3662D6c05F4DECf3e110;
    address public constant MAINNET_RLP = 0x4956b52aE2fF65D74CA2d61207523288e4528f96;
    address public constant MAINNET_STUSR = 0x6c8984bc7DBBeDAf4F6b2FD766f16eBB7d10AAb4;
    address public constant MAINNET_WSTUSR = 0x1202F5C7b4B9E47a1A484E8B270be34dbbC75055;

    address public constant MAINNET_PENDLE = 0x808507121B80c02388fAd14726482e061B8da827;
    address public constant MAINNET_VEPENDLE = 0x4f30A9D41B80ecC5B94306AB4364951AE3170210;

    address public constant MAINNET_EUL = 0xd9Fcd98c322942075A5C3860693e9f4f03AAE07b;

    // HyperEVM Tokens
    address public constant HYPEEVM_WHYPE = 0x5555555555555555555555555555555555555555;
    address public constant HYPEEVM_WSTHYPE = 0x94e8396e0869c9F2200760aF0621aFd240E1CF38;
    address public constant HYPEREVM_UBTC = 0x9FDBdA0A5e284c32744D2f17Ee5c74B284993463;
    address public constant HYPEREVM_XAUT0 = 0xf4D9235269a96aaDaFc9aDAe454a0618eBE37949;
    address public constant HYPEREVM_USDT0 = 0xB8CE59FC3717ada4C02eaDF9682A9e934F625ebb;
    address public constant HYPEREVM_UETH = 0xBe6727B535545C67d5cAa73dEa54865B92CF7907;
    address public constant HYPEREVM_USDE = 0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34;
    address public constant HYPEREVM_USDHL = 0xb50A96253aBDF803D85efcDce07Ad8becBc52BD5;
    address public constant HYPEREVM_KHYPE = 0xfD739d4e423301CE9385c1fb8850539D657C296D;

    // Pendle YTs
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
    address public constant MAINNET_YT_LVLUSD_28MAY2025 = 0x65901Ac9EFA7CdAf1Bdb4dbce4c53B151ae8d014;
    address public constant MAINNET_YT_EBTC_25JUNE2025 = 0x6a162ea0F31dC63Cd154f4fcCDD43B612Df731e9;
    address public constant MAINNET_YT_SUSDE_30JUL2025 = 0xb7E51D15161C49C823f3951D579DEd61cD27272B;
    address public constant MAINNET_YT_EUSDE_28MAY2025 = 0x708dD9B344dDc7842f44C7b90492CF0e1E3eb868;
    address public constant MAINNET_YT_EUSDE_13AUG2025 = 0xe8eF806c8aaDc541408dcAd36107c7d26a391712;
    address public constant MAINNET_YT_USDE_30JUL2025 = 0x733Ee9Ba88f16023146EbC965b7A1Da18a322464;
    address public constant MAINNET_YT_LVLUSD_24SEP2025 = 0x946934554a2Bf59039661f971986F0223E906264;
    address public constant MAINNET_YT_USR_28MAY2025 = 0x77DE4Be22Ecc633416D79371eF8e861Fb1d2cC39;
    address public constant MAINNET_YT_WSTUSR_24SEP2025 = 0x1E24B022329f3CA0083b12FAF75d19639FAebF6f;
    address public constant MAINNET_YT_WEETHS_25JUNE2025 = 0xaaC7DB6C2bC926aDE954D69A2d705f059043EA02;
    address public constant MAINNET_YT_EETH_25JUNE2025 = 0x08AEfe9dFe7818CaaedD94E38e910d2155b7d2b0;
    address public constant MAINNET_YT_WEETHK_25JUNE2025 = 0x03722CE19e9F5828969D39474a8EfC35c4eA3987;
    address public constant MAINNET_YT_AGETH_25JUNE2025 = 0x0310A860CF7Efe8F54Ab9B4dE49Cd071C37fCBCB;
    address public constant MAINNET_PENDLE_YT_USDE_27MAR2025 = 0x4A8036EFA1307F1cA82d932C0895faa18dB0c9eE;
    address public constant MAINNET_YT_USDE_24SEP2025 = 0x48bbbEdc4d2491cc08915D7a5c7cc8A8EdF165da;
    address public constant MAINNET_YT_SUSDE_24SEP2025 = 0x029d6247ADb0A57138c62E3019C92d3dfC9c1840;
    address public constant MAINNET_YT_USDE_26NOV2025 = 0x99C92D4Da7a81c7698EF33a39D7538d0f92623f7;
    address public constant MAINNET_YT_SUSDE_26NOV2025 = 0x28E626b560F1FaaC01544770425e2De8FD179c79;

    // Pendle LPs
    address public constant MAINNET_PENDLE_LP_WSTUSR_24SEP2025 = 0x09fA04Aac9c6d1c6131352EE950CD67ecC6d4fB9;
    address public constant MAINNET_PENDLE_LP_USDE_30JUL2025 = 0x9Df192D13D61609D1852461c4850595e1F56E714;
    address public constant MAINNET_PENDLE_LP_SUSDE_30JUL2025 = 0x4339Ffe2B7592Dc783ed13cCE310531aB366dEac;
    address public constant MAINNET_PENDLE_LP_WEETHS_25JUNE2025 = 0xcbA3B226cA62e666042Cb4a1e6E4681053885F75;
    address public constant MAINNET_PENDLE_LP_WEETHK_25JUNE2025 = 0x9E612FF1902c5fEEa4fd69eB236375d5299e0FfC;
    address public constant MAINNET_PENDLE_LP_EETH_25JUNE2025 = 0xF4Cf59259D007a96C641B41621aB52C93b9691B1;
    address public constant MAINNET_PENDLE_LP_EBTC_25JUNE2025 = 0x523f9441853467477b4dDE653c554942f8E17162;
    address public constant MAINNET_PENDLE_LP_AGETH_25JUNE2025 = 0xBe8549a20257917a0a9EF8911DAF18190A8842a4;
    address public constant MAINNET_PENDLE_LP_LVLUSD_24SEP2025 = 0x461bc2ac3f80801BC11B0F20d63B73feF60C8076;
    address public constant MAINNET_PENDLE_LP_USDE_24SEP2025 = 0x6d98a2b6CDbF44939362a3E99793339Ba2016aF4;
    address public constant MAINNET_PENDLE_LP_SUSDE_24SEP2025 = 0xA36b60A14A1A5247912584768C6e53E1a269a9F7;

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
    // Mellow: Re7 Resolv Restaked wstUSR
    address public constant MAINNET_MELLOW_RSTUSR = 0x617895460004821C8DE800d4a644593cAb0aD40c;

    address public constant MAINNET_POND = 0x57B946008913B82E4dF85f501cbAeD910e58D26C;

    // YT Yield Claiming
    address public constant MAINNET_SY_SUSDE = 0xD288755556c235afFfb6316702719C32bD8706e8;
    address public constant MAINNET_PENDLE_ROUTERV4 = 0x888888888889758F76e7103c6CbF23ABbF58F946;
    address public constant MAINNET_SY_RSUSDE = 0xBCD9522EEf626dD0363347BDE6cAB105c2C7797e;
    address public constant MAINNET_SY_KARAK_SUSDE_30JAN2025 = 0x1b641894e66aec7Bf5ab86517e8D81763Cc8e19E;
    address public constant MAINNET_SY_SUSDE_27MAR2025 = 0x3Ee118EFC826d30A29645eAf3b2EaaC9E8320185;
    address public constant MAINNET_SY_SUSDE_29MAY2025 = 0xE877B2A8a53763C8B0534a15e87da28f3aC1257e;
    address public constant MAINNET_SY_WSTUSR_26MAR2025 = 0x6c78661c00D797C9c7fCBE4BCacbD9612A61C07f;
    address public constant MAINNET_SY_SUSDE_30JUL2025 = 0xF541AA4d6f29ec2423A0D306dBc677021A02DBC0;
    address public constant MAINNET_SY_WEETHS_25JUNE2025 = 0x012BADcC6e824c2eA32bd5367eBda3be3402c9c5;
    address public constant MAINNET_SY_EETH_25JUNE2025 = 0xAC0047886a985071476a1186bE89222659970d65;
    address public constant MAINNET_SY_WEETHK_25JUNE2025 = 0xffC374D301F2EA381EE313Da0324ea7bf0dbFddF;
    address public constant MAINNET_SY_AGETH_25JUN2025 = 0xb1B9150f2085f6a553b547099977181CA802752A;
    address public constant MAINNET_SY_SUSDE_24SEP2025 = 0xC01cde799245a25e6EabC550b36A47F6F83cc0f1;
    address public constant MAINNET_SY_SUSDE_26NOV2025 = 0xAbf8165dD7a90ab75878161db15Bf85F6F781d9b;

    // Additional Reward Assets
    address public constant MAINNET_LRT2 = 0x8F08B70456eb22f6109F57b8fafE862ED28E6040;
    address public constant MAINNET_OBOL_CLAIM = 0xEfd2247fcC3C7aA1FCbE1d2b81e6d0164583eeA3;
    address public constant MAINNET_OBOL = 0x0B010000b7624eb9B3DfBC279673C76E9D29D5F7;
    address public constant MAINNET_OBOL_LOCKUPS = 0x3b9122704A20946E9Cb49b2a8616CCC0f0d61AdB;

    // Kernel
    address public constant MAINNET_KERNEL_MERKLE_DISTRIBUTOR = 0x68B55c20A2634B25a50a219b632F22854D810bf5;
    address public constant MAINNET_KERNEL = 0x3f80B1c54Ae920Be41a77f8B902259D48cf24cCf;

    // Merkl Claiming
    address public constant MAINNET_MERKL_DISTRIBUTOR = 0x3Ef3D8bA38EBe18DB133cEc108f4D14CE00Dd9Ae;
    address public constant MAINNET_REUL = 0xf3e621395fc714B90dA337AA9108771597b4E696;

    // Morpho
    address public constant MAINNET_MORPHO_DISTRIBUTOR = 0x330eefa8a787552DC5cAd3C3cA644844B1E61Ddb;

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
        } else if (tagHash == keccak256(bytes("obol-claiming"))) {
            return getOBOLProtocolConfigs();
        } else if (tagHash == keccak256(bytes("contango"))) {
            return getContangoProtocolConfigs();
        } else if (tagHash == keccak256(bytes("user-request-batch"))) {
            return getUserRequestBatchProtocolConfigs();
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return getKernelProtocolConfigs();
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return getKernelProtocolConfigs();
        } else if (tagHash == keccak256(bytes("usdc"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("april-25-yt-batch"))) {
            return getApril25YTBatchProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-on"))) {
            return getMerklClaimREULOnProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-off"))) {
            return getMerklClaimREULOffProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("fluid-merkle-claim"))) {
            return getFluidMerkleClaimProtocol();
        } else if (tagHash == keccak256(bytes("may-25-pendle-lp-batch"))) {
            return getPendleLPMay25ProtocolGuardConfigs();
        } else if (tagHash == keccak256(bytes("morpho-transfer-and-claim"))) {
            return getMorphoProtocolConfigs();
        } else if (tagHash == keccak256(bytes("fluid-vaults-and-yt-06-03"))) {
            return getFluidVaultsAndYT0603ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hype-evm-initial-strats"))) {
            return getHypeEVMInitialProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hype-evm-update-sentiment-super-pool"))) {
            return getSentimentHypeSuperPoolProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyperbeat-expansion"))) {
            return getHyperbeatExpansionProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-felix"))) {
            return getHyperbeatFelixProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyperbeat-perm-allow"))) {
            return getHyperEVMPermAllowHyperbeatProtocolConfig();
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq-hyperbeat-lst"))) {
            return getKinetiqHyperbeatLstProtocolConfigs();
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-jul-25"))) {
            return getEthereumEthenaExpansionJul25ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-behype"))) {
            return getHyperevmHyperbeatBeHYPEProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0"))) {
            return getHyperevmHyperbeatHyperUSDT0ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0-token"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("eth-fluid-usde-vaults-jul-25"))) {
            return getEthFluidUsdeVaultsJul25ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-borrow-hbHYPE-and-more-aug25"))) {
            return getHyperevmHyperbeatBorrowAndMoreAug25ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18-blocklist"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18ModulePermProtocolConfigs();
        } else if (tagHash == keccak256(bytes("eth-allow-eul"))) {
            return new ProtocolGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-pendle-claim-update"))) {
            return getHyperevmPendleClaimUpdateProtocolConfigs();
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-sep-15"))) {
            return getEthereumEthenaExpansionSep15ProtocolConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-behype-update"))) {
            return getHyperevmBeHypeProtocolConfigs();
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
            return getFluidLoopUSDeSmartVaultsTokenConfigs();
        } else if (tagHash == keccak256(bytes("obol-claiming"))) {
            return getOBOLTokenConfigs();
        } else if (tagHash == keccak256(bytes("contango"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("user-request-batch"))) {
            return getUserRequestBatchTokenConfigs();
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return getKernelTokenConfigs();
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return getKernelTokenConfigs();
        } else if (tagHash == keccak256(bytes("usdc"))) {
            return getUSDCTokenConfigs();
        } else if (tagHash == keccak256(bytes("april-25-yt-batch"))) {
            return getApril25YTBatchTokenConfigs();
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-on"))) {
            return getMerklClaimREULOnTokenConfigs();
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-off"))) {
            return getMerklClaimREULOffTokenConfigs();
        } else if (tagHash == keccak256(bytes("fluid-merkle-claim"))) {
            return getFluidMerkleClaimToken();
        } else if (tagHash == keccak256(bytes("may-25-pendle-lp-batch"))) {
            return getPendleLPMay25TokenConfigs();
        } else if (tagHash == keccak256(bytes("morpho-transfer-and-claim"))) {
            return getMorphoTokenConfigs();
        } else if (tagHash == keccak256(bytes("fluid-vaults-and-yt-06-03"))) {
            return getFluidVaultsAndYT0603TokenConfigs();
        } else if (tagHash == keccak256(bytes("hype-evm-initial-strats"))) {
            return getHypeEVMInitialTokenConfigs();
        } else if (tagHash == keccak256(bytes("hype-evm-update-sentiment-super-pool"))) {
            return getSentimentHypeSuperPoolTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyperbeat-expansion"))) {
            return getHyperbeatExpansionTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-felix"))) {
            return getHyperbeatFelixTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyperbeat-perm-allow"))) {
            return getHyperEVMPermAllowHyperbeatTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq"))) {
            return getKinetiqTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq-hyperbeat-lst"))) {
            return getKinetiqHyperbeatLstTokenConfigs();
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-jul-25"))) {
            return getEthereumEthenaExpansionJul25TokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-behype"))) {
            return getHyperevmHyperbeatBeHYPETokenConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0-token"))) {
            return getHyperevmHyperbeatHyperUSDT0TokenConfigs();
        } else if (tagHash == keccak256(bytes("eth-fluid-usde-vaults-jul-25"))) {
            return getEthFluidUsdeVaultsJul25TokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-borrow-hbHYPE-and-more-aug25"))) {
            return getHyperevmHyperbeatBorrowAndMoreAug25TokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18TokenConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18-blocklist"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18ModulePermTokenConfigs();
        } else if (tagHash == keccak256(bytes("eth-allow-eul"))) {
            return getEthAllowEulTokenConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-pendle-claim-update"))) {
            return new TokenGuardConfig[](0);
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-sep-15"))) {
            return getEthereumEthenaExpansionSep15TokenConfigs();
        } else if (tagHash == keccak256(bytes("hyperevm-behype-update"))) {
            return getHyperevmBeHypeTokenConfigs();
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
        } else if (tagHash == keccak256(bytes("obol-claiming"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("contango"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("user-request-batch"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("usdc"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("april-25-yt-batch"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-on"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-off"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-merkle-claim"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("may-25-pendle-lp-batch"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("morpho-transfer-and-claim"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-vaults-and-yt-06-03"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hype-evm-initial-strats"))) {
            return getHypeEVMInitialTokenModuleConfigs();
        } else if (tagHash == keccak256(bytes("hype-evm-update-sentiment-super-pool"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperbeat-expansion"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-felix"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperbeat-perm-allow"))) {
            return getHyperEVMPermBlockTokenModuleConfigs();
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq-hyperbeat-lst"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-jul-25"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-behype"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0-token"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("eth-fluid-usde-vaults-jul-25"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-borrow-hbHYPE-and-more-aug25"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18-blocklist"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18ModuleTokenConfigs();
        } else if (tagHash == keccak256(bytes("eth-allow-eul"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-pendle-claim-update"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-sep-15"))) {
            return new TokenModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-behype-update"))) {
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
        } else if (tagHash == keccak256(bytes("obol-claiming"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("contango"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("user-request-batch"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("kernel"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("usdc"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("april-25-yt-batch"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-on"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("merkl-claim-reul-off"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-merkle-claim"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("may-25-pendle-lp-batch"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("morpho-transfer-and-claim"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("fluid-vaults-and-yt-06-03"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hype-evm-initial-strats"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hype-evm-update-sentiment-super-pool"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperbeat-expansion"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-felix"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperbeat-perm-allow"))) {
            return getHyperEVMPermBlockProtocolModuleConfig();
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-kinetiq-hyperbeat-lst"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-jul-25"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-behype"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-hyperbeat-hyperusdt0-token"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("eth-fluid-usde-vaults-jul-25"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-borrow-hbHYPE-and-more-aug25"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyper-evm-hyperbeat-hyperithm-hype-aug18-blocklist"))) {
            return getHyperevmHyperbeatHyperithmHypeAug18ModuleProtocolConfigs();
        } else if (tagHash == keccak256(bytes("eth-allow-eul"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-pendle-claim-update"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("ethereum-ethena-expansion-sep-15"))) {
            return new ProtocolModuleConfig[](0);
        } else if (tagHash == keccak256(bytes("hyperevm-behype-update"))) {
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

    function getFluidLoopUSDeSmartVaultsTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](2);

        configs[0] = TokenGuardConfig({
            token: MAINNET_EBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_CBBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getFluidLoopUSDeSmartVaultsConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](4);

        configs[0] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_SUSDE_USDT_USDT, // sUSDe-USDT/USDT
            selectorStates: new SelectorState[](1)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_SUSDE_DEX_USDC_USDT, // sUSDe/USDC-USDT
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT3.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_USDE_USDT_USDT, // USDe-USDT/USDT
            selectorStates: new SelectorState[](1)
        });
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[3] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_EBTC_CBBTC_WBTC, // EBTC-cbBTC/WBTC
            selectorStates: new SelectorState[](1)
        });
        configs[3].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getFluidVaultsAndYT0603ProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_GHO_SUSDE_DEX_GHO_USDC,
            selectorStates: new SelectorState[](1)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_SUSDE_USDT_DEX_USDC_USDT,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_USDE_USDT_DEX_USDC_USDT,
            selectorStates: new SelectorState[](1)
        });
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getFluidVaultsAndYT0603TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_EUSDE_13AUG2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getOBOLTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_OBOL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getOBOLProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_OBOL_CLAIM, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IObolClaim.claimAndDelegate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_OBOL_LOCKUPS, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IObolLockups.unlock.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getContangoProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_CONTANGO_POSITION_NFT, selectorStates: new SelectorState[](3)});
        configs[0].selectorStates[0] =
            SelectorState({selector: ERC721.transferFrom.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] = SelectorState({
            selector: bytes4(keccak256("safeTransferFrom(address,address,uint256)")),
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[2] = SelectorState({
            selector: bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)")),
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({target: MAINNET_CONTANGO_MAESTRO, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: PayableMulticall.multicall.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getUserRequestBatchTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        configs[0] = TokenGuardConfig({
            token: MAINNET_MELLOW_RSTUSR,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_LVLUSD_28MAY2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        configs[2] = TokenGuardConfig({
            token: MAINNET_YT_EBTC_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getUserRequestBatchProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] = getProtocolGuardConfigMellowSymbiotic(MAINNET_MELLOW_RSTUSR, false);

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_SUDE_USDT_DEX_USDC_USDT, // sUSDe-USDT/USDC-USDT
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_UDE_USDT_DEX_USDC_USDT, // USDe-USDT/USDC-USDT
            selectorStates: new SelectorState[](1)
        });
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getKernelProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_KERNEL_MERKLE_DISTRIBUTOR, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IKernelMerkleDistributor.claim.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] = SelectorState({
            selector: IKernelMerkleDistributor.claimAndStake.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getKernelTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_KERNEL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getUSDCTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_USDC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getApril25YTBatchTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](15);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_30JUL2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_EUSDE_28MAY2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_YT_USDE_30JUL2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_YT_LVLUSD_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_YT_USR_28MAY2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_YT_WSTUSR_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_YT_WEETHS_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_YT_EETH_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[8] = TokenGuardConfig({
            token: MAINNET_YT_WEETHK_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[9] = TokenGuardConfig({
            token: MAINNET_YT_AGETH_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        // SY Tokens
        configs[10] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE_30JUL2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[11] = TokenGuardConfig({
            token: MAINNET_SY_WEETHS_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[12] = TokenGuardConfig({
            token: MAINNET_SY_EETH_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[13] = TokenGuardConfig({
            token: MAINNET_SY_WEETHK_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[14] = TokenGuardConfig({
            token: MAINNET_SY_AGETH_25JUN2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getApril25YTBatchProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](5);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE_30JUL2025, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_SY_WEETHS_25JUNE2025, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] = ProtocolGuardConfig({target: MAINNET_SY_EETH_25JUNE2025, selectorStates: new SelectorState[](1)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[3] = ProtocolGuardConfig({target: MAINNET_SY_WEETHK_25JUNE2025, selectorStates: new SelectorState[](1)});
        configs[3].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[4] = ProtocolGuardConfig({target: MAINNET_SY_AGETH_25JUN2025, selectorStates: new SelectorState[](1)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getMerklClaimREULOnProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_MERKL_DISTRIBUTOR, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: MerklDistributor.claim.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getMerklClaimREULOnTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_REUL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getMerklClaimREULOffProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_MERKL_DISTRIBUTOR, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: MerklDistributor.claim.selector, state: RumpelGuard.AllowListState.OFF});

        return configs;
    }

    function getMerklClaimREULOffTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_REUL,
            transferAllowState: RumpelGuard.AllowListState.OFF,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getFluidMerkleClaimProtocol() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] =
            ProtocolGuardConfig({target: MAINNET_FLUID_MERKLE_DISTRIBUTOR, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: FluidMerkleDistributor.claim.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: FluidMerkleDistributor.bulkClaim.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getPendleLPMay25ProtocolGuardConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, selectorStates: new SelectorState[](5)});
        configs[0].selectorStates[0] = SelectorState({
            selector: IPendleRouterV4.addLiquiditySingleToken.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: IPendleRouterV4.addLiquiditySingleTokenKeepYt.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[2] = SelectorState({
            selector: IPendleRouterV4.removeLiquiditySingleToken.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[3] =
            SelectorState({selector: IPendleRouterV4.multicall.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[4] =
            SelectorState({selector: IPendleRouterV4.callAndReflect.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({target: MAINNET_VEPENDLE, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] = SelectorState({
            selector: IPVotingEscrowMainchain.increaseLockPosition.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[1] =
            SelectorState({selector: IPVotingEscrowMainchain.withdraw.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getFluidMerkleClaimToken() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_FLUID_TOKEN,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getPendleLPMay25TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](10);

        configs[0] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_WSTUSR_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_USDE_30JUL2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_SUSDE_30JUL2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_WEETHS_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[4] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_WEETHK_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[5] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_EETH_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[6] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_EBTC_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[7] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_AGETH_25JUNE2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[8] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_LVLUSD_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // enable pendel transfers & approvals for vePendel locking for LP boosts
        configs[9] = TokenGuardConfig({
            token: MAINNET_PENDLE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getMorphoTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_MORPHO,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getMorphoProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_MORPHO_DISTRIBUTOR, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMorphoDistributor.claim.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHypeEVMInitialProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);
        // hyperbeat vault - deposit & request redeem
        configs[0] = ProtocolGuardConfig({target: HYPEEVM_HYPERBEAT_VAULT_HYPE, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: HyperbeatTokenizedAccount.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] = SelectorState({
            selector: HyperbeatTokenizedAccount.requestRedeem.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // sentiment position manager - process & processBatch
        configs[1] =
            ProtocolGuardConfig({target: HYPEEVM_SENTIMENT_POSITION_MANAGER, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] =
            SelectorState({selector: SentimentPositionManager.process.selector, state: RumpelGuard.AllowListState.ON});
        configs[1].selectorStates[1] = SelectorState({
            selector: SentimentPositionManager.processBatch.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // sentiment pool muli-token.transfer
        configs[2] = ProtocolGuardConfig({target: HYPEEVM_SENTIMENT_POOL, selectorStates: new SelectorState[](1)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IERC6909.transfer.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHypeEVMInitialTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        // whype
        configs[0] = TokenGuardConfig({
            token: HYPEEVM_WHYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // wstHype
        configs[1] = TokenGuardConfig({
            token: HYPEEVM_WSTHYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // hbHype
        configs[2] = TokenGuardConfig({
            token: HYPEEVM_HYPERBEAT_VAULT_HYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHypeEVMInitialTokenModuleConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](2);

        configs[0] = TokenModuleConfig({token: HYPEEVM_WHYPE, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: HYPEEVM_WSTHYPE, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getSentimentHypeSuperPoolProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        // sentiment pool muli-token.transfer
        configs[0] = ProtocolGuardConfig({target: HYPEEVM_SENTIMENT_POOL, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IERC6909.transfer.selector, state: RumpelGuard.AllowListState.OFF});

        return configs;
    }

    function getSentimentHypeSuperPoolTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEEVM_HYPE_SENTIMENT_SUPER_POOL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getHyperbeatExpansionProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](6);

        configs[0] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_VAULT_UBTC, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] =
            SelectorState({selector: HyperbeatTokenizedAccount.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] = SelectorState({
            selector: HyperbeatTokenizedAccount.requestRedeem.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_XUAT0,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositVault.depositInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_XUAT0,
            selectorStates: new SelectorState[](2)
        });
        configs[2].selectorStates[0] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemRequest.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[3] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0,
            selectorStates: new SelectorState[](2)
        });
        configs[3].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[4] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE, selectorStates: new SelectorState[](2)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[5] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH,
            selectorStates: new SelectorState[](2)
        });
        configs[5].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[5].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHyperbeatExpansionTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](10);

        configs[1] = TokenGuardConfig({
            token: HYPEREVM_UBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[2] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_UBTC,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[3] = TokenGuardConfig({
            token: HYPEREVM_XAUT0,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[4] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_XUAT0,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[5] = TokenGuardConfig({
            token: HYPEREVM_USDT0,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[6] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[7] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[8] = TokenGuardConfig({
            token: HYPEREVM_UETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[9] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperbeatFelixProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](5);

        configs[0] =
            ProtocolGuardConfig({target: HYPEREVM_WHYPE_FELIX_STABILITY_POOL, selectorStates: new SelectorState[](3)});
        configs[0].selectorStates[0] =
            SelectorState({selector: LiquityStabilityPool.provideToSP.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] = SelectorState({
            selector: LiquityStabilityPool.withdrawFromSP.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[0].selectorStates[2] = SelectorState({
            selector: LiquityStabilityPool.claimAllCollGains.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] =
            ProtocolGuardConfig({target: HYPEREVM_UBTC_FELIX_STABILITY_POOL, selectorStates: new SelectorState[](3)});
        configs[1].selectorStates[0] =
            SelectorState({selector: LiquityStabilityPool.provideToSP.selector, state: RumpelGuard.AllowListState.ON});
        configs[1].selectorStates[1] = SelectorState({
            selector: LiquityStabilityPool.withdrawFromSP.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[2] = SelectorState({
            selector: LiquityStabilityPool.claimAllCollGains.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // Felix metamorpho vaults ---
        configs[2] =
            ProtocolGuardConfig({target: HYPEREVM_USDE_FELIX_METAMORPHO_VAULT, selectorStates: new SelectorState[](4)});
        configs[2].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[2].selectorStates[1] =
            SelectorState({selector: IERC4626.mint.selector, state: RumpelGuard.AllowListState.ON});
        configs[2].selectorStates[2] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        configs[2].selectorStates[3] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[3] =
            ProtocolGuardConfig({target: HYPEREVM_USDT0_FELIX_METAMORPHO_VAULT, selectorStates: new SelectorState[](4)});
        configs[3].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[1] =
            SelectorState({selector: IERC4626.mint.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[2] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        configs[3].selectorStates[3] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[4] =
            ProtocolGuardConfig({target: HYPEREVM_USDHL_FELIX_METAMORPHO_VAULT, selectorStates: new SelectorState[](4)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[1] =
            SelectorState({selector: IERC4626.mint.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[2] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});
        configs[4].selectorStates[3] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHyperbeatFelixTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](5);

        configs[0] = TokenGuardConfig({
            token: HYPEREVM_USDE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[1] = TokenGuardConfig({
            token: HYPEREVM_USDHL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[2] = TokenGuardConfig({
            token: HYPEREVM_USDE_FELIX_METAMORPHO_VAULT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[3] = TokenGuardConfig({
            token: HYPEREVM_USDT0_FELIX_METAMORPHO_VAULT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[4] = TokenGuardConfig({
            token: HYPEREVM_USDHL_FELIX_METAMORPHO_VAULT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperEVMPermAllowHyperbeatProtocolConfig() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](7);

        configs[0] = ProtocolGuardConfig({target: HYPEEVM_HYPERBEAT_VAULT_HYPE, selectorStates: new SelectorState[](2)});
        configs[0].selectorStates[0] = SelectorState({
            selector: HyperbeatTokenizedAccount.deposit.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[0].selectorStates[1] = SelectorState({
            selector: HyperbeatTokenizedAccount.requestRedeem.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[1] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_VAULT_UBTC, selectorStates: new SelectorState[](2)});
        configs[1].selectorStates[0] = SelectorState({
            selector: HyperbeatTokenizedAccount.deposit.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[1].selectorStates[1] = SelectorState({
            selector: HyperbeatTokenizedAccount.requestRedeem.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[2] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_XUAT0,
            selectorStates: new SelectorState[](1)
        });
        configs[2].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositVault.depositInstant.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[3] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_XUAT0,
            selectorStates: new SelectorState[](2)
        });
        configs[3].selectorStates[0] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemInstant.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });
        configs[3].selectorStates[1] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemRequest.selector,
            state: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[4] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0,
            selectorStates: new SelectorState[](2)
        });
        configs[4].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});
        configs[4].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});

        configs[5] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE, selectorStates: new SelectorState[](2)});
        configs[5].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});
        configs[5].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});

        configs[6] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH,
            selectorStates: new SelectorState[](2)
        });
        configs[6].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});
        configs[6].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});

        return configs;
    }

    function getHyperEVMPermAllowHyperbeatTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](12);
        configs[0] = TokenGuardConfig({
            token: HYPEEVM_WHYPE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[1] = TokenGuardConfig({
            token: HYPEEVM_WSTHYPE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[2] = TokenGuardConfig({
            token: HYPEEVM_HYPERBEAT_VAULT_HYPE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[3] = TokenGuardConfig({
            token: HYPEREVM_UBTC,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[4] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_UBTC,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[5] = TokenGuardConfig({
            token: HYPEREVM_XAUT0,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[6] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_XUAT0,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[7] = TokenGuardConfig({
            token: HYPEREVM_USDT0,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[8] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[9] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[10] = TokenGuardConfig({
            token: HYPEREVM_UETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        configs[11] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        return configs;
    }

    function getHyperEVMPermBlockTokenModuleConfigs() internal pure returns (TokenModuleConfig[] memory) {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](10);

        configs[0] = TokenModuleConfig({token: HYPEEVM_HYPERBEAT_VAULT_HYPE, blockTransfer: true, blockApprove: true});
        configs[1] = TokenModuleConfig({token: HYPEREVM_UBTC, blockTransfer: true, blockApprove: true});
        configs[2] = TokenModuleConfig({token: HYPEREVM_HYPERBEAT_VAULT_UBTC, blockTransfer: true, blockApprove: true});
        configs[3] = TokenModuleConfig({token: HYPEREVM_XAUT0, blockTransfer: true, blockApprove: true});
        configs[4] = TokenModuleConfig({token: HYPEREVM_HYPERBEAT_VAULT_XUAT0, blockTransfer: true, blockApprove: true});
        configs[5] = TokenModuleConfig({token: HYPEREVM_USDT0, blockTransfer: true, blockApprove: true});
        configs[6] =
            TokenModuleConfig({token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0, blockTransfer: true, blockApprove: true});
        configs[7] =
            TokenModuleConfig({token: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE, blockTransfer: true, blockApprove: true});
        configs[8] = TokenModuleConfig({token: HYPEREVM_UETH, blockTransfer: true, blockApprove: true});
        configs[9] =
            TokenModuleConfig({token: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getHyperEVMPermBlockProtocolModuleConfig() internal pure returns (ProtocolModuleConfig[] memory) {
        ProtocolModuleConfig[] memory configs = new ProtocolModuleConfig[](6);

        configs[0] = ProtocolModuleConfig({target: HYPEEVM_HYPERBEAT_VAULT_HYPE, blockedSelectors: new bytes4[](1)});
        configs[0].blockedSelectors[0] = HyperbeatTokenizedAccount.requestRedeem.selector;

        configs[1] = ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_VAULT_UBTC, blockedSelectors: new bytes4[](1)});
        configs[1].blockedSelectors[0] = HyperbeatTokenizedAccount.requestRedeem.selector;

        configs[2] =
            ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_XUAT0, blockedSelectors: new bytes4[](2)});
        configs[2].blockedSelectors[0] = HyperbeatRedemptionVault.redeemInstant.selector;
        configs[2].blockedSelectors[1] = HyperbeatRedemptionVault.redeemRequest.selector;

        configs[3] =
            ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_USDT0, blockedSelectors: new bytes4[](2)});
        configs[3].blockedSelectors[0] = IERC4626.redeem.selector;
        configs[3].blockedSelectors[1] = IERC4626.withdraw.selector;

        configs[4] =
            ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_MEV_VAULT_HYPE, blockedSelectors: new bytes4[](2)});
        configs[4].blockedSelectors[0] = IERC4626.redeem.selector;
        configs[4].blockedSelectors[1] = IERC4626.withdraw.selector;

        configs[5] =
            ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_GAUNTLET_VAULT_UETH, blockedSelectors: new bytes4[](2)});
        configs[5].blockedSelectors[0] = IERC4626.redeem.selector;
        configs[5].blockedSelectors[1] = IERC4626.withdraw.selector;

        return configs;
    }

    function getKinetiqTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEREVM_KHYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getKinetiqHyperbeatLstProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_LST, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositVault.depositInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({
            target: HYPEEVM_HYPERBEAT_VAULT_REDEMPTION_LST,
            selectorStates: new SelectorState[](2)
        });
        configs[1].selectorStates[0] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[1].selectorStates[1] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemRequest.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getKinetiqHyperbeatLstTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEEVM_HYPERBEAT_VAULT_LST,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getEthereumEthenaExpansionJul25ProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE_24SEP2025, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_DEX_GHO_USDE_DEX_GHO,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getEthereumEthenaExpansionJul25TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](5);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_USDE_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[3] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_USDE_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        configs[4] = TokenGuardConfig({
            token: MAINNET_PENDLE_LP_SUSDE_24SEP2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatBeHYPEProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](3);

        configs[0] = ProtocolGuardConfig({
            target: HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_LIQUIDHYPE,
            selectorStates: new SelectorState[](1)
        });
        configs[0].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositVault.depositInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[1] = ProtocolGuardConfig({
            target: HYPEEVM_HYPERBEAT_VAULT_DEPOSIT_ADAPTER_LIQUIDHYPE,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositAdapter.depositInstantWithHype.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[2] = ProtocolGuardConfig({
            target: HYPEEVM_HYPERBEAT_VAULT_REDEMPTION_LIQUIDHYPE,
            selectorStates: new SelectorState[](2)
        });
        configs[2].selectorStates[0] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[2].selectorStates[1] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemRequest.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatBeHYPETokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEEVM_HYPERBEAT_VAULT_LIQUIDHYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatHyperUSDT0ProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_VAULT_HYPERUSDT0, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_VAULT_HYPERUSDT0, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: IERC4626.withdraw.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getEthFluidUsdeVaultsJul25ProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](4);

        configs[0] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_USDE_USDTB_DEX_USDT,
            selectorStates: new SelectorState[](1)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_USDE_USDTB_DEX_USDC,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_USDE_USDTB_DEX_GHO,
            selectorStates: new SelectorState[](1)
        });
        configs[2].selectorStates[0] =
            SelectorState({selector: IFluidVaultT2.operate.selector, state: RumpelGuard.AllowListState.ON});

        configs[3] = ProtocolGuardConfig({
            target: MAINNET_FLUID_VAULT_GHO_USDE_DEX_GHO_USDC,
            selectorStates: new SelectorState[](1)
        });
        configs[3].selectorStates[0] =
            SelectorState({selector: IFluidVaultT4.operate.selector, state: RumpelGuard.AllowListState.ON});
        return configs;
    }

    function getHyperevmHyperbeatHyperUSDT0TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);
        configs[0] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_HYPERUSDT0,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getEthFluidUsdeVaultsJul25TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);
        configs[0] = TokenGuardConfig({
            token: MAINNET_USDTB,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatBorrowAndMoreAug25ProtocolConfigs()
        internal
        pure
        returns (ProtocolGuardConfig[] memory)
    {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](10);

        // hyperbeat borrow hbHYPE-whype
        configs[0] = ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_BORROW, selectorStates: new SelectorState[](4)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IMorphoBase.supplyCollateral.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IMorphoBase.borrow.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[2] =
            SelectorState({selector: IMorphoBase.repay.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[3] =
            SelectorState({selector: IMorphoBase.withdrawCollateral.selector, state: RumpelGuard.AllowListState.ON});

        // kinetiq earn vault
        configs[1] =
            ProtocolGuardConfig({target: HYPEREVM_KINETIQ_EARN_VAULT_DEPOSIT, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] =
            SelectorState({selector: TellWithMultiAssetSupport.deposit.selector, state: RumpelGuard.AllowListState.ON});

        configs[2] =
            ProtocolGuardConfig({target: HYPEREVM_KINETIQ_EARN_WITHDRAW_QUEUE, selectorStates: new SelectorState[](1)});
        configs[2].selectorStates[0] = SelectorState({
            selector: BoringOnChainQueue.requestOnChainWithdraw.selector,
            state: RumpelGuard.AllowListState.ON
        });

        // pendle strats
        configs[3] = ProtocolGuardConfig({target: HYPEREVM_PENDLE_ROUTERV4, selectorStates: new SelectorState[](2)});
        configs[3].selectorStates[0] = SelectorState({
            selector: IPendleRouterV4.redeemDueInterestAndRewardsV2.selector,
            state: RumpelGuard.AllowListState.ON
        });

        configs[4] =
            ProtocolGuardConfig({target: HYPEREVM_PENDLE_SY_BEHYPE_29OCT2025, selectorStates: new SelectorState[](1)});
        configs[4].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[5] =
            ProtocolGuardConfig({target: HYPEREVM_PENDLE_SY_HBHYPE_17DEC2025, selectorStates: new SelectorState[](1)});
        configs[5].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[6] =
            ProtocolGuardConfig({target: HYPEREVM_PENDLE_SY_HBUSDT_17DEC2025, selectorStates: new SelectorState[](1)});
        configs[6].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        configs[7] =
            ProtocolGuardConfig({target: HYPEREVM_PENDLE_SY_KHYPE_12NOV2025, selectorStates: new SelectorState[](1)});
        configs[7].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        // hyperbeat usdt vault
        configs[8] =
            ProtocolGuardConfig({target: HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_USDT, selectorStates: new SelectorState[](1)});
        configs[8].selectorStates[0] = SelectorState({
            selector: HyperbeatDepositVault.depositInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[9] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_USDT,
            selectorStates: new SelectorState[](2)
        });
        configs[9].selectorStates[0] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemInstant.selector,
            state: RumpelGuard.AllowListState.ON
        });
        configs[9].selectorStates[1] = SelectorState({
            selector: HyperbeatRedemptionVault.redeemRequest.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatBorrowAndMoreAug25TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](10);

        // hyperbeat borrow hbHYPE-whype - hbHYPE already approved
        // intentionally no approvals

        // kinetiq earn vault
        configs[0] = TokenGuardConfig({
            token: HYPEREVM_KINETIQ_EARN_VAULT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // YTs
        configs[1] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_YT_BEHYPE_29OCT2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_YT_HBHYPE_17DEC2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[3] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_YT_HBUSDT_17DEC2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[4] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_YT_KHYPE_12NOV2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        // SYs
        configs[5] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_SY_BEHYPE_29OCT2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[6] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_SY_HBHYPE_17DEC2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[7] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_SY_HBUSDT_17DEC2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });
        configs[8] = TokenGuardConfig({
            token: HYPEREVM_PENDLE_SY_KHYPE_12NOV2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        // hyperbeat usdt vault
        configs[9] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_USDT,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18ProtocolConfigs()
        internal
        pure
        returns (ProtocolGuardConfig[] memory)
    {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE,
            selectorStates: new SelectorState[](2)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18ModuleTokenConfigs()
        internal
        pure
        returns (TokenModuleConfig[] memory)
    {
        TokenModuleConfig[] memory configs = new TokenModuleConfig[](1);

        configs[0] =
            TokenModuleConfig({token: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE, blockTransfer: true, blockApprove: true});

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18ModuleProtocolConfigs()
        internal
        pure
        returns (ProtocolModuleConfig[] memory)
    {
        ProtocolModuleConfig[] memory configs = new ProtocolModuleConfig[](1);

        configs[0] =
            ProtocolModuleConfig({target: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE, blockedSelectors: new bytes4[](2)});
        configs[0].blockedSelectors[0] = IERC4626.redeem.selector;
        configs[0].blockedSelectors[1] = IERC4626.withdraw.selector;

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18ModulePermTokenConfigs()
        internal
        pure
        returns (TokenGuardConfig[] memory)
    {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE,
            transferAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON,
            approveAllowState: RumpelGuard.AllowListState.PERMANENTLY_ON
        });

        return configs;
    }

    function getHyperevmHyperbeatHyperithmHypeAug18ModulePermProtocolConfigs()
        internal
        pure
        returns (ProtocolGuardConfig[] memory)
    {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_HYPERITHM_HYPE,
            selectorStates: new SelectorState[](2)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: IERC4626.deposit.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});
        configs[0].selectorStates[1] =
            SelectorState({selector: IERC4626.redeem.selector, state: RumpelGuard.AllowListState.PERMANENTLY_ON});

        return configs;
    }

    function getEthAllowEulTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: MAINNET_EUL,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });

        return configs;
    }

    function getHyperevmPendleClaimUpdateProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] = SelectorState({
            selector: IPendleRouterV4.redeemDueInterestAndRewardsV2.selector,
            state: RumpelGuard.AllowListState.OFF
        });

        configs[1] = ProtocolGuardConfig({target: MAINNET_PENDLE_ROUTERV4, selectorStates: new SelectorState[](1)});
        configs[1].selectorStates[0] = SelectorState({
            selector: ActionMiscV3_RumpelV2.redeemDueInterestAndRewardsV2.selector,
            state: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getEthereumEthenaExpansionSep15TokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](3);

        configs[0] = TokenGuardConfig({
            token: MAINNET_YT_USDE_26NOV2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[1] = TokenGuardConfig({
            token: MAINNET_YT_SUSDE_26NOV2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.OFF
        });
        configs[2] = TokenGuardConfig({
            token: MAINNET_SY_SUSDE_26NOV2025,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }

    function getEthereumEthenaExpansionSep15ProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](1);

        configs[0] = ProtocolGuardConfig({target: MAINNET_SY_SUSDE_26NOV2025, selectorStates: new SelectorState[](1)});
        configs[0].selectorStates[0] =
            SelectorState({selector: IStandardizedYield.redeem.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHyperevmBeHypeProtocolConfigs() internal pure returns (ProtocolGuardConfig[] memory) {
        ProtocolGuardConfig[] memory configs = new ProtocolGuardConfig[](2);

        configs[0] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_DEPOSIT_BEHYPE,
            selectorStates: new SelectorState[](1)
        });
        configs[0].selectorStates[0] =
            SelectorState({selector: StakingCore.stake.selector, state: RumpelGuard.AllowListState.ON});

        configs[1] = ProtocolGuardConfig({
            target: HYPEREVM_HYPERBEAT_VAULT_REDEMPTION_BEHYPE,
            selectorStates: new SelectorState[](1)
        });
        configs[1].selectorStates[0] =
            SelectorState({selector: WithdrawManager.withdraw.selector, state: RumpelGuard.AllowListState.ON});

        return configs;
    }

    function getHyperevmBeHypeTokenConfigs() internal pure returns (TokenGuardConfig[] memory) {
        TokenGuardConfig[] memory configs = new TokenGuardConfig[](1);

        configs[0] = TokenGuardConfig({
            token: HYPEREVM_HYPERBEAT_BEHYPE,
            transferAllowState: RumpelGuard.AllowListState.ON,
            approveAllowState: RumpelGuard.AllowListState.ON
        });

        return configs;
    }
}

interface IKernelMerkleDistributor {
    function claim(uint256 index, address account, uint256 cumulativeAmount, bytes32[] calldata merkleProof) external;
    function claimAndStake(uint256 index, address account, uint256 cumulativeAmount, bytes32[] calldata merkleProof)
        external;
}

interface IMorphoBundler {
    function multicall(bytes[] memory data) external;
}

struct MarketParams {
    address loanToken;
    address collateralToken;
    address oracle;
    address irm;
    uint256 lltv;
}

interface IMorphoBase {
    function setAuthorization(address authorized, bool newIsAuthorized) external;
    function borrow(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    ) external returns (uint256 assetsBorrowed, uint256 sharesBorrowed);

    function repay(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        bytes memory data
    ) external returns (uint256 assetsRepaid, uint256 sharesRepaid);

    function supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data)
        external;

    function withdrawCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver)
        external;
}

interface IMorphoDistributor {
    function claim(address account, address reward, uint256 claimable, bytes32[] calldata proof) external;
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

interface IFluidVaultT2 {
    function operate(
        uint256 nftId_,
        int256 newCol1_,
        int256 newCol2_,
        int256 colSharesMinMax_,
        int256 newDebt_,
        address to_
    ) external;
}

interface IFluidVaultT3 {
    function operate(
        uint256 nftId_,
        int256 newCol_,
        int256 newDebtToken0,
        int256 newDebtToken1_,
        int256 debtSharesMinMax_,
        address to_
    ) external;
}

interface IFluidVaultT4 {
    function operate(
        uint256 nftId_,
        int256 newColToken0_,
        int256 newColToken1_,
        int256 colSharesMinMax_,
        int256 newDebtToken0_,
        int256 newDebtToken1_,
        int256 debtSharesMinMax_,
        address to_
    ) external payable;
}

interface IFluidVaultFactory {
    function safeTransferFrom(address from_, address to_, uint256 id_, bytes calldata data_) external;
    function transferFrom(address from_, address to_, uint256 id_) external;
}

interface IFluidVaultFactory_ {
    function safeTransferFrom(address from_, address to_, uint256 id_) external;
}

interface FluidMerkleDistributor {
    struct Claim {
        address recipient;
        uint256 cumulativeAmount;
        uint8 positionType;
        bytes32 positionId;
        uint256 cycle;
        bytes32[] merkleProof;
        bytes metadata;
    }

    function claim(
        address recipient,
        uint256 cumulativeAmount,
        uint8 positionType,
        bytes32 positionId,
        uint256 cycle,
        bytes32[] calldata merkleProof,
        bytes calldata metadata
    ) external;

    function bulkClaim(Claim[] calldata claims_) external;
}

interface IObolClaim {
    struct SignatureParams {
        uint256 nonce;
        uint256 expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function claimAndDelegate(
        bytes16 campaignId,
        bytes32[] memory proof,
        uint256 claimAmount,
        address delegatee,
        SignatureParams memory delegationSignature
    ) external payable;
}

interface IObolLockups {
    function unlock(uint256) external;
}

// @dev actually a function in ActionMiscV3 called through the RouterProxy
// @dev contract uses a diamond proxy pattern, so functions are found across many contracts but
// are combined into one here for simplicity
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

    // live in IPLimitRouter
    enum OrderType {
        SY_FOR_PT,
        PT_FOR_SY,
        SY_FOR_YT,
        YT_FOR_SY
    }

    struct Order {
        uint256 salt;
        uint256 expiry;
        uint256 nonce;
        OrderType orderType;
        address token;
        address YT;
        address maker;
        address receiver;
        uint256 makingAmount;
        uint256 lnImpliedRate;
        uint256 failSafeRate;
        bytes permit;
    }

    struct FillOrderParams {
        Order order;
        bytes signature;
        uint256 makingAmount;
    }

    // live in IPAllActionTypeV3
    struct TokenInput {
        address tokenIn;
        uint256 netTokenIn;
        address tokenMintSy;
        address pendleSwap;
        SwapData swapData;
    }

    struct TokenOutput {
        address tokenOut;
        uint256 minTokenOut;
        address tokenRedeemSy;
        address pendleSwap;
        SwapData swapData;
    }

    struct LimitOrderData {
        address limitRouter;
        uint256 epsSkipMarket;
        FillOrderParams[] normalFills;
        FillOrderParams[] flashFills;
        bytes optData;
    }

    struct ApproxParams {
        uint256 guessMin;
        uint256 guessMax;
        uint256 guessOffchain;
        uint256 maxIteration;
        uint256 eps;
    }

    struct ExitPreExpReturnParams {
        uint256 netPtFromRemove;
        uint256 netSyFromRemove;
        uint256 netPyRedeem;
        uint256 netSyFromRedeem;
        uint256 netPtSwap;
        uint256 netYtSwap;
        uint256 netSyFromSwap;
        uint256 netSyFee;
        uint256 totalSyOut;
    }

    // lives in ActionAddRemoveLiqV3
    function addLiquiditySingleToken(
        address receiver,
        address market,
        uint256 minLpOut,
        ApproxParams calldata guessPtReceivedFromSy,
        TokenInput calldata input,
        LimitOrderData calldata limit
    ) external payable returns (uint256 netLpOut, uint256 netSyFee, uint256 netSyInterm) {}

    // lives in ActionAddRemoveLiqV3
    function addLiquiditySingleTokenKeepYt(
        address receiver,
        address market,
        uint256 minLpOut,
        uint256 minYtOut,
        TokenInput calldata input
    ) external payable returns (uint256 netLpOut, uint256 netYtOut, uint256 netSyMintPy, uint256 netSyInterm) {}

    // lives in ActionAddRemoveLiqV3
    function removeLiquiditySingleToken(
        address receiver,
        address market,
        uint256 netLpToRemove,
        TokenOutput calldata output,
        LimitOrderData calldata limit
    ) external returns (uint256 netTokenOut, uint256 netSyFee, uint256 netSyInterm) {}

    // lives in  IPActionMiscV3
    // used for withdraw and claim rewards combined
    struct Call3 {
        bool allowFailure;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    // lives in ActionMiscV3
    // used for withdraw and claim rewards combined
    function multicall(Call3[] calldata calls) external payable returns (Result[] memory res) {}

    // lives in ActionMiscV3
    // used for transferring LP position to separate pool
    function callAndReflect(
        address payable reflector,
        bytes calldata selfCall1,
        bytes calldata selfCall2,
        bytes calldata reflectCall
    ) external payable returns (bytes memory selfRes1, bytes memory selfRes2, bytes memory reflectRes) {}
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

interface PayableMulticall {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

interface MerklDistributor {
    function claim(
        address[] calldata users,
        address[] calldata tokens,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external;
}

// vePendle
interface IPVotingEscrowMainchain {
    function increaseLockPosition(uint128 additionalAmountToLock, uint128 expiry) external returns (uint128);

    function withdraw() external returns (uint128);
}

contract SentimentPositionManager {
    enum Operation {
        NewPosition, // create2 a new position with a given type, no auth needed
        // the following operations require msg.sender to be authorized
        Exec, // execute arbitrary calldata on a position
        Deposit, // Add collateral to a given position
        Transfer, // transfer assets from the position to a external address
        Approve, // allow a spender to transfer assets from a position
        Repay, // decrease position debt
        Borrow, // increase position debt
        AddToken, // upsert collateral asset to position storage
        RemoveToken // remove collateral asset from position storage

    }

    struct Action {
        // operation type
        Operation op; // dynamic bytes data, interepreted differently across operation types
        bytes data;
    }

    function process(address position, Action calldata action) external {}
    function processBatch(address position, Action[] calldata actions) external {}
}

interface IERC6909 {
    function transfer(address receiver, uint256 id, uint256 amount) external returns (bool);
}

interface HyperbeatTokenizedAccount {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function requestRedeem(uint256 shares, address receiverAddr, address holderAddr) external;
}

interface HyperbeatDepositVault {
    function depositInstant(address tokenIn, uint256 amountToken, uint256 minReceiveAmount, bytes32 referrerId)
        external;
}

interface HyperbeatRedemptionVault {
    function redeemInstant(address tokenOut, uint256 amountMTokenIn, uint256 minReceiveAmount) external;

    function redeemRequest(address tokenOut, uint256 amountMTokenIn) external returns (uint256);
}

interface LiquityStabilityPool {
    function provideToSP(uint256 _amount, bool _doClaim) external;
    function withdrawFromSP(uint256 _amount, bool doClaim) external;
    // Sends all stashed collateral gains to the caller and zeros their stashed balance.
    // Used only when the caller has no current deposit yet has stashed collateral gains from the past.
    function claimAllCollGains() external;
}

interface HyperbeatDepositAdapter {
    function depositInstantWithHype(address tokenIn, uint256 amountToken, uint256 minReceiveAmount, bytes32 referrerId)
        external
        payable
        returns (uint256);
}

// Kinetiq Earn
interface TellWithMultiAssetSupport {
    function deposit(ERC20 depositAsset, uint256 depositAmount, uint256 minimumMint)
        external
        payable
        returns (uint256 shares);
}

// Kinetiq Earn withdraw queue
interface BoringOnChainQueue {
    function requestOnChainWithdraw(address assetOut, uint128 amountOfShares, uint16 discount, uint24 secondsToDeadline)
        external
        returns (bytes32 requestId);
}

// behype withdrawals
interface WithdrawManager {
    function withdraw(uint256 beHypeAmount, bool instant, uint256 minAmountOut)
        external
        returns (uint256 withdrawalId);
}

// behype staking
interface StakingCore {
    function stake(string memory communityCode) external payable;
}
