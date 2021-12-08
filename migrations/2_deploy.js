const MyToken = artifacts.require("MyToken");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(MyToken, "StarDucks Capu-Token", "SCT", "100000000000000000000000000");
    const token = await MyToken.deployed();
};