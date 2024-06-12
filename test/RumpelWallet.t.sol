// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RumpelWalletFactory} from "../src/Counter.sol";

contract RumpelWalletTest is Test {
    RumpelWalletFactory public rumpelWalletFactory;

    function setUp() public {
        rumpelWalletFactory = new RumpelWalletFactory();
    }
}
