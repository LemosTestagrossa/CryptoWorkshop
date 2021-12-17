const NFTicket = artifacts.require("NFTicket");
const GaiaStore = artifacts.require("GaiaStore");

const chai = require("./chaisetup.js");
const BN = web3.utils.BN;
const expect = chai.expect;

contract("Gaia Test", function (accounts) {
    const [deployer, recipient, other, unknown] = accounts;

    beforeEach(async () => {
        this.nfticket = await NFTicket.new("GaiaNFTicket", "GAIA");
        this.gaiaStore = await GaiaStore.new(nfticket.address, [recipient, other]);
    });

    it("e2e", async () => {
        // create ticket
        const ticketId = 1;
        await this.nfticket.createTicket(ticketId, this.gaiaStore.address, { from: deployer });

        // check gaia has nft ticket balance
        expect(await this.nfticket.balanceOf(this.gaiaStore.address)).to.be.bignumber.equal('1');

        // create event
        const eventId = 1;
        await this.gaiaStore.createEvent(eventId, 311012, 2, [ticketId]);

        // reject unknown buyer
        await expect(this.gaiaStore.buyTicket(eventId, { from: unknown, value: "2", gasPrice: 0 }))
            .to.eventually.be.rejected;

        // check gaia has balance 0
        expect(await web3.eth.getBalance(this.gaiaStore.address)).to.be.bignumber.equal('0');

        // reject buy due to insufficient funds
        await expect(this.gaiaStore.buyTicket(eventId, { from: unknown, value: "1", gasPrice: 0 }))
            .to.eventually.be.rejected;

        // sell ticket to whitelisted customer
        await this.gaiaStore.buyTicket(eventId, { from: recipient, value: "2", gasPrice: 0 });
        
        // check customer has nft balance
        expect(await this.nfticket.balanceOf(recipient)).to.be.bignumber.equal('1');
        
        // check gaia has balance 2
        expect(await web3.eth.getBalance(this.gaiaStore.address)).to.be.bignumber.equal('2');

        // reject buy due to not enough tickets
        await expect(this.gaiaStore.buyTicket(eventId, { from: recipient, value: "2", gasPrice: 0 }))
            .to.eventually.be.rejected;
    });
});
