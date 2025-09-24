// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

contract StudentData {

    // Structure to store student information
    struct Student {
        uint256 id;
        string name;
        uint8 age;
        string course;
    }

    // Array to store multiple students
    Student[] public students;

    // Event for logging
    event StudentAdded(uint256 id, string name);

    // Function to add a new student
    function addStudent(uint256 _id, string memory _name, uint8 _age, string memory _course) public {
        Student memory newStudent = Student({
            id: _id,
            name: _name,
            age: _age,
            course: _course
        });

        students.push(newStudent);
        emit StudentAdded(_id, _name);
    }

    // Function to get total number of students
    function getStudentCount() public view returns (uint256) {
        return students.length;
    }

    // Function to get a student by index
    function getStudent(uint256 index) public view returns (uint256, string memory, uint8, string memory) {
        require(index < students.length, "Invalid index");
        Student storage s = students[index];
        return (s.id, s.name, s.age, s.course);
    }

    // Fallback function to accept ether
    fallback() external payable {
        // Do nothing, just accept ETH
    }

    receive() external payable {
        // Optional: handle plain ETH transfers
    }

    // Function to get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}