pragma solidity ^0.5.0;

contract User {
    struct UserData {
        string username;
        address userAddress;
        uint companyId;
    }

    mapping(address => UserData) public users;
    mapping(uint => string) public companies;
    uint public companyCount;

    event UserCreated(address indexed userAddress, string username, uint companyId);

    function signUp(string memory _username, uint _companyId) public {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(users[msg.sender].userAddress == address(0), "User already exists");

        if (_companyId == 0) {
            companyCount++;
            companies[companyCount] = _username;
            _companyId = companyCount;
        }

        users[msg.sender] = UserData(_username, msg.sender, _companyId);
        emit UserCreated(msg.sender, _username, _companyId);
    }
}
