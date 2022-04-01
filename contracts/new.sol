// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CpToken is ERC20 {
    constructor() ERC20("CpToken", "CPY") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}

contract PersonAC {
     // Variables
    enum State{NOT_INITIATED, AWAITING_DEPOSIT, APPROVED, TRANSFERED}

    State public currentState;

    bool public isPersonAAgree;
    bool public isPersonCAgree;

    uint256 public amount;

    address public personA;
    address payable public personC;

    IERC20 public token;

    // Modifiers
    modifier onlyPersonA(){
        require(msg.sender == personA, "Only person A can call this function");
        _;
    }

    modifier onlyPersonC(){
        require(msg.sender == personC, "Only person C can call this function");
        _;
    }

   // Functions
    constructor(address _personA, address payable _personC){
        personA = _personA;
        personC = _personC;
        token = new CpToken();
    }
    
    function initiateContract() public {
        if(msg.sender == personA)
            isPersonAAgree = true;
        if(msg.sender == personC)
            isPersonCAgree = true;
        if(isPersonCAgree && isPersonCAgree){
            currentState = State.AWAITING_DEPOSIT;
        }
    }

    // Make a use of Approve 
    function approveFunds(uint256 _amount) public payable onlyPersonA{
        require(currentState == State.AWAITING_DEPOSIT, "Already deposit");
        amount = _amount;
        token.allowance(personA, address(this));
        token.approve(address(this), _amount);
        currentState = State.APPROVED;
    }

    // Make a use of transferFrom
    function guessAmount(uint _guess) public payable onlyPersonC{
        require(amount == _guess, "Number didn't match, please try again");
        token.transferFrom(personA, personC, amount - 100000000);
        currentState = State.TRANSFERED;
    }
}