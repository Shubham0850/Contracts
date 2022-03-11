// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity ^0.8.10;

contract Auction {
    address payable public auctioneer;
    uint256 public stblock;
    uint256 public etblock;

    enum Auc_state {
        Started,
        Running,
        Ended,
        Cancelled
    }
    Auc_state public auctionState;

    uint256 public highestBid;
    uint256 public highestPayableBid;
    uint256 public bidInc;

    address payable public highestBidder;

    mapping(address => uint256) public bids;

    constructor() {
        auctioneer = payable(msg.sender);
        auctionState = Auc_state.Running;
        stblock = block.number;
        etblock = stblock + 240;
        bidInc = 1 ether;
    }

    modifier notOwner() {
        require(msg.sender != auctioneer, "Owner can't bid");
        _;
    }

    modifier Owner() {
        require(msg.sender == auctioneer, "Only owner");
        _;
    }

    modifier started() {
        require(block.number > stblock);
        _;
    }

    modifier beforeEnd() {
        require(block.number < etblock);
        _;
    }

    function cancelAuction() public Owner {
        auctionState = Auc_state.Cancelled;
    }

    // for testing purpose
    function endAuction() public Owner {
        auctionState = Auc_state.Ended;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        if (a >= b) return b;
        else return a;
    }

    function bid() public payable notOwner started beforeEnd {
        require(auctionState == Auc_state.Running);
        require(msg.value >= 1 ether);

        uint256 currentBid = bids[msg.sender] + msg.value;

        require(currentBid > highestPayableBid);

        bids[msg.sender] = currentBid;

        if (currentBid < bids[highestBidder]) {
            highestPayableBid = min(currentBid + bidInc, bids[highestBidder]);
        } else {
            highestPayableBid = min(currentBid, bids[highestBidder] + bidInc);
            highestBidder = payable(msg.sender);
        }
    }

    function finalizeAuction() public {
        require(
            auctionState == Auc_state.Cancelled ||
                auctionState == Auc_state.Ended ||
                block.number >= etblock
        );
        require(msg.sender == auctioneer || bids[msg.sender] > 0);

        address payable person;
        uint256 value;

        if (auctionState == Auc_state.Cancelled) {
            person = payable(msg.sender);
            value = bids[msg.sender];
        } else {
            if (msg.sender == auctioneer) {
                person = auctioneer;
                value = highestPayableBid;
            } else {
                if (msg.sender == highestBidder) {
                    person = highestBidder;
                    value = bids[highestBidder] - highestPayableBid;
                } else {
                    person = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        person.transfer(value);
    }
}
