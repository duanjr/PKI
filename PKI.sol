pragma solidity ^0.8.15;
import "./Utils.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract PKI{
    mapping(address => bytes) private id_pk_Map;
    Utils private utils;
    function register(bytes memory publicKey ,uint8 v, bytes32 r, bytes32 s) public returns(bool) {
        address registeringAddress = utils.generateAddressFromPublickey(publicKey);
        string memory message = utils.addressToString(msg.sender);
 
        if (utils.verifySignature(message, v, s, r) != registeringAddress) {
            return false;
        }

        id_pk_Map[msg.sender] = publicKey;
        return true;
    }

    function update(bytes memory publicKeyOld ,uint8 vOld, bytes32 rOld, bytes32 sOld,
    bytes memory publicKeyNew ,uint8 vNew, bytes32 rNew, bytes32 sNew) public returns(bool) {
        address registeringAddressOld = utils.generateAddressFromPublickey(publicKeyOld);
        string memory message = utils.addressToString(msg.sender);

        if (utils.verifySignature(message, vOld, sOld, rOld) != registeringAddressOld) {
            return false;
        }

        if (keccak256(id_pk_Map[msg.sender]) != keccak256(publicKeyOld)) {
            return false;
        }

        address registeringAddressNew = utils.generateAddressFromPublickey(publicKeyNew);

        if (utils.verifySignature(message, vNew, sNew, rNew) != registeringAddressNew) {
            return false;
        }

        id_pk_Map[msg.sender] = publicKeyNew;
        return true;
    }

    function revoke(bytes memory publicKey ,uint8 v, bytes32 r, bytes32 s) public returns(bool) {
        address registeringAddress = utils.generateAddressFromPublickey(publicKey);
        string memory revokePrefix = "revoke";
        string memory revokeAddress = utils.addressToString(msg.sender);
        string memory message = string(abi.encodePacked(revokePrefix, revokeAddress));
        if (utils.verifySignature(message, v, s, r) != registeringAddress) {
            return false;
        }

        if(keccak256(id_pk_Map[msg.sender]) == keccak256(bytes(""))) {
            return false;
        }

        delete id_pk_Map[msg.sender];
        return true;
    }

    function querryPublicKey(address addressQuerried) public view returns(bytes memory){
        bytes memory publicKeyToReturn = id_pk_Map[addressQuerried];
        return publicKeyToReturn;
    }
}
