// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {SimpleToken} from "../src/SimpleToken.sol";

contract SimpleTokenTest is Test {
    SimpleToken public simpleToken;
    
    address public owner;
    address public user1;
    address public user2;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);

    function setUp() public {
        owner = address(this); // Test contract is the owner
        user1 = address(0x1);
        user2 = address(0x2);
        
        simpleToken = new SimpleToken();
    }

    // ===== Constructor Tests =====
    function test_constructor_setsOwnerCorrectly() public {
        // The owner should be the deployer (this test contract)
        // We can verify this by checking that only the owner can mint
        simpleToken.mint(user1, 100);
        assertEq(simpleToken.balanceOf(user1), 100);
    }

    // ===== Mint Function Tests =====
    function test_mint_successfulMint() public {
        uint256 mintAmount = 1000;
        
        vm.expectEmit(true, false, false, true);
        emit Mint(user1, mintAmount);
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, mintAmount);
        
        simpleToken.mint(user1, mintAmount);
        
        assertEq(simpleToken.balanceOf(user1), mintAmount);
        assertEq(simpleToken.getTotalSupply(), mintAmount);
    }

    function test_mint_onlyOwnerCanMint() public {
        vm.prank(user1); // Switch to user1 context
        vm.expectRevert("Only owner can call this function");
        simpleToken.mint(user2, 100);
    }

    function test_mint_cannotMintToZeroAddress() public {
        vm.expectRevert("Cannot mint to zero address");
        simpleToken.mint(address(0), 100);
    }

    function test_mint_cannotMintZeroAmount() public {
        vm.expectRevert("Mint amount must be greater than zero");
        simpleToken.mint(user1, 0);
    }

    function test_mint_multipleMints() public {
        simpleToken.mint(user1, 500);
        simpleToken.mint(user2, 300);
        simpleToken.mint(user1, 200); // Additional mint to user1
        
        assertEq(simpleToken.balanceOf(user1), 700);
        assertEq(simpleToken.balanceOf(user2), 300);
        assertEq(simpleToken.getTotalSupply(), 1000);
    }

    // ===== Transfer Function Tests =====
    function test_transfer_successfulTransfer() public {
        // First mint some tokens to user1
        simpleToken.mint(user1, 1000);
        
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, user2, 300);
        
        bool result = simpleToken.transfer(user2, 300);
        
        assertTrue(result);
        assertEq(simpleToken.balanceOf(user1), 700);
        assertEq(simpleToken.balanceOf(user2), 300);
    }

    function test_transfer_cannotTransferToZeroAddress() public {
        simpleToken.mint(user1, 1000);
        
        vm.prank(user1);
        vm.expectRevert("Cannot transfer to zero address");
        simpleToken.transfer(address(0), 100);
    }

    function test_transfer_cannotTransferZeroAmount() public {
        simpleToken.mint(user1, 1000);
        
        vm.prank(user1);
        vm.expectRevert("Transfer amount must be greater than zero");
        simpleToken.transfer(user2, 0);
    }

    function test_transfer_insufficientBalance() public {
        simpleToken.mint(user1, 100);
        
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        simpleToken.transfer(user2, 200); // Trying to transfer more than balance
    }

    function test_transfer_exactBalance() public {
        simpleToken.mint(user1, 500);
        
        vm.prank(user1);
        bool result = simpleToken.transfer(user2, 500);
        
        assertTrue(result);
        assertEq(simpleToken.balanceOf(user1), 0);
        assertEq(simpleToken.balanceOf(user2), 500);
    }

    function test_transfer_multipleTransfers() public {
        simpleToken.mint(user1, 1000);
        
        vm.startPrank(user1);
        simpleToken.transfer(user2, 300);
        simpleToken.transfer(user2, 200);
        vm.stopPrank();
        
        assertEq(simpleToken.balanceOf(user1), 500);
        assertEq(simpleToken.balanceOf(user2), 500);
    }

    // ===== View Function Tests =====
    function test_balanceOf_zeroBalance() public {
        assertEq(simpleToken.balanceOf(user1), 0);
        assertEq(simpleToken.balanceOf(user2), 0);
    }

    function test_balanceOf_afterMintAndTransfer() public {
        simpleToken.mint(user1, 1000);
        
        vm.prank(user1);
        simpleToken.transfer(user2, 400);
        
        assertEq(simpleToken.balanceOf(user1), 600);
        assertEq(simpleToken.balanceOf(user2), 400);
    }

    function test_getTotalSupply_initiallyZero() public {
        assertEq(simpleToken.getTotalSupply(), 0);
    }

    function test_getTotalSupply_afterMints() public {
        simpleToken.mint(user1, 500);
        assertEq(simpleToken.getTotalSupply(), 500);
        
        simpleToken.mint(user2, 300);
        assertEq(simpleToken.getTotalSupply(), 800);
    }

    function test_getTotalSupply_unchangedAfterTransfers() public {
        simpleToken.mint(user1, 1000);
        uint256 totalBefore = simpleToken.getTotalSupply();
        
        vm.prank(user1);
        simpleToken.transfer(user2, 400);
        
        assertEq(simpleToken.getTotalSupply(), totalBefore);
    }

    // ===== Fuzz Testing =====
    function testFuzz_mint(uint256 amount) public {
        vm.assume(amount > 0 && amount < type(uint256).max);
        
        simpleToken.mint(user1, amount);
        assertEq(simpleToken.balanceOf(user1), amount);
        assertEq(simpleToken.getTotalSupply(), amount);
    }

    function testFuzz_transfer(uint256 mintAmount, uint256 transferAmount) public {
        vm.assume(mintAmount > 0 && mintAmount < type(uint256).max);
        vm.assume(transferAmount > 0 && transferAmount <= mintAmount);
        
        simpleToken.mint(user1, mintAmount);
        
        vm.prank(user1);
        simpleToken.transfer(user2, transferAmount);
        
        assertEq(simpleToken.balanceOf(user1), mintAmount - transferAmount);
        assertEq(simpleToken.balanceOf(user2), transferAmount);
    }
}
