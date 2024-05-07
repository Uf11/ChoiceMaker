pragma solidity ^0.8.0;

contract User {
    struct UserData {
        string username;
        address userAddress;
        uint256 companyId; 
    }

    mapping(address => UserData) public users;
    mapping(uint256 => string) public companies; 
    uint256 public companyCount; 

    event UserCreated(address indexed userAddress, string username, uint256 companyId); 
    event UserLoggedIn(address indexed userAddress, string username, uint256 companyId); 

    function signUp(string memory _username, uint256 _companyId) public {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(users[msg.sender].userAddress == address(0), "User already exists");
        require(bytes(users[msg.sender].username).length == 0, "User already exists");
        require(users[msg.sender].companyId == 0, "User already exists");

        if (_companyId == 0) {
            companyCount++;
            companies[companyCount] = _username;
            _companyId = companyCount;
        }

        users[msg.sender] = UserData(_username, msg.sender, _companyId);
        emit UserCreated(msg.sender, _username, _companyId);
    }

    function getUserByAddress() public view returns (string memory username, uint256 companyId) { 
        UserData memory user = users[msg.sender];
        return (user.username, user.companyId);
    }
}
