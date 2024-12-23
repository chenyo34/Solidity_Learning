// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './IERC20.sol';
import './ERC20.sol';

contract Airdrop {

    function getSum(uint256[] calldata _arr) public pure returns(uint256){
        uint256 sum = 0;
        for(uint i = 0; i<_arr.length;i++){
            sum += _arr[i];
        }
        return sum;
    }
    function multiTransferToken(address _token,
                                address[] calldata _address,
                                uint256[] calldata _amount) external {
        
        require(_address.length == _amount.length, "Length of addresses and assigned aidrops are diff.");
        IERC20 token = IERC20(_token);
        uint _total = getSum(_amount);
        require(_total <= token.allowance(msg.sender,address(this)), "Need approve more Token!!!");

        for (uint j = 0; j < _address.length; j++){
            token.transferFrom(address(this),
                            _address[j],
                            _amount[j]);
        }

    }
    function multiTransferETH(address payable[] calldata _addresses,
                            uint256[] calldata _amounts) public payable {
        
        require(_addresses.length == _amounts.length, "Length of addresses and assigned aidrops are diff.");
        uint _total = getSum(_amounts);
        require(_total == msg.value, "Not enough ETH to complete the transfer!!!");
        for(uint i = 0;i < _amounts.length;i++ ){
            _addresses[i].transfer(_amounts[i]);
        }

    }
}