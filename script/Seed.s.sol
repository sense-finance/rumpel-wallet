pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {PointTokenVault, LibString} from "point-tokenization-vault/PointTokenVault.sol";

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

contract Seed is Script {
    // contract dependencies
    IUniswapV3Factory uniV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    RumpelWalletFactory walletFactory = RumpelWalletFactory(0x4d67eC37cbBf6AAEbf27d8816D0424D255E77Dc4);
    PointTokenVault pointTokenVault = PointTokenVault(payable(0xaB91B4666a0A8F3D35BeefF0492A9a0b2821FC5e));
    INonfungiblePositionManager positionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);
    DummyErc20 weth;

    // addresses and users
    struct User {
        address addr;
        uint256 pk;
    }

    string mnemonic = vm.envString("MNEMONIC");
    address adminAddr;
    uint256 adminPk;
    User[] users;

    // init configs
    uint256[] initialPrices = [2e16, 5e16, 1e17, 5e17, 7e17, 2e18, 4e18];

    function run() public {
        defineUsers();
        createWallets();

        weth = new DummyErc20(adminAddr, "Wrapped Ethereum", "WETH");
        DummyErc20[] memory wethArray = new DummyErc20[](1);
        wethArray[0] = weth;
        mintTokens(wethArray);

        DummyErc20[] memory tokens = createTokens();
        mintTokens(tokens);

        DummyErc20[] memory pTokens = deployPTokens(tokens);
        address[] memory pools = createPools(pTokens);

        seedPools(pTokens, pools);
    }

    function defineUsers() public {
        (adminAddr, adminPk) = deriveRememberKey(mnemonic, 0);

        for (uint32 i = 1; i < 11; i++) {
            (address _user, uint256 _pk) = deriveRememberKey(mnemonic, i);
            users.push(User(_user, _pk));
        }
    }

    function createWallets() public {
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address[] memory owners = new address[](1);

        for (uint32 i = 0; i < users.length; i++) {
            owners[0] = users[i].addr;
            vm.startBroadcast(users[i].pk);
            address wallet = walletFactory.createWallet(owners, 1, initCalls);
            vm.stopBroadcast();

            console.log(users[i].addr, ",", wallet);
        }
    }

    function createTokens() public returns (DummyErc20[] memory) {
        vm.startBroadcast(adminPk);
        DummyErc20[] memory tokens = new DummyErc20[](7);
        tokens[0] = new DummyErc20(adminAddr, "Token A", "A");
        tokens[1] = new DummyErc20(adminAddr, "Token B", "B");
        tokens[2] = new DummyErc20(adminAddr, "Token C", "C");
        tokens[3] = new DummyErc20(adminAddr, "Token D", "D");
        tokens[4] = new DummyErc20(adminAddr, "Token E", "E");
        tokens[5] = new DummyErc20(adminAddr, "Token F", "F");
        tokens[6] = new DummyErc20(adminAddr, "Token G", "G");
        vm.stopBroadcast();

        console.log("\nToken Addresses");
        for (uint256 i = 0; i < tokens.length; i++) {
            console.log(address(tokens[i]));
        }

        return tokens;
    }

    function mintTokens(DummyErc20[] memory tokens) public {
        console.log("\nToken Balances");
        vm.startBroadcast(adminPk);
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = 0; j < users.length; j++) {
                tokens[i].mint(users[j].addr, 10_000e18);
                console.log(tokens[i].symbol(), users[j].addr, tokens[i].balanceOf(users[j].addr));
            }
        }
        vm.stopBroadcast();
    }

    function deployPTokens(DummyErc20[] memory tokens) public returns (DummyErc20[] memory) {
        vm.startBroadcast(adminPk);
        DummyErc20[] memory pTokens = new DummyErc20[](tokens.length);

        console.log("\npTokens:");
        for (uint256 i = 0; i < tokens.length; i++) {
            string memory name = tokens[i].name();
            string memory symbol = tokens[i].symbol();

            bytes32 tokenPointId = LibString.packTwo(string.concat(name, " Point"), string.concat("p", symbol));
            pTokens[i] = DummyErc20(pointTokenVault.deployPToken(tokenPointId));
            console.log(name, "pToken", address(pTokens[i]));
        }

        vm.stopBroadcast();

        return pTokens;
    }

    function createPools(DummyErc20[] memory pTokens) public returns (address[] memory) {
        vm.startBroadcast(adminPk);
        address[] memory pools = new address[](pTokens.length);

        console.log("\nPools:");
        for (uint256 i = 0; i < pTokens.length; i++) {
            string memory name = pTokens[i].name();
            // pools[i] = uniV3Factory.createPool(address(pTokens[i]), address(weth), 10000);

            // // price is the exchange from token 0 to token 1
            // // Token 1 / Token 0
            // // amount of token 1 traded for a single token 0
            // // uint256 price;
            // // if (address(pTokens[i]) < address(weth)) {
            // //     price = initialPrices[i];
            // // } else {
            // //     price = 1e18 * 1e18 / initialPrices[i];
            // // }
            // IUniswapV3Pool(pools[i]).initialize(19235392466017147155797619338978);

            address token0 = address(pTokens[i]) < address(weth) ? address(pTokens[i]) : address(weth);
            address token1 = address(pTokens[i]) > address(weth) ? address(pTokens[i]) : address(weth);

            pools[i] = positionManager.createAndInitializePoolIfNecessary(
                token0, token1, 10000, 19235392466017147155797619338978
            );

            console.log(name, "pool:", pools[i], 19235392466017147155797619338978);
        }

        vm.stopBroadcast();

        return pools;
    }

    function seedPools(DummyErc20[] memory pTokens, address[] memory pools) public {
        console.log("seed pools");
        vm.startBroadcast(users[0].pk);

        console.log(weth.balanceOf(users[0].addr));
        console.log(pTokens[0].symbol());
        console.log(pTokens[0].balanceOf(users[0].addr));
        console.log(users[0].addr);

        weth.approve(address(positionManager), 1000e18);

        uint256 i = 0;
        address token0 = address(pTokens[i]) < address(weth) ? address(pTokens[i]) : address(weth);
        address token1 = address(pTokens[i]) > address(weth) ? address(pTokens[i]) : address(weth);

        (uint160 sqrtPriceX96, int24 tick,,,, uint8 feeProtocol,) = IUniswapV3Pool(pools[i]).slot0();

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
            recipient: users[0].addr,
            deadline: 1823444259
        });

        console.log("start");
        console.logInt(tick);
        console.log(sqrtPriceX96);
        console.log(weth.balanceOf(users[0].addr));
        console.log(pTokens[i].balanceOf(users[0].addr));
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
        console.log('"recipient":', users[0].addr);
        console.log('"deadline":', 1823444259);

        positionManager.mint(mintParams);
        vm.stopBroadcast();
    }

    // internal helpers
    function calculateSqrtPriceX96(uint256 price, uint8 decimals0, uint8 decimals1) public pure returns (uint160) {
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
