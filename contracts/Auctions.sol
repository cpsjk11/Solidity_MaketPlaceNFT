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
    // uint[] 인 이유는 한 판매자가 여러개의 제품을 올릴 수 있기 때문에 배열로 준비를 한다.
    mapping(address => uint[]) public auctionOwner; // 각 소유자 어드레스가 가지고 있는 tokenID의 배열에 대한 매핑이다.

    function() public{
        revert();
    }

    // 이벤트 부분
    event AuctionCreated(address _owner, uint _auctionId);
    event AuctionFinalized(address _owner, uint _auctionId);

    // 해당 컨트랙트가 특정 NFT 소유권을 가지고 있는지 확인하는 modifier를 정의하자!
    modifier checkNFT(address _repoAddress, uint256 _tokenId){
        // 이 함수는 아까 정의해둔 스마트 컨트랙에서 해당 NFT의 소유자를 반환하는 함수이다.
        address nftowner = Maket(_repoAddress).ownerOf(_tokenId);
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
    function sale(uint _auctionId) public payable {
        Auction memory saleAuction = auction[_auctionId];
        address  admin = 0xc25a973AA1D89d6A3944E35e7D5Db152da7d17e2;
        address  user = saleAuction.owner;
        uint256 price = saleAuction.price;
        uint256 fee = price/10; // 수수료는 10%로 잡았다.
        uint256 amountWithoutFee = price - fee;

        // 판매되는 상품의 금액과 구매자 보낸 금액을 비교해 같지 않으면 에러를 발생시키자!
        require(msg.value == price,"the amount is wrong");

        // 금액을 받고 관리자 한테 수수료를 보내고 남은 잔액은 소유자에게 보낸다.

        // 관리자에게 수수료 넘기기
        admin.send(fee);
        // 소유자에게 잔약 보내기
        user.send(amountWithoutFee);

        // 이제 구매자 한테 NFT를 전송하자~!
        finalizeAuction(_auctionId,msg.sender);

        
    }

    // 소유권 이전
    function finalizeAuction(uint _auctionId, address _to) public{
        Auction memory myAuction = auction[_auctionId]; // 구매하고 싶은 상품의 번호를 가져와 생성한다.

        // 성공적으로 토큰의 전송 권한을 부여 후 NFT토큰을 보냈을 때만 수행하는 곳 이다.
        if(approveAndTransfer(address(this), _to, myAuction.repoAddress, myAuction.tokenId)){
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

    // 옥션의 전체갯수를 반환하는 기능
    // constant : 함수 내부에서 상태변수 값을 변경시지 않겠다는 의미입니다 그리고 해당 함수를 호출할 때는 트랜잭션이 발생하지 않습니다
    function getCount() public constant returns(uint){
        return auction.length;
    }

    // 해당 상품의 소유자의 옥션 리스트를 반환하는 기능
    function getAuctionsOf(address _owner) public constant returns(uint[]){
        uint[] memory ownedAuctions = auctionOwner[_owner];
        return ownedAuctions;
    }
    // 해당 상품의 소유자의 옥션 리스트의 갯수를 반환하는 기능
    function getAuctionsCountOfOwner(address _owner) public constant returns(uint){
        return auctionOwner[_owner].length;
    }

    // 옥션 아이디 값으로 상품 전체정보 가져오는 기능
    function getAuctionById(uint _auctionId) public constant returns(
                                                                        string name,
                                                                        uint256 price,
                                                                        string metadata,
                                                                        uint256 tokenId,
                                                                        address repoAddress,
                                                                        address owner,
                                                                        bool active,
                                                                        bool finalized){
        Auction memory auc = auction[_auctionId];
        return(
            auc.name,
            auc.price,
            auc.metadata,
            auc.tokenId,
            auc.repoAddress,
            auc.owner,
            auc.active,
            auc.finalized
        );
    }
    



}