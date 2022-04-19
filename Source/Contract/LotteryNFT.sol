// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryNFT is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    event SetBaseURI(address addr, string newUri);
    event SetURI(address addr, string newUri);

    address constant _multisignWallet               = 0x697A32dB1BDEF9152F445b06d6A9Fd6E90c02E3e;
    // address constant _multisignWallet               = 0x13Bf16A02cF15Cb9059AC93c06bAA58cdB9B2a59;

    uint256 private constant MAX_NFT_SUPPLY          = 10000;
    
    Counters.Counter private _tokenCounter;
    
    string private _baseURIExtended;
    string private nftURI;

    /**
    * @dev Throws if called by any account other than the multi-signer.
    */
    modifier onlyMultiSignWallet() {
        require(owner() == _msgSender(), "Multi-signer: caller is not the multi-signer");
        _;
    }
    
    constructor() ERC721("Lottery","LTR") {
        _baseURIExtended = "https://ipfs.infura.io/";
    }

    function getURI() external view returns(string memory){
        return nftURI;
    }

    function setURI(string memory _nftURI) external onlyMultiSignWallet{
        nftURI = _nftURI;
        emit SetURI(msg.sender, _nftURI);
    }

   /**
    * @dev Mint masterNFT For Free
    */
    function mint(address sender) external returns(uint256){
        // Test _tokenCounter
        require(_tokenCounter.current() <= MAX_NFT_SUPPLY, "exceed maximum supply");

        // Incrementing ID to create new token        
        uint256 newID = _tokenCounter.current();
        _tokenCounter.increment();

        _safeMint(sender, newID);    
        return newID;
    }

    /**
     * @dev Return the base URI
     */
     function _baseURI() internal override view returns (string memory) {
        return _baseURIExtended;
    }

    /**
     * @dev Set the base URI
     */
    function setBaseURI(string memory baseURI_) external onlyMultiSignWallet() {
        _baseURIExtended = baseURI_;
        emit SetBaseURI(msg.sender, baseURI_);
    }
}