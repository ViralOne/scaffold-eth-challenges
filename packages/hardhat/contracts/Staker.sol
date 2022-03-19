// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  mapping ( address => uint256 ) balances;

  uint256 constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 30 seconds;

  bool private openForWithdraw = false;

  event Stake(address from, uint256 amount);

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  
  function stake() external payable{
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    openForWithdraw = true;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() external {
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else {
        // if the `threshold` was not met, allow everyone to call a `withdraw()` function
        openForWithdraw = true;
    }
  }

  // Add a `withdraw(address payable)` function lets users withdraw their balance
   function withdraw(address payable _to) external returns (bool){
      require(openForWithdraw, "Not open for withdraw");
      uint amount = balances[msg.sender];
      require(amount > 0, "user balance is 0");
      balances[msg.sender] = 0;
      (bool success, ) = _to.call{value: amount}("");
      require(success, "Failed to send to address");
   }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() external view returns (uint256){
    if (block.timestamp >= deadline) {
      return 0;
    }
    else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable  {
    this.stake();
  }
}
