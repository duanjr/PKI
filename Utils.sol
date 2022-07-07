pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
contract Utils {
    function Web3Hash( string memory message) public pure returns (bytes32) {
        bytes memory _message = bytes(message);
        return keccak256(bytes(abi.encodePacked(bytes("\x19Ethereum Signed Message:\n"), bytes(Strings.toString(_message.length)), _message)));
    }

    function addressToString(address _address) public pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(40);
        for(uint i = 0; i < 20; i++) {
            _string[i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[1+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

    function verifySignature(address user, uint8 v, bytes32 r, bytes32 s) public pure returns (address, bool){
        string memory message = addressToString(user);
        bytes32 web3Hash = Web3Hash(message);
        return (ecrecover(web3Hash,v,r,s),ecrecover(web3Hash,v,r,s) == user);
    }
}