// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symble() external view returns (string memory);

    function toeknURI(uint256 tokenId) external view returns (string memory);
}