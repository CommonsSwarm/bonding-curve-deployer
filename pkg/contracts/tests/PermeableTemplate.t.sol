// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PermeableTemplate.sol";

contract PermeableTemplateTest is Test {
    PermeableTemplate public permeableTemplate;
    address[] holders = new address[](1);
    uint256[] stakes = new uint256[](1);

    address private daoFactory = 0x4037F97fcc94287257E50Bd14C7DA9Cb4Df18250;
    address private ens = 0xaAfCa6b0C89521752E559650206D7c925fD0e530;
    address private miniMeFactory = 0xf7d36d4d46CDA364eDc85E5561450183469484C5;
    address private aragonID = 0x0B3b17F9705783Bb51Ae8272F3245D6414229B36;

    function setUp() public {
        // permeableTemplate = new PermeableTemplate(daoFactory, ens, miniMeFactory, aragonID);

        // permeableTemplate.newToken("Governance Token", "GOV");
    }

    function testFeeBuyShares() public {
        // holders[0] = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        // stakes[0] = 100e18;
        // permeableTemplate.newInstance(
        //     "permeable", holders, stakes, [uint64(50e16), uint64(5e16), uint64(7 days)], false, 0, 0
        // );
        // counter.increment();
        // assertEq(counter.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        // counter.setNumber(x);
        // assertEq(counter.number(), x);
    }
}
