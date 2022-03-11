// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract PersonAC {
    // Variables
    enum State {
        NOT_INITIATED,
        AWAITING_DEPOSIT,
        DEPOSITED,
        TRANSFERED
    }

    State public currentState;

    bool public isPersonAAgree;
    bool public isPersonCAgree;

    uint256 amount;

    address public personA;
    address payable public personC;

    // Modifiers
    modifier onlyPersonA() {
        require(msg.sender == personA, "Only person A can call this function");
        _;
    }

    modifier onlyPersonC() {
        require(msg.sender == personC, "Only person C can call this function");
        _;
    }

    // Functions
    constructor(address _personA, address payable _personC) {
        personA = _personA;
        personC = _personC;
    }

    function initiateContract() public {
        if (msg.sender == personA) isPersonAAgree = true;
        if (msg.sender == personC) isPersonCAgree = true;
        if (isPersonCAgree && isPersonCAgree) {
            currentState = State.AWAITING_DEPOSIT;
        }
    }

    function depositFund() public payable onlyPersonA {
        require(currentState == State.AWAITING_DEPOSIT, "Already deposit");
        amount = msg.value;
        currentState = State.DEPOSITED;
    }

    function guessAmount(uint256 _amount) public payable onlyPersonC {
        require(amount == _amount, "Amount didn't match, please try again");
        payable(msg.sender).transfer(amount);
        currentState = State.TRANSFERED;
    }

    function withdraw() public payable onlyPersonA {
        require(currentState == State.DEPOSITED, "Can't withdraw now");
        payable(msg.sender).transfer(amount);
        currentState = State.AWAITING_DEPOSIT;
    }
}
