// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Escrow {
    // Variables
    enum State {
        NOT_INITIATED,
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE
    }

    State public currState;

    bool public isBuyerIn;
    bool public isSellerIn;

    uint256 public price;

    address public buyer;
    address payable public seller;

    // Modifiers
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier escrowNotStarted() {
        require(currState == State.NOT_INITIATED);
        _;
    }

    // Functions
    constructor(
        address _buyer,
        address payable _seller,
        uint256 _price
    ) {
        buyer = _buyer;
        seller = _seller;
        price = _price * (1 ether);
    }

    function initContract() public escrowNotStarted {
        if (msg.sender == buyer) {
            isBuyerIn = true;
        }
        if (msg.sender == seller) {
            isSellerIn = true;
        }
        if (isBuyerIn && isSellerIn) {
            currState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() public payable onlyBuyer {
        require(currState == State.AWAITING_PAYMENT, "Already Paid");
        require(msg.value == price, "Wrong deposite amount, start again!");

        currState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() public payable onlyBuyer {
        require(currState == State.AWAITING_DELIVERY, "Can't confirm delivery");
        seller.transfer(price);
        currState = State.COMPLETE;
    }

    function withdraw() public payable onlyBuyer {
        require(currState == State.AWAITING_DELIVERY, "Can't withdraw now");
        payable(msg.sender).transfer(price);
        currState = State.COMPLETE;
    }
}
