// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import './IERC165.sol';

interface IERC721 is IERC165{
    
    /* Events */
    event Transfer(address indexed from,
                    address indexed to,
                    uint256 indexed tokenId);
    event Approval(address indexed owner,
                    address indexed approved_address,
                    uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner,
                        address indexed operator,
                        bool approved);

    /* functions */
    function balanceOf(address account) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from,
                            address to,
                            uint256 tokenId) external;
    function safeTransferFrom(address from,
                                address to,
                                uint256 tokenId) external ;
    function approve(address approve_add, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,
                                address to,
                                uint256 tokenId,
                                bytes calldata data) external ;
}