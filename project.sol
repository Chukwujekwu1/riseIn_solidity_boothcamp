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
}
