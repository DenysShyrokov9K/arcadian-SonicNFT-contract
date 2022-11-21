// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";

library TokenMetadata {
    using StringsUpgradeable for uint256;
    using StringsUpgradeable for address;
    using Base64Upgradeable for bytes;
    using TokenMetadata for Attribute;

    struct Attribute {
        string mintType;
        uint256 category;
        uint256 currentPowerLvl;
        uint256 currentAccuracyLvl;
        uint256 currentSpinLvl;
        uint256 currentTimeLvl;
        uint256 maxPowerLvl;
        uint256 maxAccuracyLvl;
        uint256 maxSpinLvl;
        uint256 maxTimeLvl;
    }

    function toBase64(string memory json)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    bytes(json).encode()
                )
            );
    }

    function makeMetadataJSON(
        uint256 tokenId,
        address owner,
        string memory name,
        string memory imageURI,
        string memory description,
        Attribute memory attribute
    ) internal pure returns (string memory) {
        string memory metadataJSON = makeMetadataString(
            tokenId,
            owner,
            name,
            imageURI,
            description
        );
        return
            string(
                abi.encodePacked(
                    "{",
                    metadataJSON,
                    attribute.toJSONString(),
                    "}"
                )
            );
    }

    function makeMetadataString(
        uint256 tokenId,
        address owner,
        string memory name,
        string memory imageURI,
        string memory description
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '"name":"',name,'",',
                    '"tokenId":"',tokenId.toString(),'",',
                    '"description":"',description,'",',
                    '"image":"',imageURI,'",',
                    '"owner":"',owner.toHexString(),'",'
                )
            );
    }

    function toJSONString(Attribute memory attribute)
        internal
        pure
        returns (string memory)
    {
        string memory attributeString = "";
        string memory newAttributeString = string(
                abi.encodePacked(
                    attributeString,
                    '{"mintType":"',attribute.mintType,'",',
                    '"category":',attribute.category.toString(),',',
                    '"currentPowerLvl":',attribute.currentPowerLvl.toString(),',',
                    '"currentAccuracyLvl":',attribute.currentAccuracyLvl.toString(),',',
                    '"currentSpinLvl":',attribute.currentSpinLvl.toString(),',',
                    '"currentTimeLvl":',attribute.currentTimeLvl.toString(),',',
                    '"maxPowerLvl":',attribute.maxPowerLvl.toString(),',',
                    '"maxAccuracyLvl":',attribute.maxAccuracyLvl.toString(),',',
                    '"maxSpinLvl":',attribute.maxSpinLvl.toString(),',',
                    '"maxTimeLvl":',attribute.maxTimeLvl.toString(),"}"
                )
            );
            attributeString = newAttributeString;
        return string(abi.encodePacked('"attributes":', attributeString));
    }

    function makeContractURI(
        string memory name,
        string memory description,
        string memory imageURL,
        string memory externalLinkURL,
        uint256 sellerFeeBasisPoints,
        address feeRecipient
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    name,
                    '",',
                    '"description":"',
                    description,
                    '",',
                    '"image":"',
                    imageURL,
                    '",',
                    '"external_link":"',
                    externalLinkURL,
                    '",',
                    '"seller_fee_basis_points":',
                    sellerFeeBasisPoints.toString(),
                    ",",
                    '"fee_recipient":"',
                    feeRecipient.toHexString(),
                    '"}'
                )
            );
    }
}
