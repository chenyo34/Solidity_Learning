// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './IERC20.sol';

contract ERC20 is IERC20 {
    /*
     *State Variables
     */
    mapping (address => uint256) public override balanceOf;

    mapping (address => mapping (address => uint256)) public override allowance;

    uint256 public override totalSupply;

    string public tokenName;

    string public symbol;

    uint8 public decimals;

    constructor(string memory _tokenName, string memory _symbol){
        tokenName = _tokenName;
        symbol = _symbol;
    }
    

    function transfer(address _to_account, uint256 value) public override returns (bool){
        // Assert the calling account has enough tokens to send value-worth token to _to account

        if (balanceOf[msg.sender] < value){
            return false;
        }
        // OR require(balanceOf[msg.sender] >= value, "Token is not enough to make this transfer!!!");

        balanceOf[msg.sender] -= value;
        balanceOf[_to_account] += value;
        emit Transfer(msg.sender, _to_account, value);
        return true;
    }

    function approve(address _spender, uint256 value) public override returns (bool){
        
        if (balanceOf[msg.sender] < value){
            return false;
        }
        // OR require(balanceOf[msg.sender] >= value, "Token is not enough to make this transfer!!!");
        allowance[msg.sender][_spender] = value;
        emit Approval(msg.sender, _spender, value);
        return true;

    }

    function transferFrom(address _from,
                            address _to,
                            uint256 value) public override returns (bool){

        if ( (balanceOf[_from] >= value) && (allowance[_from][_to] >= value)){
            allowance[_from][_to] -= value;
            balanceOf[_from] -= value;
            balanceOf[_to] += value;
            emit Transfer(_from, _to, value);
            return true;
        } else {
            return false;
        }
    
    }

    function mint(uint256 amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}

