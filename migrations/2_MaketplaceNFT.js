const Maket = artifacts.require("Maket");

module.exports = async function(deployer){
    deployer.deploy(Maket,"AvarCat","Acat");
};