// Contract based on https://docs.openzeppelin.com/contracts/4.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// address: 0xcD8f7A41F97aB18e30985Cc3f8c131f289526F21

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pokemon is ERC721URIStorage, Ownable {
   using Counters for Counters.Counter;
   Counters.Counter private _tokenIds;
    uint256 public mintPrice;
    uint256 public maxSupply;
    uint256 public totalSupply;
    uint256 public maxPerWallet;
    address payable public withdrawWallet;
    mapping(address=>uint256) public walletMints;

   constructor() payable ERC721("PokemonNFT", "PokeNFT") {
        mintPrice = 0.02 ether;
        maxSupply = 1000;
        maxPerWallet = 3;
   }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    function mint(uint256 _quantity) public payable {
        require(msg.value >= _quantity * mintPrice, "Wrong mint value");
        require(totalSupply + _quantity <= maxSupply, "Sold out");
        require(walletMints[msg.sender] + _quantity <= maxPerWallet,"Exceeded max wallet");

        for(uint256 i=0 ; i<_quantity ; i++){
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, newTokenId);
        }
    }

   function mintNFT(address recipient, string memory tokenURI)
       public onlyOwner
       returns (uint256)
   {
       _tokenIds.increment();

       uint256 newItemId = _tokenIds.current();
       _mint(recipient, newItemId);
       _setTokenURI(newItemId, tokenURI);

       return newItemId;
   }
}