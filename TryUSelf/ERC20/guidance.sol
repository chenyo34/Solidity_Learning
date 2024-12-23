// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
    // Create two files
    // IERC20.sol defines the standard ERC20 interface.  
    // ERC20.sol inherits and overrides IERC20, 
        // adding two new functions: mint() and burn().  
        // Both require an integer parameter and adjust totalSupply when tokens are created or destroyed.  



    //The following is the basic description for the IERC20, try it yourself.

    //==========
    //IERC20.sol
    //==========
    
    /*************
    Events 
    *************/

    /**
     * @dev Triggered when `value` tokens are transferred from `from` to `to`.
     */


    /**
     * @dev Triggered whenever `value` tokens are approved by `owner` to be spent by `spender`.
     */                


    /*************
    Functions
    *************/

    /**
     * @dev Returns the total amount of tokens.
     */

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */

    /**
     * @dev Transfers `amount` tokens from the caller's account to the recipient `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded or not.
     *
     * Emits a {Transfer} event.
     */

    /**
     * @dev Allows `spender` to spend `amount` tokens from caller's account.
     *
     * Returns a boolean value indicating whether the operation succeeded or not.
     *
     * Emits an {Approval} event.
     */

    /**
     * @dev Returns the amount authorized by the `owner` account to the `spender` account, default is 0.
     *
     * When {approve} or {transferFrom} is invoked，`allowance` will be changed.
     */

    /**
     * @dev Transfer `amount` of tokens from `from` account to `to` account, subject to the caller's
     * allowance. The caller must have allowance for `from` account balance.
     *
     * Returns `true` if the operation is successful.
     *
     * Emits a {Transfer} event.
     */

    //==========
    //ERC20.sol
    //==========
    
    // This implementation primarily overrides the IREC20 interface, thus the structure has been generally determined.
    // However, the ERC20 implementation remains flexible, leaving room for custom functionality.
    // Consider adding enhancements to improve functionality, usability, and compatibility where appropriate.
