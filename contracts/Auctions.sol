pragma solidity ^0.4.24;

import "./MaketplaceNFT.sol";

contract Auctions{
    // 구조체 생성
    struct Auction{
        string name; // 제목
        uint256 price; // 가격
        string metadata; // ifps
        uint256 tokenId; // 토큰 아이디
        address repoAddress; // NFT 컨트랙트 어드레스
        address owner; // 소유자
        bool active; // 활성화 여부
        bool finalized; // 판매 종류여부
    }
    Auction[] public auction;
    // uiny[] 인 이유는 한 판매자가 여러개의 제품을 올릴 수 있기 때문에 배열로 준비를 한다.
    mapping(address => uint[]) public auctionOwner; // 각 소유자 어드레스가 가지고 있는 tokenID의 배열에 대한 매핑이다.

    function() public{
        revert();
    }

    // 해당 컨트랙트가 특정 NFT 소유권을 가지고 있는지 확인하는 modifier를 정의하자!
    modifier checkNFT(address _repoAddress, uint256 _tokenId){
        // 이 함수는 아까 정의해둔 스마트 컨트랙에서 해당 NFT의 소유자를 반환하는 함수이다.
        address nftowner = Maket(_repoAddress).onwerOf(_tokenId);
        // NFT 소유자가 아닐 시 에러 발생!!🔥🔥
        require(nftowner == address(this));
        _; // modifier을 사용하는 함수는 여기서 부터 시작된다.
    }

    // 상품 생성부분
    function createAuction(address _repoAddress, uint256 _tokenId,string _auctionTitle, string _metadata, uint256 _price) public checkNFT(_repoAddress,_tokenId) returns(bool){
        uint auctionId = auction.length;
        Auction memory newAuction;
        newAuction.name = _auctionTitle; // 제목
        newAuction.price = _price; // 가격
        newAuction.metadata = _metadata;
        newAuction.tokenId = _tokenId;
        newAuction.repoAddress = _repoAddress;
        newAuction.owner = msg.sender; // 소유자는 이 함수를 실행시킨 주소로 부터 소유자라고 해준다.
        newAuction.active = true; // 이제 생성했으므로 활성화 여부는 true이다.
        newAuction.finalized = false;

        auction.push(newAuction);
        auctionOwner[msg.sender].push(auctionId);

        emit AuctionCreated(msg.sender, auctionId);
        return true;
    }

    // 판매
    function finalizeAuction(uint _auctionId, address _to) public{
        Auction memory myAuction = auction[__auctionId]; // 구매하고 싶은 상품의 번호를 가져와 생성한다.

        // 성공적으로 토큰의 전송 권한을 부여 후 NFT토큰을 보냈을 때만 수행하는 곳 이다.
        if(approveAndTransfer(address(this), _to, myAction.repoAddress,myAction.tokenId)){
            auction[_auctionId].active = false; // 판매가 완료 되었으니 활성화 X
            auction[_auctionId].finalized = true; // 그리고 판매 불가능으로 바꾼다.
            emit AuctionFinalized(msg.sender, _auctionId); // 이벤트 발생!
        }
    }

    function approveAndTransfer(address _from, address _to, address _repoAddress, uint256 _tokenId) internal returns(bool){
        Maket remoteContract = Maket(_repoAddress);
        remoteContract.approve(_to, _tokenId); // 토큰 전송 권한 부여
        remoteContract.transferFrom(_from, _to, _tokenId); // 토큰 전송!
        return true;
    }

}
