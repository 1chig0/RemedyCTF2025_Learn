// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {console2, Test} from "forge-std/Test.sol";
import "../src/Challenge.sol";
import "../src/Casino.sol";
import "../src/interfaces/ICasino.sol";


contract CasinoTest is Test { 
    uint256 privateKey = vm.deriveKey("test test test test test test test test test test test ball",0);
    address public PLAYER = vm.addr(privateKey);
    // uint256 systemPK = vm.deriveKey("test test test test test test test test test test test junk", 1);

    uint systemPK = vm.deriveKey("test test test test test test test test test test test junk", 1);
    address public challenge;
    address public system = vm.addr(systemPK);
    Casino public casino;
    
    function setUp() public {
        vm.label(PLAYER, "PLAYER");
        vm.label(system, "system");
        vm.deal(system, 100 ether);
        console2.log("systemPK", systemPK);
        console2.log("this1: ",address(this));
        vm.startBroadcast(system);
        console2.log("this2: ",address(this));
        challenge = address(new Challenge(PLAYER));
        casino = Challenge(challenge).CASINO();
        casino.deposit{value: 100 ether}(system);

        bytes32 salt = 0x5365718353c0589dc12370fcad71d2e7eb4dcb557cfbea5abb41fb9d4a9ffd3a;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(systemPK, keccak256(abi.encode(0, salt)));
        casino.pause(
            abi.encodePacked(r, s, v),
            salt
        );

        salt = 0x7867dc2b606f63c4ad88af7e48c7b934255163b45fb275880b4b451fa5d25e1b;
        (v, r, s) = vm.sign(systemPK, keccak256(abi.encode(1, system, 1 ether, salt)));
        casino.reset(
            abi.encodePacked(r, s, v),
            payable(system),
            1 ether,
            salt
        );

        vm.stopBroadcast();
    }

    function testChallenge() public {
        vm.startPrank(PLAYER);
        // uint b1 = casino.balances(system);
        uint b1 = address(casino).balance;
        console2.log("b1", b1);
        uint b2 = system.balance;
        console2.log("b2", b2);
        casino.bet(0 ether);
        vm.stopPrank();
    }
}