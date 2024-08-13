import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RumpelWalletFactory} from "../src/RumpelWalletFactory.sol";
import {RumpelGuard} from "../src/RumpelGuard.sol";
import {InitializationScript} from "../src/InitializationScript.sol";
import {PointTokenVault, LibString} from "point-tokenization-vault/PointTokenVault.sol";
import {ISafe, Enum} from "../src/interfaces/external/ISafe.sol";

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
    RumpelGuard guard = RumpelGuard(0x05959a76DF690Dc3423A7c71C90Bb810E4932754);
    PointTokenVault pointTokenVault = PointTokenVault(payable(0xaB91B4666a0A8F3D35BeefF0492A9a0b2821FC5e));

    IUniswapV3Factory uniV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    INonfungiblePositionManager positionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

    struct SafeTX {
        address to;
        uint256 value;
        bytes data;
        Enum.Operation operation;
    }

    struct User {
        address addr;
        uint256 pk;
        address wallet;
    }

    User admin = User(vm.envAddress("ADMIN_ADDR"), vm.envUint("ADMIN_PK"), address(0));
    User[] users;
    uint256 numberOfUsers = 10;

    bytes32 A = "TOKEN_A";
    bytes32 B = "TOKEN_B";
    bytes32 C = "TOKEN_C";
    bytes32[] tokenIds = [A, B, C];

    DummyErc20 weth;
    mapping(bytes32 id => DummyErc20 underlyingToken) uTokens;
    mapping(bytes32 id => DummyErc20 pToken) pTokens;
    mapping(DummyErc20 pToken => IUniswapV3Pool pool) pools;

    uint256[] initialPrices = [5e16, 1e17, 2e18];

    string mnemonic = vm.envString("MNEMONIC");

    function run() public {
        // setup
        createUsers();
        createWeth();
        createUnderlyingTokens();
        createPTokens();
        createUserWallets();
        updateGuardToAllowTransfers();
        createPools();
        claimAndDistributePTokens(10_000_000e18);

        // seed

        // Period 0
        deposit(users[0], A, 400e18);
        mintWethSideLiquidity(users[1], A, 10e18);

        // Period 1
        deposit(users[2], B, 25e18);
        mintWethSideLiquidity(users[4], A, 25e18);
        mintWethSideLiquidity(users[6], C, 15e18);

        // Period 2
        // withdraw(users[0], A, 300e18);
        deposit(users[3], C, 30e18);
        mintWethSideLiquidity(users[5], B, 50e18);
        // mintPTokenSideLiquidity(users[7], C, 10e18);

        // Period 3
        // deposit(users[2], A, 50e18);
        // mintPTokenSideLiquidity(users[4], A, 75e18);
        // burnWethSideLiquidity(users[6], C, 15e18);
        // doubleSideLiquidity(users[8], C, 30e18)

        // Period 4
        // mintLiquidity(users[0], pTokens[0]);
        // mintLiquidity(users[0], pTokens[1]);
        // mintLiquidity(users[0], pTokens[2]);
    }

    function createUsers() internal {
        address userAddr;
        uint256 userPk;

        // create rest of users
        for (uint256 i = 1; i < numberOfUsers + 1; i++) {
            (userAddr, userPk) = deriveRememberKey(mnemonic, 1);
            users.push(User(userAddr, userPk, address(0)));
        }
    }

    function createWeth() internal {
        vm.startBroadcast(admin.pk);
        weth = new DummyErc20(admin.addr, "wrapped eth", "WETH");

        for (uint256 i = 0; i < users.length; i++) {
            weth.mint(users[i].addr, 1000e18);
        }

        vm.stopBroadcast();
    }

    function createUnderlyingTokens() internal {
        vm.startBroadcast(admin.pk);
        uTokens[A] = new DummyErc20(admin.addr, "Underlying A", "UNDER_A");
        uTokens[B] = new DummyErc20(admin.addr, "Underlying B", "UNDER_B");
        uTokens[C] = new DummyErc20(admin.addr, "Underlying C", "UNDER_C");

        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = 0; j < tokenIds.length; j++) {
                uTokens[tokenIds[j]].mint(users[i].addr, 1000e18);
            }
        }
        vm.stopBroadcast();
    }

    function createPTokens() internal {
        vm.startBroadcast(admin.pk);
        pTokens[A] = DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("A Point", "pA")));
        pTokens[B] = DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("B Point", "pB")));
        pTokens[C] = DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("C Point", "pC")));
        vm.stopBroadcast();
    }

    function createUserWallets() internal {
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address[] memory owners = new address[](1);

        for (uint32 i = 0; i < users.length; i++) {
            owners[0] = users[i].addr;
            vm.startBroadcast(users[i].pk);
            users[i].wallet = walletFactory.createWallet(owners, 1, initCalls);
            vm.stopBroadcast();
        }
    }

    function updateGuardToAllowTransfers() internal {
        vm.startBroadcast(admin.pk);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            guard.setCallAllowed(address(uTokens[tokenIds[i]]), ERC20.transfer.selector, RumpelGuard.AllowListState.ON);
        }
        vm.stopBroadcast();
    }

    function createPools() internal {
        vm.startBroadcast(admin.pk);
        address token0;
        address token1;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            (token0, token1) = _getOrderedTokens(address(weth), address(pTokens[tokenIds[i]]));
            pools[pTokens[tokenIds[i]]] = IUniswapV3Pool(
                positionManager.createAndInitializePoolIfNecessary(
                    token0, token1, 10000, _calculateSqrtPriceX96(initialPrices[i], 18, 18)
                )
            );
        }
        vm.stopBroadcast();
    }

    function claimAndDistributePTokens(uint256 amount) internal {
        vm.startBroadcast(admin.pk);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            bytes32 tokenId = tokenIds[i];
            string memory name = pTokens[tokenId].name();
            string memory symbol = pTokens[tokenId].symbol();
            bytes32 pointId = LibString.packTwo(name, symbol);

            bytes32 leaf1 = keccak256(abi.encodePacked(admin.addr, pointId, amount));
            bytes32 leaf2 = keccak256(abi.encodePacked(users[0].addr, pointId, amount));

            bytes32 root;
            if (leaf1 < leaf2) {
                root = keccak256(abi.encodePacked(leaf1, leaf2));
            } else {
                root = keccak256(abi.encodePacked(leaf2, leaf1));
            }

            bytes32[] memory proof = new bytes32[](1);
            proof[0] = leaf2;

            pointTokenVault.updateRoot(root);
            pointTokenVault.claimPTokens(
                PointTokenVault.Claim({pointsId: pointId, totalClaimable: amount, amountToClaim: amount, proof: proof}),
                admin.addr,
                admin.addr
            );

            for (uint256 j = 0; j < users.length; j++) {
                pTokens[tokenId].transfer(users[j].addr, (amount / 2) / users.length);
            }
        }

        vm.stopBroadcast();
    }

    function deposit(User memory user, bytes32 tokenId, uint256 amount) internal {
        vm.startBroadcast(user.pk);
        uTokens[tokenId].transfer(user.wallet, amount);
        vm.stopBroadcast();
    }

    function withdraw(User memory user, bytes32 tokenId, uint256 amount) internal {
        vm.startBroadcast(user.pk);
        ISafe safe = ISafe(user.wallet);
        bytes memory data = abi.encodeWithSelector(ERC20.transfer.selector, user.addr, amount);
        _execSafeTx(user, safe, address(uTokens[tokenId]), 0, data, Enum.Operation.Call);
        vm.stopBroadcast();
    }

    function mintPTokenSideLiquidity(User memory user, bytes32 tokenId, uint256 amount) internal {
        vm.startBroadcast(user.pk);
        DummyErc20 pToken = pTokens[tokenId];
        pToken.approve(address(positionManager), amount);

        (, int24 tick,,,,,) = IUniswapV3Pool(pools[pToken]).slot0();

        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;

        address token0 = address(pToken) < address(weth) ? address(pToken) : address(weth);
        address token1 = address(pToken) > address(weth) ? address(pToken) : address(weth);

        if (token0 == address(weth)) {
            amount0Desired = 0;
            amount1Desired = amount;
            tickLower = (tick / 200 - 1) * 200 - 200 * 10;
            tickUpper = (tick / 200 - 1) * 200;
        } else {
            amount0Desired = amount;
            amount1Desired = 0;
            tickLower = (tick / 200 + 1) * 200;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;
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
            recipient: user.addr,
            deadline: 1823444259
        });
        positionManager.mint(mintParams);
        vm.stopBroadcast();
    }

    function mintWethSideLiquidity(User memory user, bytes32 tokenId, uint256 amount) internal {
        vm.startBroadcast(user.pk);
        weth.approve(address(positionManager), amount);

        DummyErc20 pToken = pTokens[tokenId];
        (, int24 tick,,,,,) = IUniswapV3Pool(pools[pToken]).slot0();

        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;

        address token0 = address(pToken) < address(weth) ? address(pToken) : address(weth);
        address token1 = address(pToken) > address(weth) ? address(pToken) : address(weth);

        if (token0 == address(weth)) {
            amount0Desired = amount;
            amount1Desired = 0;
            tickLower = (tick / 200 + 1) * 200;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;
        } else {
            amount0Desired = 0;
            amount1Desired = amount;
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
            recipient: user.addr,
            deadline: 1823444259
        });
        positionManager.mint(mintParams);
        vm.stopBroadcast();
    }

    // internal helpers
    function _getOrderedTokens(address firstParam, address secondParam)
        internal
        pure
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

    function _execSafeTx(
        User memory user,
        ISafe safe,
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) public {
        SafeTX memory safeTX = SafeTX({to: to, value: value, data: data, operation: operation});

        uint256 nonce = safe.nonce();

        bytes32 txHash = safe.getTransactionHash(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), nonce
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user.pk, txHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        safe.execTransaction(
            safeTX.to, safeTX.value, safeTX.data, safeTX.operation, 0, 0, 0, address(0), payable(address(0)), signature
        );
    }
}
