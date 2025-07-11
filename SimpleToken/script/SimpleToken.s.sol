// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {SimpleToken} from "../src/SimpleToken.sol";

contract SimpleTokenScript is Script {
    SimpleToken public simpleToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        simpleToken = new SimpleToken();

        vm.stopBroadcast();
    }
}
