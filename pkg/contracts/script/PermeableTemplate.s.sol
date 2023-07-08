// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.4.24;

import "forge-std/Script.sol";
import "../src/PermeableTemplate.sol";

contract PermeableTemplateScript is Script {
    address private daoFactory = 0x1234567890123456789012345678901234567890;
    address private ens = 0x1234567890123456789012345678901234567890;
    address private miniMeFactory = 0x1234567890123456789012345678901234567890;
    address private aragonID = 0x1234567890123456789012345678901234567890;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        PermeableTemplate t = new PermeableTemplate(daoFactory, ens, miniMeFactory, aragonID);

        t.newTokenAndInstance(
            "Governance Token",
            "GOV",
            "permeable",
            new address[](0),
            new uint256[](0),
            [uint64(50e16), uint64(5e16), uint64(7 days)],
            uint64(30 days),
            true
        );

        vm.stopBroadcast();
    }
}
