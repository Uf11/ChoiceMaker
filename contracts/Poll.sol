pragma solidity ^0.8.0;

contract Poll {
    struct PollData {
        address creator;
        string question;
        string[] options;
        mapping(address => uint256) votes;
        bool finished;
    }

    mapping(uint256 => PollData) public polls;
    uint256 public pollCount;

    event PollCreated(uint256 indexed pollId, string question); 
    event PollOptionAdded(uint256 indexed pollId, string option, string option2); 
    event PollFinished(uint256 indexed pollId, string question, uint256[] results); 

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
        emit PollOptionAdded(_pollId, _option, polls[_pollId].options[0]);
    }

    function vote(uint256 _pollId, uint256 _optionIndex) public { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
        require(_optionIndex < polls[_pollId].options.length, "Invalid option index"); // Removed check for _optionIndex >= 0
        require(polls[_pollId].votes[msg.sender] == 0, "Already voted");

        polls[_pollId].votes[msg.sender] = _optionIndex + 1;
    }

    function getPollOptions(uint256 _pollId) public view returns (string[] memory) { 
        require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");

        // Fetch the poll from the mapping using the _pollId
        PollData storage poll = polls[_pollId];

        // Return the options array from the poll
        return poll.options;
    }

    // function finishPoll(uint256 _pollId) public { 
    //     require(_pollId > 0 && _pollId <= pollCount, "Invalid poll ID");
    //     require(msg.sender == polls[_pollId].creator, "Only the creator can finish the poll");

    //     polls[_pollId].finished = true;

    //     // Emit event with results
    //     uint256[] memory results = new uint256[](polls[_pollId].options.length);
    //     for (uint256 i = 0; i < polls[_pollId].options.length; i++) {
    //         uint256 optionIndex = i + 1;
    //         uint256 voteCount = 0;
    //         for (uint256 j = 0; j < pollCount; j++) {
    //             if (bytes(polls[_pollId].question).length > 0) {
    //                 voteCount++;
    //             }
    //         }
    //         results[i] = voteCount;
    //     }
    //     emit PollFinished(_pollId, polls[_pollId].question, results);
    // }
}
