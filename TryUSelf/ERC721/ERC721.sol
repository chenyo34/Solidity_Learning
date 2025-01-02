// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./String.sol";

contract ERC721 is IERC721, IERC721Metadata{
    using Strings for uint256;

    /* State Variables */
    string public override name;
    string public override symbol;
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balance;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address=>bool)) private _operatorApprovals;

    /* Error */
    error ERC721InvalidReceiver(address receiver);

    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    /* Functions */

    /* IERC165 Interface*/
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool){
        return 
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }


    /* Check the balance of owner */
    function balanceOf(address owner) external view override returns (uint256){
        require(owner != address(0), "owner is zero address!!!");
        return _balance[owner];
    }

    /* check the owner of the tokenId */
    function ownerOf(uint256 tokenId) public view override returns (address owner){
        owner = _owners[tokenId];
        require(owner != address(0), "owner is zero address!!!");
    } 

    /* Check if all the NFT have been approved to the operator */
    function isApprovedForAll(address owner, address operator) external view override returns(bool){
        return _operatorApprovals[owner][operator];
    }

    /* Set the global permission/approval of the owner to the operatar */
    function setApprovalForAll(address operator, bool _approved) external override {
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender,
                            operator,
                            _approved);
    }

    /* Check the operator of the tokenId */
    function getApproved(uint256 tokenId) external view override returns (address){
        require(_owners[tokenId] != address(0), "token doesnot exist!!!");
        return _tokenApprovals[tokenId];
    }

    /* Implement the approval process with _tokenApprovals */
    function _approve(address owner,
                        address to,
                        uint tokenId) private {
        _tokenApprovals[tokenId] = to; 
        emit Approval(owner, to, tokenId);
    }

    /* Complete the approve, to the target approving object*/
    function approve(address to, uint256 tokenId) external override {
        address owner = _owners[tokenId];
        require(owner == msg.sender || _operatorApprovals[owner][msg.sender],
                "Not owner nor the approved all operator"); // Avoid Redundant permission approving 
        _approve(owner, to, tokenId);
    }

    /* Check if the spender if the owner or approved operator*/
    function _isApprovedOrOwner(address owner,
                                address spender,
                                uint256 tokenId) private view returns (bool){
        return (owner == spender ||
                _tokenApprovals[tokenId] == spender || 
                _operatorApprovals[owner][spender]);
    }


    /*  Transfer the tokenID to from "from" to "to" */
    function _transfer(address owner,
                        address from,
                        address to,
                        uint256 tokenId) private{
        require(from == owner, "Not owner!!!");
        require(to != address(0), "Target address is zero!!!");

        _approve(owner, address(0), tokenId);

        _balance[owner] -= 1;
        _balance[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from,
                            address to,
                            uint256 tokenId) external override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(from, msg.sender, tokenId), 
                "Not owner nor operator. Without Permission to operate!!!");  
        _transfer(owner, from, to, tokenId);
    }


    /* Safe Transfer tokenId from "from" to "to" and check if the receiver meet the condition*/
   function _safeTransferFrom(address owner,
                                address from,
                                address to,
                                uint256 tokenId,
                                bytes memory _data) private {
        _transfer(owner, from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }
    

    function safeTransferFrom(address from,
                                address to,
                                uint256 tokenId,
                                bytes memory _data) public override {
        address owner = ownerOf(tokenId);
        require(_isApprovedOrOwner(owner, msg.sender,tokenId), "Not owner not Approved!!!");

        _safeTransferFrom(owner, from, to, tokenId, _data);
    }

    function safeTransferFrom(address from,
                                address to,
                                uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }


    function _checkOnERC721Received(address from,
                                    address to,
                                    uint256 tokenId,
                                    bytes memory data) private {
        if(to.code.length > 0){
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0){
                    revert ERC721InvalidReceiver(to);
                } else{
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

        /* IERC721Metadata */
    function _baseURI()internal view virtual returns(string memory){
        return "";
    }

    function tokenURI(uint256 tokenId) external view virtual override returns (string memory){
        require(_owners[tokenId] != address(0), "Token Not exist!!!");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0? string(abi.encodePacked(baseURI, tokenId.toString())):"";
    }

    

    /* mint */ 
    function _mint(address to, uint256 tokenId)internal virtual {
        require(to != address(0), "Target Address is zero!!!");
        require(_owners[tokenId] == address(0), "Token has been minted!!!");

        _balance[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /* burn the NFt*/
    function _burn(uint tokenId)internal virtual { // We don't need an address in input para.
        address owner = _owners[tokenId];
        require(owner == msg.sender, "Not Owner of token!!!");
        // require(owner != address(0), "Target Address is zero!!!"); Don't need it

        _approve(owner, address(0), tokenId);

        _balance[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
        
    }
}