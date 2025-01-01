// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../ERC721/ERC721.sol";

library ECDSA{
    function verify(bytes32 _msgHash, 
                    bytes memory _signature,
                    address _signer) internal pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    } 

    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address){
        // 65是标准r,s,v签名的长度, r(32 bytes), s(32 bytes) v(1 bytes)
        require(_signature.length == 65, "invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SignatureNFT is ERC721{
    address immutable public signer;
    mapping (address => bool) public mintedAddress;

    constructor(string memory name_, 
                    string memory symbol_, 
                    address signer_) ERC721(name_, symbol_){
        signer = signer_;
    }

    function mint(address _account, 
                    uint256 _tokenId, 
                    bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId); // 将_account和_tokenId打包消息
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash); // 计算以太坊签名消息
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature"); // ECDSA检验通过
        require(!mintedAddress[_account], "Already minted!"); // 地址没有mint过
                
        mintedAddress[_account] = true; // 记录mint过的地址
        _mint(_account, _tokenId); // mint
    }

    function getMessageHash(address account_, uint256 tokenId_) public pure returns (bytes32){
        return keccak256(abi.encode(account_, tokenId_));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool){
        return  ECDSA.verify(_msgHash, _signature, signer);
    }
}
