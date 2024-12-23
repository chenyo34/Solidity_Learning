// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './IERC20.sol';
import './ERC20.sol';

contract Faucet {

    /* State Variables */
    uint256 public amountAllowed = 100;
    address public tokenContract;
    mapping (address => bool) public requestedAdress;

    /* Events */
    event SendToken(address indexed Receiver, uint256 indexed amount);

    constructor(address _tokenContract){
        tokenContract = _tokenContract; 
    }

    function requestTokens() external {
        require(requestedAdress[msg.sender] == false, "Multiple Ask!!!");
        IERC20 token = IERC20(tokenContract);
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!!!");

        token.transfer(msg.sender, amountAllowed);
        requestedAdress[msg.sender] == true;

        emit SendToken(msg.sender, amountAllowed);
    }

}