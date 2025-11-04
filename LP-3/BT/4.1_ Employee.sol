// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract EmployeeRecords {
    address public owner;

    struct Employee {
        uint256 id;
        string name;
        uint8 age;
        string department;
        uint256 salary; // in wei (or smallest currency unit)
        bool exists;
    }

    Employee[] private employees;              // dynamic array
    mapping(uint256 => uint256) private idxOf; // id -> index in employees (1-based)

    event EmployeeAdded(uint256 indexed id, string name);
    event EmployeeUpdated(uint256 indexed id);
    event EmployeeRemoved(uint256 indexed id);
    event Received(address indexed from, uint256 amount);
    event FallbackCalled(address indexed from, uint256 value, bytes data);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        employees.push(Employee(0,"",0,"",0,false)); // sentinel for 1-based indexing
    }

    // Add employee (owner)
    function addEmployee(
        uint256 _id,
        string calldata _name,
        uint8 _age,
        string calldata _department,
        uint256 _salary
    ) external onlyOwner {
        require(_id != 0, "Invalid id");
        require(!employeeExists(_id), "Exists");
        employees.push(Employee(_id, _name, _age, _department, _salary, true));
        idxOf[_id] = employees.length - 1;
        emit EmployeeAdded(_id, _name);
    }

    // Update employee (owner)
    function updateEmployee(
        uint256 _id,
        string calldata _name,
        uint8 _age,
        string calldata _department,
        uint256 _salary
    ) external onlyOwner {
        require(employeeExists(_id), "Not found");
        uint256 i = idxOf[_id];
        Employee storage e = employees[i];
        e.name = _name;
        e.age = _age;
        e.department = _department;
        e.salary = _salary;
        emit EmployeeUpdated(_id);
    }

    // Remove employee (owner) — swap & pop
    function removeEmployee(uint256 _id) external onlyOwner {
        require(employeeExists(_id), "Not found");
        uint256 i = idxOf[_id];
        uint256 last = employees.length - 1;
        if (i != last) {
            Employee storage lastEmp = employees[last];
            employees[i] = lastEmp;
            idxOf[lastEmp.id] = i;
        }
        employees.pop();
        delete idxOf[_id];
        emit EmployeeRemoved(_id);
    }

    // View employee
    function getEmployee(uint256 _id) external view returns (uint256 id, string memory name, uint8 age, string memory department, uint256 salary) {
        require(employeeExists(_id), "Not found");
        Employee storage e = employees[idxOf[_id]];
        return (e.id, e.name, e.age, e.department, e.salary);
    }

    // List all employee ids
    function listEmployeeIds() external view returns (uint256[] memory) {
        uint256 n = employees.length;
        if (n <= 1) return new uint256;
        uint256[] memory ids = new uint256[](n - 1);
        for (uint256 i = 1; i < n; i++) ids[i - 1] = employees[i].id;
        return ids;
    }

    function employeeExists(uint256 _id) public view returns (bool) {
        uint256 i = idxOf[_id];
        if (i == 0) return false;
        return employees[i].exists;
    }

    // Accept plain ETH transfers
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Fallback for unknown calls
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
}