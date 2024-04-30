App = {
    web3Provider: null,
    contracts: {},

    init: async function () {
        // Load Web3
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider;
            web3 = new Web3(web3.currentProvider);
        } else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
            web3 = new Web3(App.web3Provider);
        }

        return App.initContract();
    },

    initContract: async function () {
        $.getJSON('User.json', function (userArtifact) {
            App.contracts.User = TruffleContract(userArtifact);
            App.contracts.User.setProvider(App.web3Provider);
            App.contracts.User.deployed().then(function (instance) {
                console.log('User contract address:', instance.address);
            });
        });

        $.getJSON('Poll.json', function (pollArtifact) {
            App.contracts.Poll = TruffleContract(pollArtifact);
            App.contracts.Poll.setProvider(App.web3Provider);
            App.contracts.Poll.deployed().then(function (instance) {
                console.log('Poll contract address:', instance.address);
            });
        });

        addEventListeners();
    },
};

// Event listeners
function addEventListeners() {
    document.getElementById('signupBtn').addEventListener('click', signUp);
    document.getElementById('loginBtn').addEventListener('click', login);
    document.getElementById('createPollBtn').addEventListener('click', createPoll);
    document.getElementById('voteBtn').addEventListener('click', vote);
    document.getElementById('finishPollBtn').addEventListener('click', finishPoll);
}

// Functions
async function signUp() {
    const username = document.getElementById('username').value;
    const companyId = parseInt(document.getElementById('companyId').value) || 0;

    // Call the sign up function in the user contract
    await App.contracts.User.deployed().then(async function (instance) {
        console.log('Signing up user:', username, companyId, ethereum.selectedAddress);
        await instance.signUp(username, companyId, { from: ethereum.selectedAddress });

        // Hide user authentication section, show poll section
        document.getElementById('userAuthSection').style.display = 'none';
        document.getElementById('pollSection').style.display = 'block';
        console.log('User signed up successfully.');
    }).catch(function (err) {
        console.error('Error signing up user:', err);
    }
    );
}

async function login() {
    // Login logic
    const username = document.getElementById('username').value;

    // Check if the user exists
    await App.contracts.User.deployed().then(async function (instance) {
        const userAddress = await instance.getUserByUsername(username);
        if (userAddress !== '0x0000000000000000000000000000000000000000') {
            // Set the selected address
            ethereum.selectedAddress = userAddress;

            // Hide user authentication section
            document.getElementById('userAuthSection').style.display = 'none';

            // Fetch and display the list of polls for voting
            await fetchAndDisplayPolls();

            // Show the poll section for voting
            document.getElementById('pollSection').style.display = 'block';
        } else {
            // Display an error message
            console.error('User does not exist. Please sign up first.');
        }
    }).catch(function (err) {
        console.error('Error logging in:', err);
    });
}

async function createPoll() {
    // try {
        const question = document.getElementById('question').value;
        const option1 = document.getElementById('option1').value;
        const option2 = document.getElementById('option2').value;

        // Check if the question and options are not empty
        if (question.trim() === '' || option1.trim() === '' || option2.trim() === '') {
            console.error('Question and options cannot be empty.');
            return;
        }
        // Obtain the contract instance using Truffle's contract abstraction
        await App.contracts.Poll.deployed().then(async function (instance) {
            // Call the createPoll function of the Poll contract
            await instance.createPoll(question, { from: ethereum.selectedAddress });
            const pollId = await instance.pollCount().then(count => count.toNumber());
            console.log('Poll created with ID:', pollId);

            // Add options to the latest poll
            await instance.addOption(pollId, option1, { from: ethereum.selectedAddress });
            console.log('Option 1 added to poll with ID:', pollId );

            await instance.addOption(pollId, option2, { from: ethereum.selectedAddress });
            console.log('Option 2 added to poll with ID:', pollId);
        });
    // } catch (err) {
    //     console.error('Error creating poll:', err);
    // }
    await fetchAndDisplayPolls();
}

async function fetchAndDisplayPolls() {
    // Fetch and display polls
    const pollSelect = document.getElementById('pollSelect');
    pollSelect.innerHTML = '';

    // Fetch the number of polls
    await App.contracts.Poll.deployed().then(async function (instance) {
        const pollCount = await instance.pollCount().then(count => count.toNumber());
        // Loop through each poll and add it to the select options
        for (let i = 1; i <= pollCount; i++) {
            const poll = await instance.polls(i);
            const option = document.createElement('option');
            option.text = poll.question;
            option.value = i;
            pollSelect.add(option);
        }
    }).catch(function (err) {
        console.error('Error fetching and displaying polls:', err);
    });
}

async function vote() {
    // Vote logic
    const pollId = document.getElementById('pollSelect').value;
    const selectedOptionIndex = document.getElementById('voteOptions').value;
    // Call the vote function in the poll contract
    await App.contracts.Poll.deployed().then(async function (instance) {
        await instance.vote(pollId, selectedOptionIndex, { from: ethereum.selectedAddress });
    }).catch(function (err) {
        console.error('Error voting:', err);
    });
    // Optionally, you can update the UI to reflect the vote
}

async function finishPoll() {
    // Finish poll logic
    const pollId = document.getElementById('pollManagementSelect').value;
    // Call the finish poll function in the poll contract
    await App.contracts.Poll.deployed().then(async function (instance) {
        await instance.finishPoll(pollId, { from: ethereum.selectedAddress });
    }).catch(function (err) {
        console.error('Error finishing poll:', err);
    });
    // Optionally, you can update the UI to reflect the finished poll
}

// Initialize the app
$(function () {
    $(window).on('load', function () {
        App.init();
    });
});