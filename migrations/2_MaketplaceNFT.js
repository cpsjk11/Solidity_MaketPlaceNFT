const Maket = artifacts.require("Maket");
const Auctions = artifacts.require("Auctions");
module.exports = async function(deployer){
    deployer.deploy(Maket,"AvarCat","Acat");
    deployer.deploy(Auctions);
};
