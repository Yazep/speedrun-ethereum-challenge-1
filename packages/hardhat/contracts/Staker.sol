// SPDX-License-Identifier: MIT
pragma solidity  0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  //Errors
  error Staker__AmountShouldBeMoreThanZero();
  error Staker__TranferFailed();
  error Staker__DeadlineNotPassed();
  error Staker_ContractNotExecuted();
  error Staker__WithdrawNotAllowed();
  error  Staker__NobalancesTOWithdraw();
  error Staker__WithdrawFailed();
  error Staker_contractNotCompleted();

  ExampleExternalContract public exampleExternalContract;

  //Variables
  mapping (address => uint256) public balances;

  uint256 public constant threshold =1 ether; 
  uint256 public deadline ;
  bool public openForWithdraw;

  //Events
  event Stake(address indexed stakerAddress,uint256 indexed stakerAmount);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
      openForWithdraw = false;
  }

  //Modifier

  modifier notCompleted {
    if (!exampleExternalContract.completed()) {
      revert Staker_contractNotCompleted();
    }
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balancess` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  function stake() public payable {
    if (msg.value <=0) {
      revert Staker__AmountShouldBeMoreThanZero();
    }
    _stake(msg.value,msg.sender);
  }

  function _stake(uint256 amount, address sender)  internal {
    balances[sender]+=amount;
    emit Stake(sender,amount);
  }
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balances}()`

  function execute() public {
    if (block.timestamp<deadline) {
      revert Staker__DeadlineNotPassed();
    }
    if (address(this).balance>=threshold) {
    exampleExternalContract.complete{value: address(this).balance}();
    openForWithdraw =false;
    deadline = block.timestamp + 30;
    } else {
      openForWithdraw = true;
    }

  }

  function withdraw() public 
  {if (!openForWithdraw){
    revert Staker__WithdrawNotAllowed();}
  uint256 amount = balances[msg.sender];

  if (balances[msg.sender]<=0) {
    revert Staker__NobalancesTOWithdraw();
  }

  balances[msg.sender]=0;
  (bool success,) = msg.sender.call{value:amount}("");
  if( !success) {
    revert Staker__WithdrawFailed();
  }
  }

   receive() external payable {
    _stake(msg.value,msg.sender);

  } 

  
  //View funcitons

  function timeLeft() public view returns(uint256){
    if (block.timestamp >= deadline) { return  0 seconds;} 
    else
    {
    return (deadline-block.timestamp);
    }
     
  }
 
  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balances


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
