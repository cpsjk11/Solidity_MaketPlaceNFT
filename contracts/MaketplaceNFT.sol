pragma solidity ^0.4.24;

import "../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract Maket is ERC721Token {
    constructor (string _name, string _symbol) public ERC721Token(_name, _symbol) {}
     
     // 이벤트 로그 찍기!!
     event TokenRegistered(address _by, uint256 _tokenId);

    // 토큰생성
    function Maketplace(address _to,uint256 _tokenId,string  _tokenURI) public{
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        emit TokenRegistered(_to, _tokenId);
    }

  
}