// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-ctf/CTFDeployer.sol";
import {console2, Test} from "forge-std/Test.sol";
import "src/Challenge.sol";
import "src/Casino.sol";

contract Deploy is CTFDeployer {
    function deploy(address system, address player) internal override returns (address challenge) {
        uint _playerPK = getPrivateKey1(0);
        uint _systemPK = getPrivateKey1(1);
        console2.log("player: ", player);
        console2.log("system: ", system);
        // vm.deal(system, 100 ether);
        vm.startBroadcast(_systemPK);

        challenge = address(new Challenge(player));
        console2.log("challenge address", challenge);
        Casino casino = Challenge(challenge).CASINO();
        casino.deposit{value: 100 ether}(system);

        uint systemPK = vm.deriveKey(vm.envString("MNEMONIC"), 1);
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

    function getPrivateKey1(uint32 index) private returns (uint) {
        string memory mnemonic = vm.envOr("MNEMONIC", string("test test test test test test test test test test test junk"));
        return vm.deriveKey(mnemonic, index);
    }


    function getPrivateKey2(uint32 index) private returns (uint) {
        string memory mnemonic = vm.envOr("MNEMONIC", string("test test test test test test test test test test test ball"));
        return vm.deriveKey(mnemonic, index);
    }
}
