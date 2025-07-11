// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract SimpleToken {
     // Mapping to store balances
    mapping(address => uint256) private balances;
    
    // Total supply of tokens
    uint256 private totalSupply;
    
    // Contract owner
    address private owner;
    
    // Events for tracking token operations
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    
    // Modifier to restrict functions to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // Constructor sets the contract deployer as owner
    constructor() {
        owner = msg.sender;
    }
    
    // Function to mint new tokens
    function mint(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "Cannot mint to zero address");
        require(amount > 0, "Mint amount must be greater than zero");
        
        totalSupply += amount;
        balances[recipient] += amount;
        
        emit Mint(recipient, amount);
        emit Transfer(address(0), recipient, amount);
    }
    
    // Function to transfer tokens
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Cannot transfer to zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    
    // Function to check balance
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    // Function to get total supply
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }
   
}
