// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./String.sol";

// contract ERC721 is IERC721, IERC721Metadata{
//     using Strings for uint256;

//     /* State Variables */
//     name;
//     symbol;
//     owners;
//     _balance;
//     _tokenApprovals;
//     _operatorApprovals;

//     /* Error */
//     error ERC721InvalidReceiver(address receiver);

//     constructor(){

//     }

//     /* Functions */

//     /* IERC165 Interface*/
//     function supportsInterface(bytes4 interfaceId) external pure override returns (bool){
//         return 
//             interfaceId == type(IERC721).interfaceId ||
//             interfaceId == type(IERC165).interfaceId ||
//             interfaceId == type(IERC721Metadata).interfaceId;
//     }


//     /* Check the balance of owner */
//     function balanceOf(){}

//     /* check the owner of the tokenId */
//     function ownerOf(){}

//     /* Check if all the NFT have been approved to the operator */
//     function isApprovedForAll(){}

//     /* Set the global permission/approval of the owner to the operatar */
//     function setApprovalForAll(){}

//     /* Check the operator of the tokenId */
//     function getApproved(){}

//     /* Implement the approval process with _tokenApprovals */
//     function _approve(){}

//     /* Complete the approve, to the target approving object*/
//     function approve(){}


//     /*  Transfer the tokenID to from "from" to "to" */
//     function _transfer(){}

//     function transferFrom(){}


//     /* Safe Transfer tokenId from "from" to "to" and check if the receiver meet the condition*/
//    function _safeTransferFrom(){}
    

//     function safeTransferFrom(){}

//     function safeTransferFrom(){}


//     function _checkOnERC721Received(address from,
//                                     address to,
//                                     uint256 tokenId,
//                                     bytes memory data) private {
//         if(to.code.length > 0){
//             try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
//                 if (retval != IERC721Receiver.onERC721Received.selector) {
//                     revert ERC721InvalidReceiver(to);
//                 }
//             } catch (bytes memory reason) {
//                 if (reason.length == 0){
//                     revert ERC721InvalidReceiver(to);
//                 } else{
//                     assembly {
//                         revert(add(32, reason), mload(reason))
//                     }
//                 }
//             }
//         }
//     }

//         /* IERC721Metadata */
//     function _baseURI()internal view virtual returns(string memory){
//         return "";
//     }

//     function tokenURI(uint256 tokenId) external view virtual override returns (string memory){
//         require(_owners[tokenId] != address(0), "Token Not exist!!!");

//         string memory baseURI = _baseURI();
//         return bytes(baseURI).length > 0? string(abi.encodePacked(baseURI, tokenId.toString())):"";
//     }

    

//     /* mint */ 
//     function _mint(){}

//     /* burn the NFt*/
//     function _burn(){}
//     }
// }