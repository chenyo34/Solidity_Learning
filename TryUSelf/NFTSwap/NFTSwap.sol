// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../ERC721/IERC721.sol";
import "../ERC721/IERC721Receiver.sol";
import "../ERC721/WTFAPE.sol";

contract NFTSwap is IERC721Receiver{

    function onERC721Received(
            address operator,
            address from,
            uint tokenId,
            bytes calldata data
            ) external pure override returns (bytes4){
            return IERC721Receiver.onERC721Received.selector;
    }

    struct Order{
        address owner;
        uint256 price;
    }

    mapping(address => mapping (uint256 => Order)) public nftList;

    /* Event */
    event List(
        address indexed seller, 
        address indexed nftAddr, 
        uint256 indexed tokenId, 
        uint256 price);
    event Revoke(
        address indexed seller, 
        address indexed nftAddr, 
        uint256 indexed tokenId);
    event Update(
        address indexed seller, 
        address indexed nftAddr, 
        uint256 indexed tokenId, 
        uint256 new_price);
    event Purchase(
        address indexed buyer, 
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 close_price);

    /* Function */

    function list(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _price
        ) public {

        IERC721 _nft = IERC721(_nftAddr);
        require(_price > 0, "Price need to be Postive!!!");
        require(_nft.getApproved(_tokenId) == address(this), "Need to be approved!!!");
        
        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.price = _price;
        _order.owner = msg.sender;

        _nft.safeTransferFrom(msg.sender,address(this),_tokenId);
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    function purchase(
        address _nftAddr,
        uint256 _tokenId
        ) public payable {
        Order storage cur_order = nftList[_nftAddr][_tokenId];
        require(cur_order.price > 0, "Item does not have a valid price!!!");
        require(msg.value >= cur_order.price, "Not enough ETH to purchase!!!");

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Caller does own the ETH.Invalid Order!!!");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        payable(cur_order.owner).transfer(cur_order.price);
        if (msg.value - cur_order.price > 0){
            payable(msg.sender).transfer(msg.value - cur_order.price);
        }

        emit Purchase(msg.sender, _nftAddr, _tokenId, cur_order.price);
    }

    function revoke(
        address _nftAddr,
        uint256 _tokenId
        ) public {
        Order storage cur_order = nftList[_nftAddr][_tokenId];
        require(cur_order.price > 0, "Invalid Price!!!");
        require(cur_order.owner == msg.sender, "Not OWner!!!");

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Not Owner!!!");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];
        
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _new_price
        ) public {

        require(_new_price > 0, "Valid New Price ");
        Order storage cur_order = nftList[_nftAddr][_tokenId];
        require(cur_order.owner == msg.sender, "Not OWner!!!");

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Not Owner!!!");
        cur_order.price = _new_price;
        emit Update(msg.sender, _nftAddr, _tokenId, _new_price);
    }
}