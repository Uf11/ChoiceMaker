pragma solidity ^0.8.0;

contract Poll {
    struct PollData {
        address creator;
        string question;
        string[] options;
        uint256 companyId;
        mapping(address => uint256) voters;
        mapping(uint256 => uint256) votes;
        bool finished;
    }

    mapping(uint256 => PollData) public polls;
    uint256 public pollCount;

    event PollCreated(uint256 indexed pollId, string question); 
    event PollOptionAdded(uint256 indexed pollId, string option, string option2); 
    event PollVoted(uint256 indexed pollId, address voter, uint256 optionIndex);
    event PollFinished(uint256 indexed pollId, string question); 

    function createPoll(string memory _question) public {
        pollCount++;
        polls[pollCount].creator = msg.sender;
        polls[pollCount].question = _question;
        emit PollCreated(pollCount, _question);
    }

    function addPollOption(uint256 _pollId, string memory _option) public { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(bytes(_option).length > 0, "Option cannot be empty");
        require(msg.sender == polls[_pollId].creator, "Only the creator can add options");
        polls[_pollId].options.push(_option);

        uint lastIndex = polls[_pollId].options.length-1;

        emit PollOptionAdded(_pollId, _option, polls[_pollId].options[lastIndex]);
    }

    function vote(uint256 _pollId, uint256 _optionIndex) public { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(_optionIndex < polls[_pollId].options.length, "Invalid option index"); // Removed check for _optionIndex >= 0
        require(polls[_pollId].voters[msg.sender] == 0, "You have already voted");

        polls[_pollId].voters[msg.sender] = _optionIndex + 1;
        polls[_pollId].votes[_optionIndex]++;
        emit PollVoted(_pollId, msg.sender, _optionIndex);
    }

    function getPollOption(uint256 _pollId, uint256 _optionId) public view returns (string memory) { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");

        // Fetch the poll from the mapping using the _pollId
        PollData storage poll = polls[_pollId];

        // Return the options array from the poll
        return poll.options[_optionId];
    }

    function finishPoll(uint256 _pollId) public { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(msg.sender == polls[_pollId].creator, "Only the creator can finish the poll");
        require(!polls[_pollId].finished, "Poll already finished");

        polls[_pollId].finished = true;
        emit PollFinished(_pollId, polls[_pollId].question);
    }

    function getPollResults(uint256 _pollId, uint256 _optionId) public view returns (uint256) { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(polls[_pollId].finished, "Poll not finished");

        PollData storage poll = polls[_pollId];

        uint256[] memory results = new uint256[](2);

        for (uint256 i = 0; i < 2; i++) {
            results[i] = poll.votes[i];
        }

        // Return the array of vote counts
        return results[_optionId];
    }

}
