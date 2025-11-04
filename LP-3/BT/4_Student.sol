// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract StudentRecords {
    // student structure
    struct Student {
        uint256 id;
        string name;
        uint8 age;
        string course;
        bool exists;
    }

    Student[] private students;                    // dynamic array of students
    mapping(uint256 => uint256) private indexOf;   // id -> index in students array (1-based)
    address public owner;

    event StudentAdded(uint256 indexed id, string name);
    event StudentUpdated(uint256 indexed id);
    event StudentRemoved(uint256 indexed id);
    event Received(address indexed from, uint256 amount);
    event FallbackCalled(address indexed from, uint256 amount, bytes data);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        students.push(Student(0,"",0,"",false)); // sentinel to make index 1-based
    }

    // add student
    function addStudent(uint256 _id, string calldata _name, uint8 _age, string calldata _course) external onlyOwner {
        require(_id != 0, "Invalid id");
        require(!studentsExists(_id), "Already exists");
        students.push(Student(_id, _name, _age, _course, true));
        indexOf[_id] = students.length - 1;
        emit StudentAdded(_id, _name);
    }

    // update student
    function updateStudent(uint256 _id, string calldata _name, uint8 _age, string calldata _course) external onlyOwner {
        require(studentsExists(_id), "Not found");
        uint256 idx = indexOf[_id];
        Student storage s = students[idx];
        s.name = _name;
        s.age = _age;
        s.course = _course;
        emit StudentUpdated(_id);
    }

    // remove student (keeps array compact by swapping with last)
    function removeStudent(uint256 _id) external onlyOwner {
        require(studentsExists(_id), "Not found");
        uint256 idx = indexOf[_id];
        uint256 lastIdx = students.length - 1;
        if (idx != lastIdx) {
            // move last into idx
            Student storage last = students[lastIdx];
            students[idx] = last;
            indexOf[last.id] = idx;
        }
        students.pop();
        delete indexOf[_id];
        emit StudentRemoved(_id);
    }

    // view one student
    function getStudent(uint256 _id) external view returns (uint256 id, string memory name, uint8 age, string memory course) {
        require(studentsExists(_id), "Not found");
        Student storage s = students[indexOf[_id]];
        return (s.id, s.name, s.age, s.course);
    }

    // list all student ids
    function listStudentIds() external view returns (uint256[] memory) {
        uint256 n = students.length;
        if (n <= 1) return new uint256;
        uint256[] memory ids = new uint256[](n - 1);
        for (uint256 i = 1; i < n; i++) ids[i - 1] = students[i].id;
        return ids;
    }

    // helper
    function studentsExists(uint256 _id) public view returns (bool) {
        uint256 idx = indexOf[_id];
        if (idx == 0) return false;
        return students[idx].exists;
    }

    // Allow contract to receive ETH via `send`/`transfer`/`call` without data
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Fallback for calls with data or that do not match any function
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
}
