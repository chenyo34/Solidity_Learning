// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./Strings.sol";

contract ERC721 is IERC721, IERC721Metadata{
    using Strings for uint256;

    /* State Variables */
    string public override name;
    string public override symbol;
    mapping(uint => address) private _owner;
    mapping(address => uint) private _balance;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address=>bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    /* Error */


    /* Functions */
    /* IERC721Metadata */
    function tokenURI();


    /*  */
    function balanceOf(address owner) external views override returns (uint256){
        require(owner != address(0), "owner is zero address!!!");
        return _balance[owner];
    }

    function ownerOf(uint256 tokenId) external view override returns (address){
        owner = _owner[tokenId];
        require(pwner != addres(0), "owner is zero address!!!");
    } 

    function safeTransferFrom(address ){

    }

    function transferFrom(){}

    function _approve(address owner,
                        address to,
                        uint tokenId) private {
        _tokenApprovals[tokenId] = to; 
        emit Approval(owner, to, tokenId);
    }

    function approve(address to, uint256 tokenId){
        address owner = _owner[tokenId];
        require(owner == msg.sender || _operatorApprovals[owner][msg.sender],
                "Not owner nor the approved all operator"); // Avoid Redundant permission approving 
        _approve(owner, to, tokenId);
    }


    function setApprovalForAll(address operator, bool _approved) external override {
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender,
                            operator,
                            approved);
    }

    function getApproved(uint256 tokenId) external view override returns (address){
        require(_owner[tokenId] != address(0), "token doesnot exist!!!");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view override returns{
        return _operatorApprovals[owner][operator];
    }
    
    /* IERC165 */
    function supportsInterface(bytes4 interfaceId) external view override returns (bool){
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }
}