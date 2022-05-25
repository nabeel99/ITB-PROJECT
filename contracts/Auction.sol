// SPDX-License-Identifier: GPL-3.0
import "hardhat/console.sol";
pragma solidity=0.8.14;
/**
@title Auction House, 
@author Nabeel Naveed,
@notice It is a simple Auction house, where each user bids an amount, the highest bid is tored, once the end time 
ends the highest bid at that time the owner recieves the highest bid and the rest of the bidders can claim back there funds





 */

contract Auction {
    //@notice describes the current state of the Auction

    enum AuctionStatus { InActive, Active, Cancelled, Complete }

    /**
    @notice user struct stores each user address,uint,uint
    @param amountBid, mapping takes in a auction id and returns the amount user has bid in that auction

     */
    struct User {
        mapping(uint=>uint) amountBid;
    }
    ///@notice stores each auction start date,end date and the current maxBid of that auction
    struct auctionX{
        uint ID;
        uint startDate;
        uint endDate;
        uint minBid;
        uint maxBid;
        address winnerSoFar;
        AuctionStatus currentStatus ;
    }
    mapping(uint=>auctionX) public Auctions;
    mapping(address=>User)  bids;
    address public owner;
    uint  counter;
    constructor (address _owner) {
        owner = _owner;
    }
    function getBids(address x,uint _ID) external view returns(uint) {
        return bids[x].amountBid[_ID];
    }
    ///@notice onlyOwner Modifier called before , in functions using this modifier
    modifier onlyOwner() {
        require(msg.sender==owner,"Only owner");
        _;
    }
    ///@notice auctionCreation checks carries out basic checks on the configuration of the auction
    modifier auctionCreationChecks(uint startDate,uint endDate, uint minBid) {
        require(startDate>=block.timestamp,"start date cannot be less than the current time");
        require(endDate>startDate,"end date cannot be less than the start date");
        require(minBid>0 ether,"no zero min allowed");
        _;
    }
    ///@notice auctionAction modifier , checks basic properties
    modifier auctionInteractionChecks(auctionX memory checkAuction) {
        require(checkAuction.currentStatus!=AuctionStatus.Active,"Already activated");
        require(checkAuction.currentStatus!=AuctionStatus.Cancelled,"Cancelled");
        require(checkAuction.currentStatus!=AuctionStatus.Complete,"Completed");
        require(block.timestamp>=checkAuction.startDate,"there is still time for the auction");
        require(block.timestamp<checkAuction.endDate,"Auction has ended");
        _;
    }
    modifier auctionCancelChecks(auctionX memory checkAuction) {
        require(checkAuction.currentStatus!=AuctionStatus.InActive,"not active");
       require(checkAuction.currentStatus!=AuctionStatus.Cancelled,"Cancelled");
        require(checkAuction.currentStatus!=AuctionStatus.Complete,"Completed");
        require(block.timestamp>=checkAuction.startDate,
        "there is still time for the auction to start");
        require(block.timestamp<checkAuction.endDate,"Auction has ended");
        _;
    }
    ///@notice auctionBidChecks modifier , checks basic properties
    modifier auctionBidChecks(auctionX memory checkAuction) {
        console.log("msg value is ",msg.value);
        console.log("current status is",uint(checkAuction.currentStatus));
        console.log("mint bid is",checkAuction.minBid);
        console.log(block.timestamp>=checkAuction.startDate);
        console.log(block.timestamp<checkAuction.endDate);
        require(checkAuction.currentStatus==AuctionStatus.Active,"Contract is Inactive");
        require(block.timestamp>=checkAuction.startDate,"there is still time for the auction");
        require(block.timestamp<checkAuction.endDate,"Auction has ended");
        _;
    }

    ///@notice this function allows the creator to create an auction
    ///@param _startDate, specifies the startDate of the auction
    ///@param _endDate , specified the endDate of the auction,
    ///@param _minBid, specifies the minbid for the auction

    function createAuction(uint _startDate,uint _endDate,uint _minBid) external 
    onlyOwner auctionCreationChecks(_startDate,_endDate,_minBid){
        uint _counter = counter;
        auctionX memory newAuction;
        newAuction.ID = _counter;
        newAuction.startDate = _startDate;
        newAuction.endDate = _endDate;
        newAuction.minBid = _minBid ;
        newAuction.currentStatus = block.timestamp>=_startDate? AuctionStatus.Active:AuctionStatus.InActive;
        Auctions[_counter] = newAuction;
        counter++;         
    }
    ///@notice startAuction, checks if the auction start time > block.timestamp set its status to Active
    function startAuction(uint _ID) external onlyOwner() auctionInteractionChecks(Auctions[_ID]) {
        auctionX memory tempAuction = Auctions[_ID];
        
        tempAuction.currentStatus = AuctionStatus.Active;
        Auctions[_ID]= tempAuction;
    }
    function cancelAuction(uint _ID) external onlyOwner() auctionCancelChecks(Auctions[_ID]) {
        Auctions[_ID].currentStatus==AuctionStatus.Cancelled;
    }
    ///@notice placeBid, expects a msg value more than min bid,
    ///@param _ID, id of the auction the user wishes to bid,
    function placeBid(uint _ID) external payable auctionBidChecks(Auctions[_ID]) {
        console.log("msg value is ",msg.value);
        auctionX memory auction = Auctions[_ID];
        require(msg.value>=auction.minBid,"min bid required");
        uint increment = auction.maxBid + auction.minBid;
        
        require(msg.value>increment ,"value should be more than current max bid");
        auction.maxBid = msg.value;
        auction.winnerSoFar = msg.sender;
        bids[msg.sender].amountBid[_ID] = msg.value;
        Auctions[_ID] = auction;
    }
        ///@notice withdraw, allows owner to withdraw the maxBid of any auction whose status is complete,
        ///@param _ID, auction id

    function withdraw(uint _ID)  external onlyOwner  {
        auctionX memory  auction = Auctions[_ID];

        require(auction.currentStatus==AuctionStatus.Complete,"require auction not complete yet");
        (bool success,) =   msg.sender.call{value:auction.maxBid}("");
        require(success,"withdraw failed");
    }
    function claimBid(uint _ID) external {
        auctionX memory auction = Auctions[_ID];
        require(auction.currentStatus==AuctionStatus.Complete||auction.currentStatus==AuctionStatus.Cancelled,"cant claim"); 
       (bool success,) =   msg.sender.call{value:bids[msg.sender].amountBid[_ID]}("");
       require(success,"claim failed");
    }
    function resolveAuction(uint _ID) public {
        auctionX memory auction = Auctions[_ID];
        require(block.timestamp>=auction.endDate,"Auction has not ended yet");
        require(auction.currentStatus==AuctionStatus.Active,"Not Active");        

        auction.currentStatus = AuctionStatus.Complete;
        Auctions[_ID] = auction;
    }




   
}