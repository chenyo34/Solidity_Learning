// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC721Receiver {
    
    function onERC721Received( address operatir,
                                address from,
                                uint tokenId,
                                bytes calldata data
    ) external returns (bytes4);
}