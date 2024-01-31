// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract vote {
    address owner;
    uint private counter;

    struct Proposal {
        string title; // title of proposal
        string description; // descripition of proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    //  this map stores the proposal after people have voted
    mapping(uint => Proposal) Proposal_history;

    // this array stores the address of people that voted
    address[] private voted_addresses;

    // note msg.sender is the address of the account that calls the smart contract
    // a construct only runs once. and this is when the smart contract is deployed
    constructor() {
        owner = msg.sender;
        /* added the account used to deploy the smart contract to the voted_addresses array
         so he woundn't be able to vote.
        */
        voted_addresses.push(msg.sender);
    }

    //  this is an access modifier that only allow a function to run if the condition is true else it displays an error message
    modifier onlyowner() {
        require(
            msg.sender == owner,
            "Only contract owner can perform this action"
        );
        _;
    }

    //  this checks if the voting is still active before it allows the function to run
    modifier active() {
        require(
            Proposal_history[counter].is_active == true,
            "Voting has ended"
        );
        _;
    }

    //  this function loops through the array voted_adddresses to check if an address has voted
    function isVoted(address _addr) public view active returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    // this allow only people who have voted to run the function
    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has not voted");
        _;
    }

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyowner {
        counter += 1;
        Proposal_history[counter] = Proposal(
            _title,
            _description,
            0,
            0,
            0,
            _total_vote_to_end,
            false,
            true
        );
    }

    function voter(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = Proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice >= 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if (
            (proposal.total_vote_to_end - total_vote == 1) &&
             (choice >= 0 || choice <= 2)
        ) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    function terminateProposal() external onlyowner active {
        Proposal_history[counter].is_active = false;
    }


    function calculateCurrentState() private view returns (bool) {
    Proposal storage proposal = Proposal_history[counter];

    uint256 approve = proposal.approve;
    uint256 reject = proposal.reject;
    uint256 pass = proposal.pass;

    // Increment pass by 1 if it's an odd number
    pass += pass % 2;

    pass /= 2;

    return approve > reject + pass;
    }

       function getCurrentProposal() external view returns(Proposal memory) {
        return Proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
        return Proposal_history[number];
    }

}
