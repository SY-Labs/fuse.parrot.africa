// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract AzeroPay {
    struct Claim {
        address public_key;
        bool redeemed;
        uint256 value;
    }   

    mapping (string => Claim) public claims;

    function create(string memory id, address public_key) public payable {
        require(claims[id].public_key == address(0), "Already exists");

        claims[id] = Claim(public_key, false, msg.value);
    }

    function redeem(string memory id, bytes memory signature) public {
        require(claims[id].public_key != address(0), "Does not exists");
        require(claims[id].public_key == public_key(id, signature), "Invalid signature");
        require(claims[id].redeemed != true, "Already redeemed");
        
        payable(msg.sender).transfer(claims[id].value);

        claims[id].redeemed = true;
    }

    function encode(string memory id) public pure returns(bytes memory) {
        return abi.encodePacked(id);   
    }

    function hash(string memory id) public pure returns(bytes32) {
        return keccak256(encode(id));   
    }

    function public_key(string memory id, bytes memory signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        
        return ecrecover(hash(id), v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}