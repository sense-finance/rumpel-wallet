import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {PointTokenVault, LibString} from "point-tokenization-vault/PointTokenVault.sol";

interface IUniswapV3Pool {
    function initialize(uint160 sqrtPriceX96) external;
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

interface IUniswapV3Factory {
    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
}

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)
        external
        payable
        returns (address pool);
}

contract DummyErc20 is ERC20 {
    address immutable admin;

    constructor(address _admin, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        admin = _admin;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "Only Admin Can Mint");
        _mint(to, amount);
    }
}

contract SimpleSeed is Script {
    RumpelWalletFactory walletFactory = RumpelWalletFactory(0x4d67eC37cbBf6AAEbf27d8816D0424D255E77Dc4);
    PointTokenVault pointTokenVault = PointTokenVault(payable(0xaB91B4666a0A8F3D35BeefF0492A9a0b2821FC5e));

    IUniswapV3Factory uniV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    INonfungiblePositionManager positionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

    address adminAddr;
    uint256 adminPk;
    address userAddr;
    uint256 userPk;

    DummyErc20 weth;
    DummyErc20[] underlyingTokens;
    DummyErc20[] pTokens;
    mapping(DummyErc20 pToken => IUniswapV3Pool pool) pools;

    uint256[] initialPrices = [5e16, 1e17, 2e18];

    string mnemonic = vm.envString("MNEMONIC");

    function run() public {
        (adminAddr, adminPk) = deriveRememberKey(mnemonic, 0);
        (userAddr, userPk) = deriveRememberKey(mnemonic, 1);

        createWeth();
        createUnderlyingTokens();
        createPTokens();
        createPools();

        mintLiquidity(userAddr, userPk, pTokens[0]);
        mintLiquidity(userAddr, userPk, pTokens[1]);
        mintLiquidity(userAddr, userPk, pTokens[2]);
    }

    function createWeth() internal {
        vm.startBroadcast(adminPk);
        weth = new DummyErc20(adminAddr, "wrapped eth", "WETH");
        weth.mint(userAddr, 1000e18);
        vm.stopBroadcast();
    }

    function createUnderlyingTokens() internal {
        vm.startBroadcast(adminPk);
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying A", "UNDER_A"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying B", "UNDER_B"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying C", "UNDER_C"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying D", "UNDER_D"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying E", "UNDER_E"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying F", "UNDER_F"));
        underlyingTokens.push(new DummyErc20(adminAddr, "Underlying G", "UNDER_G"));
        vm.stopBroadcast();
    }

    function createPTokens() internal {
        vm.startBroadcast(adminPk);
        pTokens.push(DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("A Point", "pA"))));
        pTokens.push(DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("B Point", "pB"))));
        pTokens.push(DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("C Point", "pC"))));
        vm.stopBroadcast();
    }

    function createPools() internal {
        vm.startBroadcast(adminPk);
        address token0;
        address token1;
        for (uint256 i = 0; i < pTokens.length; i++) {
            (token0, token1) = _getOrderedTokens(address(weth), address(pTokens[i]));
            pools[pTokens[i]] = IUniswapV3Pool(
                positionManager.createAndInitializePoolIfNecessary(
                    token0, token1, 10000, _calculateSqrtPriceX96(initialPrices[i], 18, 18)
                )
            );
        }
        vm.stopBroadcast();
    }

    function mintLiquidity(address user, uint256 userPk, DummyErc20 pToken) internal {
        vm.startBroadcast(userPk);
        weth.approve(address(positionManager), 10e18);

        (, int24 tick,,,,,) = IUniswapV3Pool(pools[pToken]).slot0();

        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;

        address token0 = address(pToken) < address(weth) ? address(pToken) : address(weth);
        address token1 = address(pToken) > address(weth) ? address(pToken) : address(weth);

        if (token0 == address(weth)) {
            amount0Desired = 10e18;
            amount1Desired = 0;
            tickLower = (tick / 200 + 1) * 200;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;
        } else {
            amount0Desired = 0;
            amount1Desired = 10e18;
            tickLower = (tick / 200 - 1) * 200 - 200 * 10;
            tickUpper = (tick / 200 - 1) * 200;
        }

        INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: 10000,
            tickLower: tickLower,
            tickUpper: tickUpper,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: user,
            deadline: 1823444259
        });
        positionManager.mint(mintParams);
        vm.stopBroadcast();
    }

    // internal helpers
    function _getOrderedTokens(address firstParam, address secondParam)
        internal
        returns (address token0, address token1)
    {
        token0 = firstParam < secondParam ? firstParam : secondParam;
        token1 = firstParam > secondParam ? firstParam : secondParam;
        return (token0, token1);
    }

    function _calculateSqrtPriceX96(uint256 price, uint8 decimals0, uint8 decimals1) internal pure returns (uint160) {
        require(price > 0, "Price must be greater than zero");

        // Adjust the price for decimal differences
        if (decimals0 > decimals1) {
            price = price * (10 ** (decimals0 - decimals1));
        } else if (decimals1 > decimals0) {
            price = price / (10 ** (decimals1 - decimals0));
        }

        // Calculate the square root of the price
        uint256 sqrtPrice = _sqrt(price * (1e18));

        // Scale by 2^96
        uint256 sqrtPriceX96 = sqrtPrice * (2 ** 96) / (1e18);

        require(sqrtPriceX96 <= type(uint160).max, "sqrtPriceX96 overflow");
        return uint160(sqrtPriceX96);
    }

    function _sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
