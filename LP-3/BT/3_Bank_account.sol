// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract BankAccount {
    mapping(address => uint256) private balances;
    mapping(address => bool) private isUser;

    event AccountCreated(address user, uint256 amount);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);

    function createAccount() public payable {
        require(!isUser[msg.sender], "Account exists");
        isUser[msg.sender] = true;
        balances[msg.sender] = msg.value;
        emit AccountCreated(msg.sender, msg.value);
    }

    function deposit() public payable {
        require(isUser[msg.sender], "No account");
        require(msg.value > 0, "Amount > 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(isUser[msg.sender], "No account");
        require(balances[msg.sender] >= amount, "Low balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function showBalance() public view returns (uint256) {
        require(isUser[msg.sender], "No account");
        return balances[msg.sender];
    }
}
