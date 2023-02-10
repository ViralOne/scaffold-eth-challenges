pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
  
  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable{
    uint256 amountOfTokensToBuy = msg.value  * tokensPerEth;
    yourToken.transfer(msg.sender, amountOfTokensToBuy);
    emit BuyTokens(msg.sender, msg.value, amountOfTokensToBuy);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
   function withdraw() external onlyOwner{
    (bool success, ) = msg.sender.call{value: address(this).balance/2}("");
    require(success, 'Unable to withdraw');
   }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokensToSell) external{
    require(yourToken.balanceOf(msg.sender) >= tokensToSell, "You don't have enough tokens to sell");
    yourToken.transferFrom(msg.sender, address(this), tokensToSell);
    (bool success, ) = msg.sender.call{value: tokensToSell/tokensPerEth}("");
    require(success, 'Unable to sell');
  }

}
