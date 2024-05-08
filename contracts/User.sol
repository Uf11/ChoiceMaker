pragma solidity ^0.8.0;

contract User {
    struct UserData {
        string username;
        address userAddress;
        uint256 companyId; 
    }

    mapping(uint256 => bool) public companyExists;
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
        if(companyExists[_companyId]==false){
            companyCount++;
            companyExists[_companyId] = true;
        }

        users[msg.sender] = UserData(_username, msg.sender, _companyId);
        emit UserCreated(msg.sender, _username, _companyId);
    }

    function getUserByAddress() public view returns (string memory username, uint256 companyId) { 
        UserData memory user = users[msg.sender];
        return (user.username, user.companyId);
    }

    function checkCompanyExist(uint256 _companyId) public view returns (bool) { 
        return companyExists[_companyId];
    }
}
