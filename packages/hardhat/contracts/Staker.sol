// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  bool openForWithdraw = false;
  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  event Stake (address staker, uint256 amount);
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;
  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake () payable public {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  modifier timeElaps () {
    require (block.timestamp > deadline, "Time has not elapsed yet");
    _;
  }
   modifier set_withdraw () {
     if(address(this).balance < threshold) {
       openForWithdraw = true;
     }
     require(openForWithdraw == true, "Can't withdraw now");
    _;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function excute() public timeElaps {
      require(address(this).balance >= threshold, "Total Stake isn't equal to threshold");
      exampleExternalContract.complete{value: address(this).balance}();
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `withdraw()` function to let users withdraw their balance
 function withdraw() public timeElaps set_withdraw {
     uint256 userBalance = balances[msg.sender];

    // check if the user has balance to withdraw
    require(userBalance > 0, "You don't have balance to withdraw");

    // reset the balance of the user
    balances[msg.sender] = 0;

    // Transfer balance back to the user
    (bool sent,) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  } 

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
      if(block.timestamp >= deadline) {
        return 0;
      }
      return deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
      stake();
  }

}
