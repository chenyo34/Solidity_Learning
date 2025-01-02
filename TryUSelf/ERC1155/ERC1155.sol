// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./IERC1155MetadataURI.sol";
import "./Address.sol";
import "../ERC721/String.sol";
import "../ERC721/IERC165.sol";

contract ERC1155 is IERC165,
                    IERC1155,
                    IERC1155MetadataURI {

    using Address for address;
    using Strings for uint256;
    string public name;
    string public symbol;
    mapping(uint256 => mapping(address => uint256)) public _balances; // Should be private
    mapping(address => mapping(address => bool)) public _operatorApprovals; // Should be private

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function supportsInterface(
        bytes4 itnerfaceId
    )public pure override returns(bool){ 
       return  
            itnerfaceId == type(IERC165).interfaceId ||
            itnerfaceId == type(IERC1155).interfaceId ||
            itnerfaceId == type(IERC1155MetadataURI).interfaceId;
    }

    function balanceOf(
        address account,
        uint256 id
    ) public view override returns(uint256) {
        require(account != address(0), "Current Account is zero adress!!!");
        return _balances[id][account];
    }
    
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) external view override returns(uint256[] memory){
        require(accounts.length == ids.length, "Length of accounts and ids are not matched!!!");
        uint256[] memory outputBalances = new uint256[](ids.length);
        for (uint i = 0; i < ids.length; i ++) 
        {
            // outputBalances[i] = _balances[ids[i]][accounts[i]]; Why you can't use that!
            outputBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        return outputBalances;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    )public virtual override {
        require(msg.sender != operator, "Owner is approving to self!!!");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address account,
        address operator
    )public view virtual override returns (bool) {
        require(
            account != address(0) && 
            operator != address(0),
            "Zero address appears!!!"
        );
        require(
            account != operator,
            "Account is the same as the operator!!!"
        );
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override{
        address operator = msg.sender;
        // From is the owner or has been approved to operate
        require(
            from == operator ||
            isApprovedForAll(from, operator),
             "ERC1155: Caller is not token owner nor approved!!!"
        );
        require(
            to != address(0),
            "Transfer to Zero Address"
        );

        require(
            _balances[id][from] >= amount,
            "Not enough NFT to transfer!!!"
        );
        unchecked {
            _balances[id][from] -= amount;
        } // Since the overflow/underflow has been handled
        
        _balances[id][to] += amount;

        emit TransferSingle(msg.sender,from,to,amount,id);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);    
    }  

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )public virtual override {
        require(
            ids.length == amounts.length,
            "Different length of ids and amounts!!!"
        );
        address operator = msg.sender;
        // From is the owner or has been approved to operate
        require(
            from == operator ||
            isApprovedForAll(from, operator),
             "ERC1155: Caller is not token owner nor approved!!!"
        );
        require(
            to != address(0),
            "Transfer to Zero Address"
        );
        for (uint i = 0; i < ids.length; i++) 
        {
            require(
                _balances[ids[i]][from] >= amounts[i],
                "Not enough NFT to transfer for index!!!"
            );
            unchecked {
                _balances[ids[i]][from] -= amounts[i];
            } // Since the overflow/underflow has been handled
        
            _balances[ids[i]][to] += amounts[i];
        }


        emit TransferBatch(msg.sender,from,to,amounts,ids);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);    
    }

    // function _doSafeTransferAcceptanceCheck(
    //     address operator,
    //     address from,
    //     address to,
    //     uint256 id,
    //     uint256 amount,
    //     bytes memory data
    // ) private {
    //     if (to.isContract()) {
    //         try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
    //             if (response != IERC1155Receiver.onERC1155Received.selector) {
    //                 revert("ERC1155: ERC1155Receiver rejected tokens");
    //             }
    //         } catch Error(string memory reason) {
    //             revert(reason);
    //         } catch {
    //             revert("ERC1155: transfer to non-ERC1155Receiver implementer");
    //         }
    //     }
    // }

    // // @dev ERC1155的批量安全转账检查
    // function _doSafeBatchTransferAcceptanceCheck(
    //     address operator,
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) private {
    //     if (to.isContract()) {
    //         try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
    //             bytes4 response
    //         ) {
    //             if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
    //                 revert("ERC1155: ERC1155Receiver rejected tokens");
    //             }
    //         } catch Error(string memory reason) {
    //             revert(reason);
    //         } catch {
    //             revert("ERC1155: transfer to non-ERC1155Receiver implementer");
    //         }
    //     }
    // }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual{
        require(
            to != address(0), 
            "Mint Target Address CANNOT be zero address!!!"
        );    
        address operator = msg.sender;
        _balances[id][to] += amount;

        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual{
        require(
            ids.length == amounts.length,
            "The length of ids and amounts are diff!!!"
        );
        require(
            to != address(0), 
            "Mint Target Address CANNOT be zero address!!!"
        );    
        address operator = msg.sender;
        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount,
        bytes memory data
    )internal virtual {
        require(
            from != address(0), 
            "Mint Target Address CANNOT be zero address!!!"
        );    
        require(
            _balances[id][from] >= amount,
            "Insufficient fund to burn!!!"
        );
        address operator = msg.sender;
        unchecked{
            _balances[id][from] -= amount;
        }

        emit TransferSingle(operator, from, address(0),id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, address(0), id, amount, data);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )internal virtual {
        require(
            from != address(0), 
            "Mint Target Address CANNOT be zero address!!!"
        );    
        for (uint256 i = 0; i < ids.length; i++){
            require(
                _balances[ids[i]][from] >= amounts[i],
                "Insufficient fund to burn!!!"
            );
            
            unchecked{
                _balances[ids[i]][from] -= amounts[i];
            }
        }
        address operator = msg.sender;
        emit TransferBatch(operator, from, address(0), ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, address(0), ids, amounts, data);
    }

    /**
     * @dev 返回ERC1155的id种类代币的uri，存储metadata，类似ERC721的tokenURI.
     */
    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    }

    /**
     * 计算{uri}的BaseURI，uri就是把baseURI和tokenId拼接在一起，需要开发重写.
     */
    function _baseURI(
    )internal view virtual returns (string memory) {
        return "";
    }


    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )public {
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )public {
    }
}