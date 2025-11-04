// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract StudentManager {
    struct Student {
        uint256 id;
        string name;
        uint8 age;
        string course;
    }

    Student[] private students;
    mapping(uint256 => uint256) private idx;
    uint256 public studentCount;

    uint256 public depositsCount;
    uint256 public lastDepositAmount;
    address public lastSender;

    event StudentAdded(uint256 indexed id, string name);
    event StudentUpdated(uint256 indexed id);
    event StudentRemoved(uint256 indexed id);
    event Received(address indexed from, uint256 amount);
    event FallbackCalled(address indexed from, uint256 amount, bytes data);

    constructor() {
        studentCount = 0;
    }

    function addStudent(string calldata _name, uint8 _age, string calldata _course) external {
        studentCount += 1;
        uint256 newId = studentCount;
        students.push(Student({id: newId, name: _name, age: _age, course: _course}));
        idx[newId] = students.length;
        emit StudentAdded(newId, _name);
    }

    function getStudent(uint256 _id) public view returns (Student memory) {
        uint256 i = idx[_id];
        require(i != 0, "Student not found");
        return students[i - 1];
    }

    function getAllStudents() external view returns (Student[] memory) {
        return students;
    }

    function updateStudent(uint256 _id, string calldata _name, uint8 _age, string calldata _course) external {
        uint256 i = idx[_id];
        require(i != 0, "Student not found");
        Student storage s = students[i - 1];
        s.name = _name;
        s.age = _age;
        s.course = _course;
        emit StudentUpdated(_id);
    }

    function removeStudent(uint256 _id) external {
        uint256 i = idx[_id];
        require(i != 0, "Student not found");
        uint256 arrayIndex = i - 1;
        uint256 lastIndex = students.length - 1;
        if (arrayIndex != lastIndex) {
            Student memory lastStudent = students[lastIndex];
            students[arrayIndex] = lastStudent;
            idx[lastStudent.id] = arrayIndex + 1;
        }
        students.pop();
        idx[_id] = 0;
        emit StudentRemoved(_id);
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

    function getStudentsLength() external view returns (uint256) {
        return students.length;
    }
}
