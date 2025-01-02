// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721{

    uint256 public constant MAX_COLLECTION_SIZE = 10000; 
    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; 
    uint256 public constant AUCTION_TIME = 10 minutes; 
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; 
    uint256 public constant AUCTION_DROP_PER_STEP = (AUCTION_START_PRICE - AUCTION_END_PRICE) / (AUCTION_TIME / AUCTION_DROP_INTERVAL); 

    uint256 public auctionStartTime;
    string private _baseTokenURI;
    uint256[] private  _allTokens;

    constructor() Ownable(msg.sender) ERC721("WTF Dutch Auction", "WTF DA") {
        auctionStartTime = block.timestamp;
    }

    /* Override the totalSupply from ERC721 */
    function totalSupply() public view virtual returns(uint256) {
        return _allTokens.length;
    }

    function auctionMint(uint256 quantity) external payable {
        require(
            totalSupply() + quantity <= MAX_COLLECTION_SIZE,
            "Not enough remaining reserved collection to support current mint account!!!"
        );
        // Create local timestamp avoid redundent gas cost
        uint256 _saleStartTime = uint256(auctionStartTime);
        require(
            _saleStartTime != 0 && _saleStartTime <= block.timestamp,
            "Sale has not started yet!!!"
        );

        // Calculate the total cost based on the current acution price and desired quantity
        uint256 totalcost = getAuctionPrice() * quantity; 
        require(
            msg.value>= totalcost,
            "Not enough ETH!!!"
        );

        // Mint NFT
        for(uint256 i=0; i<quantity; i++){
            uint256 mint_tokenId = totalSupply();
            _mint(msg.sender, mint_tokenId);
            _addTokenToAllTokensEnumeration(mint_tokenId);
        }

        // Refund the remaining ETH
        if (msg.value > totalcost){
            payable(msg.sender).transfer(msg.value-totalcost);
        }
    }

    function getAuctionPrice() public view returns (uint256){
        if (auctionStartTime >= block.timestamp){ // Has not started
            return AUCTION_START_PRICE;
        } else if (block.timestamp >= auctionStartTime + AUCTION_TIME){
            return AUCTION_END_PRICE;
        } else {
            return AUCTION_START_PRICE - AUCTION_DROP_PER_STEP * (block.timestamp - auctionStartTime)/AUCTION_DROP_INTERVAL;
        }
            
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    function setAuctionStartTime(uint256 timestamp) external onlyOwner{
        auctionStartTime = timestamp;
    }

    // BaseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    // BaseURI setter, onlyOwner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
    // Withdraw ETH，onlyOwner
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}