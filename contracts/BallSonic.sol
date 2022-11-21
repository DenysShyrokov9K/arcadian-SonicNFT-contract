// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./TokenMetaData.sol";

contract BallSonic is ERC721URIStorage, Ownable {
    using Strings for uint256;

    uint256 public tokenCount;
    uint256 nonce;
    string public imageBaseURI;
      

    string public mintType;
    mapping(uint256 => uint256) public category;
    mapping(uint256 => uint256) public currentPowerLvl;
    mapping(uint256 => uint256) public currentAccuracyLvl;
    mapping(uint256 => uint256) public currentSpinLvl;
    mapping(uint256 => uint256) public currentTimeLvl;
    mapping(uint256 => uint256) public maxPowerLvl;
    mapping(uint256 => uint256) public maxAccuracyLvl;
    mapping(uint256 => uint256) public maxSpinLvl;
    mapping(uint256 => uint256) public maxTimeLvl;

    // using TokenMetadata for string;

    TokenMetadata.Attribute attribute;

    mapping(address => uint256[]) public userTokenIds;
    mapping(uint256 => bool) blackList;
    mapping(uint256 => uint256) public tokenIdType;

    constructor() ERC721("BallSonic", "BAS") {
        tokenCount = 1000;
        mintType = "BallSonic";
    }

    function mint() external payable {
        require(tokenCount > 0);
        require(msg.value >= 1 * 10**18);
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
        if (_tokenId >= 1 && _tokenId <= 500) tokenIdType[_tokenId] = 1;
        if (_tokenId >= 501 && _tokenId <= 700) tokenIdType[_tokenId] = 2;
        if (_tokenId >= 701 && _tokenId <= 850) tokenIdType[_tokenId] = 3;
        if (_tokenId >= 851 && _tokenId <= 950) tokenIdType[_tokenId] = 4;
        if (_tokenId >= 951 && _tokenId <= 1000) tokenIdType[_tokenId] = 5;
        category[_tokenId] = tokenIdType[_tokenId];
        currentPowerLvl[_tokenId] = 1;
        currentAccuracyLvl[_tokenId] = 1;
        currentSpinLvl[_tokenId] = 1;
        currentTimeLvl[_tokenId] = 1;
        maxPowerLvl[_tokenId] = 5;
        maxAccuracyLvl[_tokenId] = 5;
        maxSpinLvl[_tokenId] = 5;
        maxTimeLvl[_tokenId] = 5;
        setTokenURI(_tokenId);
    }

    function upgrade(
        uint256 _tokenId,
        uint256 _upgradePowerLvl,
        uint256 _upgradeAccuracyLvl,
        uint256 _upgradeSpinLvl,
        uint256 _upgradeTimeLvl
    ) external payable {
        require(msg.sender == ERC721.ownerOf(_tokenId));
        require(
            (_upgradePowerLvl >= 0 &&
                _upgradeAccuracyLvl >= 0 &&
                _upgradeSpinLvl >= 0 &&
                _upgradeTimeLvl >= 0 && 
                _upgradePowerLvl + currentPowerLvl[_tokenId] <= maxPowerLvl[_tokenId] && 
                _upgradeAccuracyLvl + currentAccuracyLvl[_tokenId] <= maxAccuracyLvl[_tokenId] && 
                _upgradeSpinLvl + currentSpinLvl[_tokenId] <= maxSpinLvl[_tokenId] && 
                _upgradeTimeLvl + currentTimeLvl[_tokenId] <= maxTimeLvl[_tokenId] 
                ),
            "Upgrade vale must be more than 0 and less than max value"
        );
        require(
            msg.value >=
                (_upgradePowerLvl  + _upgradeAccuracyLvl  + _upgradeSpinLvl  + _upgradeTimeLvl ) * 5 * 10**17
        );
        currentPowerLvl[_tokenId] += _upgradePowerLvl;
        currentAccuracyLvl[_tokenId] += _upgradeAccuracyLvl;
        currentSpinLvl[_tokenId] += _upgradeSpinLvl;
        currentTimeLvl[_tokenId] += _upgradeTimeLvl;
        setTokenURI(_tokenId);
    }

    function burn(uint256 _tokenId) external {
        require(
            msg.sender == ERC721.ownerOf(_tokenId),
            "Only the owner of NFT can transfer or bunt it"
        );
        for(uint256 i = 0;i < userTokenIds[ERC721.ownerOf(_tokenId)].length ; i++){
            if(userTokenIds[ERC721.ownerOf(_tokenId)][i] == _tokenId){
                userTokenIds[ERC721.ownerOf(_tokenId)][i] = userTokenIds[ERC721.ownerOf(_tokenId)][userTokenIds[ERC721.ownerOf(_tokenId)].length-1];
                userTokenIds[ERC721.ownerOf(_tokenId)].pop();
            }
        }
        _burn(_tokenId);
    }

    function setTokenURI(uint256 _tokenId) internal {
        attribute = TokenMetadata.Attribute(
            "BallSonic",
            category[_tokenId],
            currentPowerLvl[_tokenId],
            currentAccuracyLvl[_tokenId],
            currentSpinLvl[_tokenId],
            currentTimeLvl[_tokenId],
            maxPowerLvl[_tokenId],
            maxAccuracyLvl[_tokenId],
            maxSpinLvl[_tokenId],
            maxTimeLvl[_tokenId]
        );
        string memory imageURI = string(
            abi.encodePacked(imageBaseURI, tokenIdType[_tokenId].toString())
        );
        string memory json = TokenMetadata.makeMetadataJSON(
            _tokenId,
            ERC721.ownerOf(_tokenId),
            "8Ball",
            imageURI,
            "8Ball is fantastic game",
            attribute
        );
        string memory _tokenURI = TokenMetadata.toBase64(json);
        _setTokenURI(_tokenId, _tokenURI);
    }

    function setImageBaseUri(string memory _imageBaseURI) external onlyOwner {
        imageBaseURI = _imageBaseURI;
    }

    function ownerWithdraw() external onlyOwner {
        address ownerAddress = msg.sender;
        (bool isSuccess, ) = ownerAddress.call{value: (address(this).balance)}(
            ""
        );
        require(isSuccess, "Withdraw fail");
    }
}
