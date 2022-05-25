// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";


contract ICO {
	address public owner;
	address public tokenAddress;
	uint public startTime;
	uint public endTime;
	uint public price = 0.001 ether;
	uint public raisedAmount;
	uint public hardCap = 1 ether;
	uint public minInvestment = 0.01 ether;
	uint public maxInvestment = 0.2 ether;
	
	constructor(address tokenAddress_ , uint startTime_, uint endTime_) {
		tokenAddress = tokenAddress_;	
		require(startTime_ < endTime_, "start time > end time");
		require(startTime_ >= block.timestamp, "start time >= current time");
		owner = msg.sender;
		startTime = startTime_;
		endTime = endTime_;
	}
	
	modifier onlyOwner {
		require(owner == msg.sender, "caller is not the owner");
        _;
	}

	modifier activeSale() {
		require(block.timestamp >= startTime, "sale has not started yet");
		require(block.timestamp <= endTime, "sale has ended");
		require(raisedAmount < hardCap, "hard cap reached");
		_;
	}

	modifier validAmount {
		require(msg.value >= minInvestment, "minimum investment is not met");
		require(msg.value <= maxInvestment, "maximum investment is exceeded");
		_;
	}

	function buy() activeSale validAmount external payable {
		uint amountOfTokens = (10**(IERC20Metadata(tokenAddress).decimals())) * (msg.value / price);
		require(msg.value < hardCap, "amount exceeds hard cap");
		IERC20(tokenAddress).transfer(msg.sender, amountOfTokens);
		raisedAmount += msg.value;
	}

	// Owner can withdraw deposited ether
	function withdrawEther() external onlyOwner {
		require(block.timestamp >= endTime, "cannot withdraw ether before end time");
        (bool success,) = owner.call{value:raisedAmount}("");
        require(success,"withdraw failed");
    }
    ///@notice no need for a recieve function to explicitly deny a normal eth transfer to the contract
    ///as if a contract does not have recieve or fallback it cannot accept a normal eth transfer
    //  receive() external payable {
    //     require(false,"please use the correct function to buy tokens");
    // }
}