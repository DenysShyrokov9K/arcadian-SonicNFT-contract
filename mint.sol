// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BallSonic is ERC721URIStorage, Ownable  {
    using Strings for uint256;
    uint256 public tokenCount;
    uint256 nonce;
    string public baseURI;

    mapping(address => uint256[]) public userTokenIds;
    mapping(uint256 => bool) blackList;
    mapping(uint256 => uint256) public tokenIdType;

    constructor() ERC721("BallSonic", "BAS") {
        tokenCount = 1000;
    }

    function mint() external payable {
        require(tokenCount > 0);
        require(msg.value >= 1 * 10 ** 18);
        uint256 rand = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        ) % tokenCount;
        nonce++;
        uint256 index = 0;
        uint256 _tokenId = 0;
        for (uint256 i = 0; i < 1000; i++) {
            if (blackList[i] == false) {
                if (index == rand) {
                    _tokenId = i + 1;
                    blackList[_tokenId] = true;
                    tokenCount--;
                    break;
                }
                index++;
            }
        }
        userTokenIds[msg.sender].push(_tokenId);
        _safeMint(msg.sender, _tokenId);
        if(_tokenId >= 1 && _tokenId <= 500)
            tokenIdType[_tokenId] = 1;
        if(_tokenId >= 501 && _tokenId <= 700)
            tokenIdType[_tokenId] = 2;
        if(_tokenId >= 701 && _tokenId <= 850)
            tokenIdType[_tokenId] = 3;
        if(_tokenId >= 851 && _tokenId <= 950)
            tokenIdType[_tokenId] = 4;
        if(_tokenId >= 951 && _tokenId <= 1000)
            tokenIdType[_tokenId] = 5;
        setTokenURI(_tokenId);
    }

    function setTokenURI(uint256 _tokenId) internal {
        string memory tokenURI = string(
            abi.encodePacked(baseURI , _tokenId.toString())
        );
        _setTokenURI(_tokenId, tokenURI);
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function burn(uint256 _tokenId) external {
        require(msg.sender == ERC721.ownerOf(_tokenId), "Only the owner of NFT can transfer or bunt it");
        _burn(_tokenId);
    }

    function transfer(address _from,address _to,uint256 _tokenId) external {
        require(msg.sender == _from, "Only the owner of NFT can transfer or bunt it");
        _transfer(_from, _to, _tokenId);
    }

    function ownerWithdraw() external onlyOwner {
        address ownerAddress = msg.sender;
        (bool isSuccess, ) = ownerAddress.call{value: (address(this).balance)}(
            ""
        );
        require(isSuccess, "Withdraw fail");
    }
}
