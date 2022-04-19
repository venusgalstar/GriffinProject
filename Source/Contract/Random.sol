// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Random is Ownable{
    using SafeMath for uint256;
    uint256 constant initSeed = 0x48945787;
    uint256 totalIndex;
    uint256 randomCounter;

    mapping(uint256 => uint256) private tokenByIndex;
    mapping(uint256 => uint256) private weightByToken;

    constructor() {
        randomCounter = 0x76396738;
    }

    function addToken(uint256 tokenId, uint32 tokenWeight) external onlyOwner {
        if(tokenWeight == 0) return;
        for(uint256 i=0; i<tokenWeight; i++) {
            tokenByIndex[totalIndex + i] = tokenId;
        }
        weightByToken[tokenId] += tokenWeight;
        totalIndex = totalIndex + tokenWeight;
    }

    function getRandom(uint256 seed, uint256 maxCount) internal view returns(uint256) {
        uint256 rand = encrypt(random(seed), initSeed);
        return rand * maxCount / 0x100000000;
    }

    function selectToken() external onlyOwner returns(uint256) {
        require(randomCounter > 0, "There is no added tokens.");
        uint256 candidate = getRandom(randomCounter, totalIndex);
        randomCounter++;
        return tokenByIndex[candidate];
    }

    function random(uint256 seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            seed
        )));
    }

    function encrypt(uint256 a, uint256 s) internal pure returns(uint256) {
        uint32 t1 = uint32(s);
        uint32 t2 = uint32(a);
        uint32 t3 = t1;
        uint32 t4 = t2;
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        t3 = xor(t3, t4);
        t3 = rotateRight(t3, 3);
        t4 = rotateLeft(t4, 3);
        return xor(t3, t4);
    }
    
    function and(uint32 a, uint32 b) internal pure returns (uint32) {
        return a & b;
    }
    
    function or(uint32 a, uint32 b) internal pure returns (uint32) {
        return a | b;
    }
    
    function xor(uint32 a, uint32 b) internal pure returns (uint32) {
        return a ^ b;
    }
    
    function negate(uint32 a) internal pure returns (uint32) {
        return a ^ allOnes();
    }
    
    function shiftLeft(uint32 a, uint8 n) internal pure returns (uint32) {
        uint256 shifted = uint256(a) * uint256(2 ** n);
        uint32 c = uint32(shifted);
        return c;
    }
    
    function shiftRight(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 shifted = uint32(a) / uint32(2 ** n);
        return shifted;
    }
    
    function getFirstN(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 nOnes = uint32(uint32(2 ** n - 1));
        uint32 mask = uint32(shiftLeft(nOnes, uint8(32 - n))); // Total 8 bits
        return a & mask;
    } 
    
    function getLastN(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 lastN = a % uint32(2 ** n);
        return lastN;
    } 
    
    // Sets all bits to 1
    function allOnes() internal pure returns (uint32) {
        return 0xFFFFFFFF; // 0 - 1, since data type is unsigned, this results in all 1s.
    }
    
    // Get bit value at position
    function getBit(uint32 a, uint8 n) internal pure returns (bool) {
        return uint32(a & shiftLeft(uint32(0x01), n)) != 0;
    }
    
    // Set bit value at position
    function setBit(uint32 a, uint8 n) internal pure returns (uint32) {
        return a | shiftLeft(0x01, n);
    }
    
    // Set the bit into state "false"
    function clearBit(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 mask = negate(shiftLeft(0x01, n));
        return a & mask;
    }

    function rotateLeft(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 lastN = getLastN(a, 32-n);
        uint32 leftVal = shiftRight(a, 32-n);
        lastN = shiftLeft(lastN, n);
        return or(lastN, leftVal);
    }

    function rotateRight(uint32 a, uint8 n) internal pure returns (uint32) {
        uint32 lastN = getLastN(a, n);
        uint32 leftVal = shiftRight(a, n);
        lastN = shiftLeft(lastN, 32-n);
        return or(lastN, leftVal);
    }
}