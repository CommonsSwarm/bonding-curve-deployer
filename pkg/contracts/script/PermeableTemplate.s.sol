// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.2;

import "forge-std/Script.sol";
import "../src/PermeableTemplate.sol";

contract PermeableTemplateScript is Script {
    address private daoFactory = 0x4037F97fcc94287257E50Bd14C7DA9Cb4Df18250;
    address private ens = 0xaAfCa6b0C89521752E559650206D7c925fD0e530;
    address private miniMeFactory = 0xf7d36d4d46CDA364eDc85E5561450183469484C5;
    address private aragonID = 0x0B3b17F9705783Bb51Ae8272F3245D6414229B36;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address _collateralToken = 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d;
        uint32 _reserveRatio = 20e4; // 20%
        uint256 _buyFeePct = 10;
        uint256 _sellFeePct = 20;
        uint256 _initialAmount = 1e18;

        PermeableTemplate t = new PermeableTemplate(daoFactory, ens, miniMeFactory, aragonID);

        address[] memory holders = new address[](1);
        holders[0] = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

        uint256[] memory stakes = new uint256[](1);
        stakes[0] = 100e18;

        IERC20(_collateralToken).approve(address(t), _initialAmount);

        t.newToken("Governance Token", "GOV");
        t.newInstance(
            "permeable",
            holders,
            stakes,
            [uint64(50e16), uint64(5e16), uint64(7 days)],
            [uint256(_buyFeePct), uint256(_sellFeePct)],
            _collateralToken,
            _reserveRatio,
            _initialAmount
        );

        vm.stopBroadcast();
    }
}
