const MyToken = artifacts.require("MyToken");

const chai = require("./chaisetup.js");
const BN = web3.utils.BN;
const expect = chai.expect;

contract("Token Test", function (accounts) {
    const [initialHolder, recipient, anotherAccount] = accounts;

    beforeEach(async () => {
        this.myToken = await MyToken.new("StarDucks Capu-Token", "SCT", 10000);
    });

    it("All tokens should be in my account", async () => {
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();
        return expect(
            instance.balanceOf(initialHolder)
        ).to.eventually.be.a.bignumber.equal(totalSupply);
    });

    it("I can send tokens from Account 1 to Account 2", async () => {
        const sendTokens = 1;
        let instance = this.myToken;
        let totalSupply = await instance.totalSupply();
        await expect(
            instance.balanceOf(initialHolder)
        ).to.eventually.be.a.bignumber.equal(totalSupply);
        await expect(instance.transfer(recipient, sendTokens)).to.eventually.be
            .fulfilled;
        await expect(
            instance.balanceOf(initialHolder)
        ).to.eventually.be.a.bignumber.equal(
            totalSupply.sub(new BN(sendTokens))
        );
        return expect(
            instance.balanceOf(recipient)
        ).to.eventually.be.a.bignumber.equal(new BN(sendTokens));
    });

    it("It's not possible to send more tokens than account 1 has", async () => {
        let instance = this.myToken;
        let balanceOfAccount = await instance.balanceOf(initialHolder);
        await expect(instance.transfer(recipient, new BN(balanceOfAccount + 1)))
            .to.eventually.be.rejected;

        //check if the balance is still the same
        return expect(
            instance.balanceOf(initialHolder)
        ).to.eventually.be.a.bignumber.equal(balanceOfAccount);
    });
});
