// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EmployeeManager {
    struct Employee {
        uint256 id;
        string name;
        uint8 age;
        string department;
        uint256 salary;
    }

    Employee[] private employees;
    mapping(uint256 => uint256) private idx;
    uint256 public employeeCount;

    uint256 public depositsCount;
    uint256 public lastDepositAmount;
    address public lastSender;

    event EmployeeAdded(uint256 indexed id, string name);
    event EmployeeUpdated(uint256 indexed id);
    event EmployeeRemoved(uint256 indexed id);
    event Received(address indexed from, uint256 amount);
    event FallbackCalled(address indexed from, uint256 amount, bytes data);

    constructor() {
        employeeCount = 0;
    }

    function addEmployee(string calldata _name, uint8 _age, string calldata _department, uint256 _salary) external {
        employeeCount += 1;
        uint256 newId = employeeCount;
        employees.push(Employee({id: newId, name: _name, age: _age, department: _department, salary: _salary}));
        idx[newId] = employees.length;
        emit EmployeeAdded(newId, _name);
    }

    function getEmployee(uint256 _id) public view returns (Employee memory) {
        uint256 i = idx[_id];
        require(i != 0, "Employee not found");
        return employees[i - 1];
    }

    function getAllEmployees() external view returns (Employee[] memory) {
        return employees;
    }

    function updateEmployee(uint256 _id, string calldata _name, uint8 _age, string calldata _department, uint256 _salary) external {
        uint256 i = idx[_id];
        require(i != 0, "Employee not found");
        Employee storage e = employees[i - 1];
        e.name = _name;
        e.age = _age;
        e.department = _department;
        e.salary = _salary;
        emit EmployeeUpdated(_id);
    }

    function removeEmployee(uint256 _id) external {
        uint256 i = idx[_id];
        require(i != 0, "Employee not found");
        uint256 arrayIndex = i - 1;
        uint256 lastIndex = employees.length - 1;
        if (arrayIndex != lastIndex) {
            Employee memory lastEmployee = employees[lastIndex];
            employees[arrayIndex] = lastEmployee;
            idx[lastEmployee.id] = arrayIndex + 1;
        }
        employees.pop();
        idx[_id] = 0;
        emit EmployeeRemoved(_id);
    }

    function deposit() external payable {
        require(msg.value > 0, "Send ETH");
        depositsCount += 1;
        lastDepositAmount = msg.value;
        lastSender = msg.sender;
        emit Received(msg.sender, msg.value);
    }

    receive() external payable {
        depositsCount += 1;
        lastDepositAmount = msg.value;
        lastSender = msg.sender;
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        depositsCount += 1;
        lastDepositAmount = msg.value;
        lastSender = msg.sender;
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }

    function getEmployeesLength() external view returns (uint256) {
        return employees.length;
    }
}