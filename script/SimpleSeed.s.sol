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

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
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

contract DummyMorpho {
    mapping(address user => mapping(address token => uint256 amount)) _balances;

    event SupplyCollateral(bytes32 indexed id, address indexed caller, address indexed onBehalf, uint256 assets);
    event WithdrawCollateral(
        bytes32 indexed id, address caller, address indexed onBehalf, address indexed receiver, uint256 assets
    );

    function supplyCollateral(bytes32 id, address token, uint256 amount) public {
        _balances[msg.sender][token] += amount;
        ERC20(token).transferFrom(msg.sender, address(this), amount);
        emit SupplyCollateral(id, msg.sender, msg.sender, amount);
    }

    function withdrawCollateral(bytes32 id, address token, uint256 amount) public {
        require(amount <= _balances[msg.sender][token], "Not enough balance");
        _balances[msg.sender][token] -= amount;
        ERC20(token).transfer(msg.sender, amount);
        emit WithdrawCollateral(id, msg.sender, msg.sender, msg.sender, amount);
    }
}

contract SimpleSeed is Script {
    RumpelWalletFactory walletFactory = RumpelWalletFactory(0x4d67eC37cbBf6AAEbf27d8816D0424D255E77Dc4);
    RumpelGuard guard = RumpelGuard(0x05959a76DF690Dc3423A7c71C90Bb810E4932754);
    PointTokenVault pointTokenVault = PointTokenVault(payable(0xaB91B4666a0A8F3D35BeefF0492A9a0b2821FC5e));

    IUniswapV3Factory uniV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    INonfungiblePositionManager positionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

    DummyMorpho morpho = DummyMorpho(0xb1298dfBb900Cf0925E8Eb231031829B96F79896);

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
    bytes32 D = "TOKEN_D";
    bytes32[] tokenIds = [A, B, C, D];

    DummyErc20 weth;
    mapping(bytes32 id => DummyErc20 underlyingToken) uTokens;
    mapping(bytes32 id => DummyErc20 pToken) pTokens;
    mapping(DummyErc20 pToken => IUniswapV3Pool pool) pools;
    mapping(bytes32 id => uint256 initialPrice) initialPrices;

    string mnemonic = vm.envString("MNEMONIC");

    function run() public {
        console.log("admin:", admin.addr);

        initialPrices[A] = 5e16;
        initialPrices[B] = 50000e18;
        initialPrices[C] = 100e18;
        initialPrices[D] = 3000e18;

        createUsers();
        fundUsers();
        createWeth();
        createUnderlyingTokens();
        createPTokens();
        createUserWallets();
        updateGuardToAllowTransfers();
        createPools();
        claimAndDistributePTokens(10_000_000e18);

        // weth = DummyErc20(0x72c18AB51A865E5d24ED69f026a7a962EF7D3899);

        // uTokens[A] = DummyErc20(0x797837Fc728fa98A2e85aA0Df9759B3BaDba11A7);
        // uTokens[B] = DummyErc20(0x7354a309F37601c81DD610b5E9eEdCEba256c088);
        // uTokens[C] = DummyErc20(0x6803Dde7737eF1f96faF1C6ACEeD2F6030CB7E1A);
        // uTokens[D] = DummyErc20(0x565e8D35B56174e35C0fc06435Dc9F43BbF86781);

        // pTokens[A] = DummyErc20(0x4CFb882B75CE0d78ba20e49Dc00aA5Eeb0433699);
        // pTokens[B] = DummyErc20(0xE9e97F2e6dd1a420dfA6c0974Da2e537df60c2bA);
        // pTokens[C] = DummyErc20(0x95E1DC07EDBF9a59F72e41Fd533f1A5B4f3AbB72);
        // pTokens[D] = DummyErc20(0x8F31499D0C314E9a5345fcd52768c3c30C11e64F);

        // pools[pTokens[A]] = IUniswapV3Pool(0xa0820E79483622C65e1eF6c8fa15f8362917448e);
        // pools[pTokens[B]] = IUniswapV3Pool(0x3CD3EF402819e4Ec5D43b94C39CfDFA2C7E9Ad4C);
        // pools[pTokens[C]] = IUniswapV3Pool(0xB4FC88d0a0BA8D5EeACB45Fe07B99D039Be6cA4B);
        // pools[pTokens[D]] = IUniswapV3Pool(0xd67635cc24cDF27B1f81cf7D3975ff4F942b942F);

        // users[0].wallet = 0x4D4f8317c296F7d91d51B811ca5343CB166360e5;
        // users[1].wallet = 0x59BD3C33127D2D2766f5CcFe7AeA9fEa544EE102;
        // users[2].wallet = 0x4232EA2F481E06A39Edf378952a57dc93D7A1401;
        // users[3].wallet = 0x4DEf3F63A2DCFD3078D32F195632c340C9689c57;
        // users[4].wallet = 0xd25E37f3bA6b065d151370f440a37861da89b1D0;
        // users[5].wallet = 0x9e53D1af9FF446165D24A2295b6C5D356f6d6Ee8;
        // users[6].wallet = 0xe75ae49085531946a552985AE797eCA72CeDc38f;
        // users[7].wallet = 0x5c695A313185E127CCFD06C99f57e927f58BD00D;
        // users[8].wallet = 0x71052156cbC38d37D3BBFF34499d546e2Ad565Cb;
        // users[9].wallet = 0x75033C3697b4862bA00946F0e8F35068761cE55a;
        // users[10].wallet = 0xEb0C585F8343D350c17f42e6881D938722c96b21;

        // seed
        // Period 0
        deposit(users[0], A, 400e18);
        mintWethSideLiquidity(users[1], A, 10e18);

        // Period 1
        deposit(users[2], B, 25e18);
        mintWethSideLiquidity(users[4], A, 25e18);
        uint256 lpToBurn = mintWethSideLiquidity(users[6], C, 15e18);
        morphoSupplyCollateral(users[9], D, 1000e18);

        // Period 2
        withdraw(users[0], A, 300e18);
        deposit(users[3], C, 30e18);
        mintWethSideLiquidity(users[5], B, 50e18);
        mintPTokenSideLiquidity(users[7], C, 10e18);

        // Period 3
        // uint256 lpToBurn = 20666;
        deposit(users[2], A, 50e18);
        mintPTokenSideLiquidity(users[4], A, 75e18);
        burnWethSideLiquidity(lpToBurn, users[6]);
        mintDualSideLiquidity(users[8], C, 30e18);

        // Period 4
        withdraw(users[3], C, 30e18);
        morphoWithdrawCollateral(users[9], D, 1000e18);

        // Period 5
        deposit(users[0], A, 350e18);
        mintWethSideLiquidity(users[5], C, 10e18);

        // Period 6
        withdraw(users[2], A, 50e18);
        deposit(users[3], C, 30e18);
        mintWethSideLiquidity(users[6], C, 15e18);
    }

    function createUsers() internal {
        address userAddr;
        uint256 userPk;

        // create rest of users
        for (uint32 i = 0; i < numberOfUsers + 1; i++) {
            (userAddr, userPk) = deriveRememberKey(mnemonic, i);
            users.push(User(userAddr, userPk, address(0)));
            console.log("user", i, userAddr);
        }
    }

    function fundUsers() internal {
        vm.startBroadcast(users[0].pk);
        for (uint256 i = 1; i < users.length; i++) {
            address payable recipient = payable(users[i].addr);
            uint256 amount = 0.025 ether;
            (bool sent,) = recipient.call{value: amount}("");
            require(sent, "Failed to send Ether");
        }
        vm.stopBroadcast();
    }

    function createWeth() internal {
        vm.startBroadcast(admin.pk);
        weth = new DummyErc20(admin.addr, "wrapped eth", "WETH");
        console.log("weth", address(weth));

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
        uTokens[D] = new DummyErc20(admin.addr, "Underlying D", "UNDER_D");

        console.log("Underlying A", address(uTokens[A]));
        console.log("Underlying B", address(uTokens[B]));
        console.log("Underlying C", address(uTokens[C]));
        console.log("Underlying D", address(uTokens[D]));

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
        pTokens[D] = DummyErc20(pointTokenVault.deployPToken(LibString.packTwo("D Point", "pD")));

        console.log("A Point", address(pTokens[A]));
        console.log("B Point", address(pTokens[B]));
        console.log("C Point", address(pTokens[C]));
        console.log("D Point", address(pTokens[D]));

        vm.stopBroadcast();
    }

    function createUserWallets() internal {
        InitializationScript.InitCall[] memory initCalls = new InitializationScript.InitCall[](0);
        address[] memory owners = new address[](1);

        for (uint32 i = 0; i < users.length; i++) {
            owners[0] = users[i].addr;
            vm.startBroadcast(users[i].pk);
            users[i].wallet = walletFactory.createWallet(owners, 1, initCalls);
            console.log("user wallet", users[i].addr, users[i].wallet);
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
                    token0, token1, 10000, _calculateSqrtPriceX96(initialPrices[tokenIds[i]], 18, 18)
                )
            );
            console.log("pool", pTokens[tokenIds[i]].symbol(), address(pools[pTokens[tokenIds[i]]]));
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

    function mintWethSideLiquidity(User memory user, bytes32 tokenId, uint256 amount) internal returns (uint256) {
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
        (uint256 lpTokenId,,,) = positionManager.mint(mintParams);
        vm.stopBroadcast();
        return lpTokenId;
    }

    function mintDualSideLiquidity(User memory user, bytes32 tokenId, uint256 wethAmount) internal {
        vm.startBroadcast(user.pk);

        DummyErc20 pToken = pTokens[tokenId];
        (, int24 tick,,,,,) = IUniswapV3Pool(pools[pToken]).slot0();

        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;

        address token0 = address(pToken) < address(weth) ? address(pToken) : address(weth);
        address token1 = address(pToken) > address(weth) ? address(pToken) : address(weth);

        if (token0 == address(weth)) {
            amount0Desired = wethAmount;
            amount1Desired = wethAmount * initialPrices[tokenId] / 1e18;
            tickLower = (tick / 200 + 1) * 200 - 200 * 11;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;
            weth.approve(address(positionManager), amount0Desired + amount0Desired * 1e17 / 1e18);
            pToken.approve(address(positionManager), amount1Desired + amount1Desired * 1e17 / 1e18);
        } else {
            amount0Desired = wethAmount * 1e18 / initialPrices[tokenId];
            amount1Desired = wethAmount;
            tickLower = (tick / 200 + 1) * 200 - 200 * 11;
            tickUpper = (tick / 200 + 1) * 200 + 200 * 10;

            weth.approve(address(positionManager), amount1Desired + amount1Desired * 1e17 / 1e18);
            pToken.approve(address(positionManager), amount0Desired + amount0Desired * 1e17 / 1e18);
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

    function burnWethSideLiquidity(uint256 lpTokenId, User memory user) internal {
        (,,,,,,, uint128 liquidity,,,,) = positionManager.positions(lpTokenId);

        vm.startBroadcast(user.pk);
        positionManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: lpTokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: 1823444259
            })
        );

        vm.stopBroadcast();
    }

    function morphoSupplyCollateral(User memory user, bytes32 tokenId, uint256 amount) public {
        vm.startBroadcast(user.pk);
        uTokens[tokenId].approve(address(morpho), amount);
        morpho.supplyCollateral(tokenId, address(uTokens[tokenId]), amount);
        vm.stopBroadcast();
    }

    function morphoWithdrawCollateral(User memory user, bytes32 tokenId, uint256 amount) public {
        vm.startBroadcast(user.pk);
        morpho.withdrawCollateral(tokenId, address(uTokens[tokenId]), amount);
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
