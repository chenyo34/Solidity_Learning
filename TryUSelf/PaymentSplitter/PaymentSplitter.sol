// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * 分账合约 
 * @dev 这个合约会把收到的ETH按事先定好的份额分给几个账户。收到ETH会存在分账合约中，需要每个受益人调用release()函数来领取。
 */
 contract PaymentSplitter{

    /* Event */

    event PayeeAdded(address new_payee, uint256 shares);
    event PaymentReceived(address to_account, uint256 value);
    event PaymentReleased(address from_account, uint256 value);

    /* State Variables */
    uint256 public totalShares;
    uint256 public totalReleased;
    address[] public payees;
    mapping(address =>uint256) public shares;
    mapping(address=>uint256) public released;

    /* Function */
    constructor (
        address[] memory _payees,
        uint256[] memory _shares
    ) { 
        require(
            _payees.length == _shares.length,
            "Lenght of payees and shares not match!!!"
        );
        require(
            _payees.length > 0,
            "No payee!!!"
        );
        for (uint256 i = 0; i < _shares.length;i++){
            _addPayee(_payees[i], _shares[i]);
        }
        
    }

    function releasable(
        address payable _payee
    ) public view returns (uint256){
        uint256 totalReceived = address(this).balance + totalReleased;
        return pendingPayment(_payee, totalReceived, released[_payee]);
    }


    function release(
        address payable _payee
    )external virtual {
        require(
            shares[_payee] > 0,
            "The share is not exist in this payer!!!"
        );
        uint256 valid_payment = releasable(_payee);
        require(
            valid_payment == 0, 
            "Already release all payment!!!"
        );
        released[_payee] += valid_payment;
        totalReleased += valid_payment;
        _payee.transfer(valid_payment);

        emit PaymentReleased(_payee, valid_payment);
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function _addPayee(
        address _payee,
        uint256 _share
    ) public {
        require(
            _payee != address(0),
            "Payee account is zero account!!!"
        );
        require(
            _share > 0,
            "Share is zero!!!"
        );
        require(
            shares[_payee] == 0,
            "Payee has been listed!!!"
        );
        shares[_payee] = _share;
        payees.push(_payee);
        totalShares += _share;
    }

    function pendingPayment(
        address _payee,
        uint256 _total_received,
        uint256 _released_value
    )public view returns(uint256){
        return 
            _total_received * shares[_payee] / _total_received - _released_value;
    }
 }