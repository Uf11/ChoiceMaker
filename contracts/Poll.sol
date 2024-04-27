pragma solidity ^0.5.0;

contract Poll {
    struct PollData {
        address creator;
        string question;
        string[] options;
        mapping(address => uint) votes;
        bool finished;
    }

    mapping(uint => PollData) public polls;
    uint public pollCount;

    event PollCreated(uint indexed pollId, string question);
    event PollOptionAdded(uint indexed pollId, string option);
    event PollFinished(uint indexed pollId, string question, uint[] results);

    function createPoll(string memory _question) public {
        require(bytes(_question).length > 0, "Question cannot be empty");

        pollCount++;
        polls[pollCount].creator = msg.sender;
        polls[pollCount].question = _question;
        emit PollCreated(pollCount, _question);
    }

    function addOption(uint _pollId, string memory _option) public {
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(bytes(_option).length > 0, "Option cannot be empty");

        polls[_pollId].options.push(_option);
        emit PollOptionAdded(_pollId, _option);
    }

    function vote(uint _pollId, uint _optionIndex) public {
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(_optionIndex >= 0 && _optionIndex < polls[_pollId].options.length, "Invalid option index");
        require(polls[_pollId].votes[msg.sender] == 0, "Already voted");

        polls[_pollId].votes[msg.sender] = _optionIndex + 1;
    }

    function finishPoll(uint _pollId) public {
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(msg.sender == polls[_pollId].creator, "Only the creator can finish the poll");

        polls[_pollId].finished = true;

        // Emit event with results
        uint[] memory results = new uint[](polls[_pollId].options.length);
        for (uint i = 0; i < polls[_pollId].options.length; i++) {
            uint optionIndex = i + 1;
            uint voteCount = 0;
            for (uint j = 0; j < pollCount; j++) {
                if (polls[_pollId].votes[address(j)] == optionIndex) {
                    voteCount++;
                }
            }
            results[i] = voteCount;
        }
        emit PollFinished(_pollId, polls[_pollId].question, results);
    }
}
