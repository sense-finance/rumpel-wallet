// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {RumpelGuard} from "../src/RumpelGuard.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

struct ProtocolConfig {
    address target;
    bytes4[] allowedSelectors;
}

struct TokenConfig {
    address token;
    bool allowTransfer;
    bool allowApprove;
}

library RumpelGuardConfig {
    // Protocols
    address public constant MAINNET_MORPHO_BUNDLER = 0x4095F064B8d3c3548A3bebfd0Bbfd04750E30077;
    address public constant MAINNET_ZIRCUIT_RESTAKING_POOL = 0xF047ab4c75cebf0eB9ed34Ae2c186f3611aEAfa6;
    address public constant MAINNET_SYMBIOTIC_WSTETH_COLLATERAL = 0x32296969EEF7ebd568736EA78d659b803322fb01;
    address public constant MAINNET_KARAK_VAULT_SUPERVISOR = 0x54e44DbB92dBA848ACe27F44c0CB4268981eF1CC;

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

    function setupProtocols(RumpelGuard rumpelGuard) internal {
        ProtocolConfig[] memory protocols = getProtocolConfigs();
        for (uint256 i = 0; i < protocols.length; i++) {
            ProtocolConfig memory config = protocols[i];
            for (uint256 j = 0; j < config.allowedSelectors.length; j++) {
                rumpelGuard.setCallAllowed(config.target, config.allowedSelectors[j], RumpelGuard.AllowListState.ON);
            }
        }
    }

    function setupTokens(RumpelGuard rumpelGuard) internal {
        TokenConfig[] memory tokens = getTokenConfigs();
        for (uint256 i = 0; i < tokens.length; i++) {
            TokenConfig memory config = tokens[i];
            if (config.allowTransfer) {
                rumpelGuard.setCallAllowed(config.token, ERC20.transfer.selector, RumpelGuard.AllowListState.ON);
            }
            if (config.allowApprove) {
                rumpelGuard.setCallAllowed(config.token, ERC20.approve.selector, RumpelGuard.AllowListState.ON);
            }
        }
    }

    function getProtocolConfigs() internal pure returns (ProtocolConfig[] memory) {
        ProtocolConfig[] memory configs = new ProtocolConfig[](7);

        // Morpho Bundler (supply, withdraw, borrow, repay)
        configs[0] = ProtocolConfig({target: MAINNET_MORPHO_BUNDLER, allowedSelectors: new bytes4[](1)});
        configs[0].allowedSelectors[0] = IMorphoBundler.multicall.selector;

        // Zircuit Restaking Pool
        configs[1] = ProtocolConfig({target: MAINNET_ZIRCUIT_RESTAKING_POOL, allowedSelectors: new bytes4[](2)});
        configs[1].allowedSelectors[0] = IZircuitRestakingPool.depositFor.selector;
        configs[1].allowedSelectors[1] = IZircuitRestakingPool.withdraw.selector;

        // Symbiotic WstETH Collateral
        configs[2] = ProtocolConfig({target: MAINNET_SYMBIOTIC_WSTETH_COLLATERAL, allowedSelectors: new bytes4[](2)});
        configs[2].allowedSelectors[0] = ISymbioticWstETHCollateral.deposit.selector;
        configs[2].allowedSelectors[1] = ISymbioticWstETHCollateral.withdraw.selector;

        // Karak Vault Supervisor
        configs[3] = ProtocolConfig({target: MAINNET_KARAK_VAULT_SUPERVISOR, allowedSelectors: new bytes4[](3)});
        configs[3].allowedSelectors[0] = IKarakVaultSupervisor.deposit.selector;
        configs[3].allowedSelectors[1] = IKarakVaultSupervisor.gimmieShares.selector;
        configs[3].allowedSelectors[2] = IKarakVaultSupervisor.returnShares.selector;

        // Mellow Ethena LRT Vault sUSDe
        configs[4] = ProtocolConfig({target: MAINNET_RSUSDE, allowedSelectors: new bytes4[](2)});
        configs[4].allowedSelectors[0] = IMellow.deposit.selector;
        configs[4].allowedSelectors[1] = IMellow.registerWithdrawal.selector;

        // KELP Airdrop Gain Vault
        configs[5] = ProtocolConfig({target: MAINNET_AGETH, allowedSelectors: new bytes4[](4)});
        configs[5].allowedSelectors[0] = IEIP4626.deposit.selector;
        configs[5].allowedSelectors[1] = IEIP4626.mint.selector;
        configs[5].allowedSelectors[2] = IEIP4626.withdraw.selector;
        configs[5].allowedSelectors[3] = IEIP4626.redeem.selector;

        // Ethena Staking
        configs[6] = ProtocolConfig({target: MAINNET_SUSDE, allowedSelectors: new bytes4[](3)});
        configs[6].allowedSelectors[0] = IEThenaStaking.unstake.selector;
        configs[6].allowedSelectors[1] = IEThenaStaking.cooldownAssets.selector;
        configs[6].allowedSelectors[2] = IEThenaStaking.cooldownShares.selector;

        return configs;
    }

    function getTokenConfigs() internal pure returns (TokenConfig[] memory) {
        TokenConfig[] memory configs = new TokenConfig[](9);

        configs[0] = TokenConfig({token: MAINNET_SUSDE, allowTransfer: true, allowApprove: true});
        configs[1] = TokenConfig({token: MAINNET_USDE, allowTransfer: true, allowApprove: true});
        configs[2] = TokenConfig({token: MAINNET_WSTETH, allowTransfer: true, allowApprove: true});
        configs[3] = TokenConfig({token: MAINNET_KUSDE, allowTransfer: true, allowApprove: true});
        configs[4] = TokenConfig({token: MAINNET_KWEETH, allowTransfer: true, allowApprove: true});
        configs[5] = TokenConfig({token: MAINNET_WEETH, allowTransfer: true, allowApprove: true});
        configs[6] = TokenConfig({token: MAINNET_MSTETH, allowTransfer: true, allowApprove: true});
        configs[7] = TokenConfig({token: MAINNET_RSUSDE, allowTransfer: true, allowApprove: true});
        configs[8] = TokenConfig({token: MAINNET_AGETH, allowTransfer: true, allowApprove: true});

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

interface IEIP4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256);
    function mint(uint256 shares, address receiver) external returns (uint256);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256);
}

interface IEThenaStaking {
    function unstake(address receiver) external;
    function cooldownAssets(uint256 assets) external returns (uint256 shares);
    function cooldownShares(uint256 shares) external returns (uint256 assets);
}

interface IKarakVaultSupervisor {
    function deposit(address vault, uint256 amount, uint256 minSharesOut) external;
    function gimmieShares(address vault, uint256 shares) external;
    function returnShares(address vault, uint256 shares) external;
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
