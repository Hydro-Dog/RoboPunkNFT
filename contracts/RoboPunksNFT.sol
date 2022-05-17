//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoboPunksNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenURI;
    address payable internal withdrawWallet;
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('RoboPunks', 'RP') {
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 1000;
        maxPerWallet = 3;
        //set withdraw wallet
    }

    function setIsPublicMintEnable(bool flag) external onlyOwner {
        isPublicMintEnabled = flag;
    } 

    function setBaseTokenURI(string calldata uri) external onlyOwner {
        baseTokenURI = uri;
    } 

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        require(_exists(tokenId), 'Token does not exist');
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId), '.json'));
    }

    function withdraw() public onlyOwner {
        (bool success,) = withdrawWallet.call{value: address(this).balance}('');
        require(success, 'Withdraw failed');
    }

    function mint(uint256 quantity) public payable {
        require(isPublicMintEnabled, 'Public mint disabled');
        require(msg.value == mintPrice * quantity, 'Wrong mint value');
        require(totalSupply + quantity <= maxSupply, 'Sold out');
        require(walletMints[msg.sender] + quantity <= maxPerWallet, 'Max wallet exeeded');

        for(uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }        
    }
}