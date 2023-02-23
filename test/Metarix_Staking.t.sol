// Commands
// forge test --match-path test/Metarix_Staking.t.sol -vvvvv --gas-report
// forge test --match-path test/Metarix_Staking.t.sol --gas-report

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/MetarixStaking.sol";
import "../src/Mocks/Token.sol";

contract MetarixStaking_Test is Test {
    
    MocksERC20 public token;
    MetarixStaking_V1 public staking;

    address public token_deployer;
    address public staking_deployer;

    address public user = address(12345);

    function setUp() public {
        /// Deploy ...
        token = new MocksERC20();
        staking = new MetarixStaking_V1();

        token_deployer = token.owner();
        staking_deployer = staking.owner();

        /// Change the staked token address
        vm.prank(staking_deployer);
        staking.changeMetarixAddress(address(token));

        /// Send tokens for rewards
        vm.prank(token_deployer);
        token.approve(address(staking), 100 * 10 ** 18);
        token.transfer(address(staking), 100 * 10 ** 18);

        /// Send tokens to user
        token.approve(user, 100 * 10 ** 18);
        token.transfer(user, 100 * 10 ** 18);

        /// Register the tokens for rewards
        vm.prank(staking_deployer);
        staking.registerTokensForRewards();
    }

    function testStaking() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);

        // uint256 _allowance = token.allowance(user, address(staking));
        // console.log("Allowance: %s", _allowance);

        staking.stake(2, 10 * 10 ** 18);
    }

    function testFailUnstake() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(2, 10 * 10 ** 18);
        staking.unstake(0); 
    }

    function testEmergencyWithdraw() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(2, 10 * 10 ** 18);
        staking.emergencyWithdraw(0);
    }

    function testCompund() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(2, 10 * 10 ** 18);
        vm.warp(block.timestamp + 7 days);
        staking.compound(0);
    }

    function testFailCompundAfterMaturity() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(0, 10 * 10 ** 18);
        vm.warp(block.timestamp + 91 days);
        staking.compound(0); 
    }

    function testCompundAndUnstake() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(0, 10 * 10 ** 18);
        vm.warp(block.timestamp + 7 days);
        staking.compound(0);
        vm.warp(block.timestamp + 91 days);
        staking.unstake(0); 
    }

    function testDoubleCompundAndUnstake() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(0, 10 * 10 ** 18);
        vm.warp(block.timestamp + 7 days);
        staking.compound(0);
        vm.warp(block.timestamp + 30 days);
        staking.compound(0);
        vm.warp(block.timestamp + 91 days);
        staking.unstake(0); 
    }

    function testFailDoubleCompundAndUnstake() public {
        vm.prank(user);
        token.approve(address(staking), 100 * 10 ** 18);
        staking.stake(0, 10 * 10 ** 18);
        vm.warp(block.timestamp + 7 days);
        staking.compound(0);
        vm.warp(block.timestamp + 84 days);
        staking.compound(0);
        vm.warp(block.timestamp + 90 days);
        staking.unstake(0); 
    }
}
