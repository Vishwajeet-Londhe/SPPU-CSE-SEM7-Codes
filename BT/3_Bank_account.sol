// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract BankAccount {
    mapping(address => uint256) private balances;
    mapping(address => bool) private isUser;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // Create account (optional initial deposit)
    function createAccount() public payable {
        require(!isUser[msg.sender], "Account already exists");
        isUser[msg.sender] = true;
        balances[msg.sender] = msg.value;
    }

    // Deposit money
    function deposit() public payable {
        require(isUser[msg.sender], "Account not found");
        require(msg.value > 0, "Deposit must be > 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw money
    function withdraw(uint256 amount) public {
        require(isUser[msg.sender], "Account not found");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit Withdraw(msg.sender, amount);
    }

    // Show your balance
    function showBalance() public view returns (uint256) {
        require(isUser[msg.sender], "Account not found");
        return balances[msg.sender];
    }
}