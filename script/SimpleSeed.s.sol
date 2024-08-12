import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
    IUniswapV3Factory uniV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    INonfungiblePositionManager positionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

    // pool
    // 0x597a1b0515bbeee6796b89a6f403c3fd41bb626c

    address adminAddr;
    uint256 adminPk;
    address userAddr;
    uint256 userPk;

    function run() public {
        string memory mnemonic = vm.envString("MNEMONIC");

        (adminAddr, adminPk) = deriveRememberKey(mnemonic, 0);
        (userAddr, userPk) = deriveRememberKey(mnemonic, 1);

        console.log(adminAddr);
        console.log(userAddr);

        vm.startBroadcast(adminPk);
        DummyErc20 pointToken = new DummyErc20(adminAddr, "pToken", "PT");
        DummyErc20 weth = new DummyErc20(adminAddr, "wrapped eth", "WETH");

        // pointToken.mint(userAddr, 1000e18);
        weth.mint(userAddr, 1000e18);
        vm.stopBroadcast();

        vm.startBroadcast(userPk);
        // pointToken.approve(address(positionManager), 10e18);
        weth.approve(address(positionManager), 10e18);

        if (weth < pointToken) {
            console.log("token0 is weth");
        }

        address token0 = address(pointToken) < address(weth) ? address(pointToken) : address(weth);
        address token1 = address(pointToken) > address(weth) ? address(pointToken) : address(weth);

        address pool =
            positionManager.createAndInitializePoolIfNecessary(token0, token1, 10000, 19235392466017147155797619338978);

        (uint160 sqrtPriceX96, int24 tick,,,, uint8 feeProtocol,) = IUniswapV3Pool(pool).slot0();

        console.logInt(tick);
        console.log(sqrtPriceX96);

        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;

        if (token0 == address(weth)) {
            console.log("here");
            amount0Desired = 10e18;
            amount1Desired = 0;
            tickLower = (tick / 200 + 1) * 200;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;
        } else {
            console.log("there");
            amount0Desired = 0;
            amount1Desired = 10e18;
            tickLower = (tick / 200) * 200 - 200 * 10;
            tickUpper = (tick / 200) * 200;
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
            recipient: userAddr,
            deadline: 1823444259
        });
        positionManager.mint(mintParams);

        console.log("start");
        console.logInt(tick);
        console.log(sqrtPriceX96);
        console.log(weth.balanceOf(userAddr));
        console.log(pointToken.balanceOf(userAddr));
        console.log('"token0":', token0);
        console.log('"token1":', token1);
        console.log('"fee":', 10000);
        console.log('"tickLower":');
        console.logInt(tickLower);
        console.log('"tickUpper":');
        console.logInt(tickUpper);
        console.log('"amount0Desired":', amount0Desired);
        console.log('"amount1Desired":', amount1Desired);
        console.log('"amount0Min":', amount0Desired);
        console.log('"amount1Min":', amount1Desired);
        console.log('"recipient":', userAddr);
        console.log('"deadline":', 1823444259);

        vm.stopBroadcast();
    }
    // address pool = uniV3Factory.createPool(address(pointToken), address(weth), 10000);

    // uint256 price;
    // if (address(pointToken) < address(weth)) {
    //     price = 5e16;
    // } else {
    //     price = 1e18 * 1e18 / 5e16;
    // }
    // IUniswapV3Pool(pool).initialize(calculateSqrtPriceX96(price, 18, 18));
    // console.log("pool:", pool);
    // vm.stopBroadcast();

    // vm.startBroadcast(userPk);
    // pointToken.approve(address(positionManager), 10e18);
    // weth.approve(address(positionManager), 10e18);
    // address token0 = address(pointToken) < address(weth) ? address(pointToken) : address(weth);
    // address token1 = address(pointToken) > address(weth) ? address(pointToken) : address(weth);

    // (uint160 sqrtPriceX96, int24 tick,,,, uint8 feeProtocol,) = IUniswapV3Pool(pool).slot0();

    // console.log(sqrtPriceX96);

    // int24 tickLower;
    // int24 tickUpper;
    // uint256 amount0Desired;
    // uint256 amount1Desired;
    // if (token0 == address(weth)) {
    //     console.log("here");
    //     amount0Desired = 10e18;
    //     amount1Desired = 0;
    //     tickLower = tick - 200 * 10;
    //     tickUpper = tick;
    // } else {
    //     console.log("there");
    //     amount0Desired = 0;
    //     amount1Desired = 10e18;
    //     tickLower = tick;
    //     tickUpper = tick + 200 * 10;
    // }

    // INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams({
    //     token0: token0,
    //     token1: token1,
    //     fee: 10000,
    //     tickLower: tickLower,
    //     tickUpper: tickUpper,
    //     amount0Desired: amount0Desired,
    //     amount1Desired: amount1Desired,
    //     amount0Min: amount0Desired,
    //     amount1Min: amount1Desired,
    //     recipient: userAddr,
    //     deadline: 1823444259
    // });

    // console.log('"token0":', token0);
    // console.log('"token1":', token1);
    // console.log('"fee":', 10000);
    // console.log('"tickLower":');
    // console.logInt(tickLower);
    // console.log('"tickUpper":');
    // console.logInt(tickUpper);
    // console.log('"amount0Desired":', amount0Desired);
    // console.log('"amount1Desired":', amount1Desired);
    // console.log('"amount0Min":', amount0Desired);
    // console.log('"amount1Min":', amount1Desired);
    // console.log('"recipient":', userAddr);
    // console.log('"deadline":', 1823444259);

    // vm.stopBroadcast();

    // internal helpers
    function calculateSqrtPriceX96(uint256 price, uint8 decimals0, uint8 decimals1) internal pure returns (uint160) {
        require(price > 0, "Price must be greater than zero");

        // Adjust the price for decimal differences
        if (decimals0 > decimals1) {
            price = price * (10 ** (decimals0 - decimals1));
        } else if (decimals1 > decimals0) {
            price = price / (10 ** (decimals1 - decimals0));
        }

        // Calculate the square root of the price
        uint256 sqrtPrice = sqrt(price * (1e18));

        // Scale by 2^96
        uint256 sqrtPriceX96 = sqrtPrice * (2 ** 96) / (1e18);

        require(sqrtPriceX96 <= type(uint160).max, "sqrtPriceX96 overflow");
        return uint160(sqrtPriceX96);
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
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
