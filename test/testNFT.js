import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
chai.use(chaiAsPromised)
const { expect, assert } = chai

const MyNFT = artifacts.require("Maket");

contract('Test MyNFT contract', function(accounts) {

    let token;
    const name = "AvarCat" // NFT 이름
    const symbol = "ACat" // symbol 이름

    const account1 = accounts[1]
    const tokenId1 = 1111;
    const tokenUri1 = "This is data for the token 1"; // Does not have to be unique

    const account2 = accounts[2]
    const tokenId2 = 2222;
    const tokenUri2 = "This is data for the token 2"; // Does not have to be unique

    const account3 = accounts[3]

    it(' deploy and mint ERC721 token', async () => {
        token = await MyNFT.new(name, symbol)
        await token.Maketplace(account1, tokenId1, tokenUri1, {from: accounts[0]})

        expect(await token.symbol()).to.equal(symbol)
        expect(await token.name()).to.equal(name)
    })

    it(' check unique id', async () => {
        const duplicateTokenID = token.Maketplace(account2, tokenId1, tokenUri2, {from: accounts[0]}) //tokenId
        expect(duplicateTokenID).to.be.rejectedWith(/VM Exception while processing transaction: revert/)
    })

    it(' create multiple unique tokens and manage ownership', async () => {
        const additionalToken = await token.Maketplace(account2, tokenId2, tokenUri2, {from: accounts[0]})
        expect(Number(await token.totalSupply())).to.equal(2)

        expect(await token.exists(tokenId1)).to.be.true
        expect(await token.exists(tokenId2)).to.be.true        

        expect(await token.ownerOf(tokenId1)).to.equal(account1)
        expect(await token.ownerOf(tokenId2)).to.equal(account2)
    })

    it(' safe transfer', async () => {
        const unownedTokenId = token.safeTransferFrom(account2, account3, tokenId1, {from: accounts[2]}) // tokenId
        expect(unownedTokenId).to.be.rejectedWith(/VM Exception while processing transaction: revert/)

        const wrongOwner = token.safeTransferFrom(account1, account3, tokenId2, {from: accounts[1]}) // wrong owner
        expect(wrongOwner).to.be.rejectedWith(/VM Exception while processing transaction: revert/)
        
        const wrongFromGas = token.safeTransferFrom(account2, account3, tokenId2, {from: accounts[1]}) // wrong owner
        expect(wrongFromGas).to.be.rejectedWith(/VM Exception while processing transaction: revert/)

        await token.safeTransferFrom(account2, account3, tokenId2, {from: accounts[2]})
        expect(await token.ownerOf(tokenId2)).to.equal(account3)
    })
})
