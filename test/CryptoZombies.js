const utils = require("./helpers/utils");
const time = require("./helpers/time");
const CryptoZombies = artifacts.require("CryptoZombies"); // CryptoZombies contract abstraction
const zombieNames = ["Zombie 1", "Zombie 2"];
// const expect = require("chai").expect;

contract("CryptoZombies", (accounts) => {
  let [alice, bob] = accounts; // first and second account from ganache
  let contractInstance;

  beforeEach(async () => {
    contractInstance = await CryptoZombies.new(); // get the contract instance from the abstraction (deploys the contract)
  });

  /*
  afterEach(async () => {
    await contractInstance.kill(); // remove the smart contract once the tests are finished
  });
  */

  it("should be able to create a new zombie", async () => {
    const result = await contractInstance.createRandomZombie(zombieNames[0], {
      from: alice,
    });
    assert.equal(result.receipt.status, true); // check if the transaction was successfull
    // expect(result.receipt.status).to.equal(true);
    assert.equal(result.logs[0].args.name, zombieNames[0]); // check if the emited event of the created zombie name field is equal to the name we provided to the zombie
    // expect(result.logs[0].args.name).to.equal(zombieNames[0]);
  });

  it("should not allow two zombies", async () => {
    // create first zombie
    await contractInstance.createRandomZombie(zombieNames[0], {
      from: alice,
    });
    // create a second zombie
    await utils.shouldThrow(
      contractInstance.createRandomZombie(zombieNames[1], {
        from: alice,
      })
    );
  });
  context("with the single-step transfer scenario", async () => {
    it("should transfer a zombie", async () => {
      // 1. Alice creates a Zombie
      const result = await contractInstance.createRandomZombie(zombieNames[0], {
        from: alice,
      });

      // 2. Get the zombieId
      const zombieId = result.logs[0].args.zombieId.toNumber();

      // 3. Alice transfers the zombie to Bob
      await contractInstance.transferFrom(alice, bob, zombieId, {
        from: alice,
      });

      // 4. Get the new owner of the zombie
      const newOwner = await contractInstance.ownerOf(zombieId);

      // 5. Check if the new owner is Bob
      assert.equal(newOwner, bob);
      // expect(newOwner).to.equal(bob);
    });
  });

  context("with the two-step transfer scenario", async () => {
    it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
      // 1. Alice creates a Zombie
      const result = await contractInstance.createRandomZombie(zombieNames[0], {
        from: alice,
      });

      // 2. Get the zombieId
      const zombieId = result.logs[0].args.zombieId.toNumber();

      // 3. Alice aproves Bob to use her Zombie
      await contractInstance.approve(bob, zombieId, { from: alice });

      // 4.  Bob transfers the zombie to himself
      await contractInstance.transferFrom(alice, bob, zombieId, {
        from: bob,
      });

      // 5. Get the new owner of the zombie
      const newOwner = await contractInstance.ownerOf(zombieId);

      // 6. Check if the new owner is Bob
      assert.equal(newOwner, bob);
      // expect(newOwner).to.equal(bob);
    });
    it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
      const result = await contractInstance.createRandomZombie(zombieNames[0], {
        from: alice,
      });
      const zombieId = result.logs[0].args.zombieId.toNumber();
      await contractInstance.approve(bob, zombieId, { from: alice });
      await contractInstance.transferFrom(alice, bob, zombieId, {
        from: alice,
      });
      const newOwner = await contractInstance.ownerOf(zombieId);
      assert.equal(newOwner, bob);
      // expect(newOwner).to.equal(bob);
    });
  });
  it("zombies should be able to attack another zombie", async () => {
    let result;
    result = await contractInstance.createRandomZombie(zombieNames[0], {
      from: alice,
    });
    const firstZombieId = result.logs[0].args.zombieId.toNumber();
    result = await contractInstance.createRandomZombie(zombieNames[1], {
      from: bob,
    });
    const secondZombieId = result.logs[0].args.zombieId.toNumber();
    await time.increase(time.duration.days(1)); // increase time by 1 day and mines a block (so the timestamp of the mined block is +1 day)
    // now the last block of the blockchain has +1day on its timestamp and we can call attack (attack / feeding cooldown is 0)
    await contractInstance.attack(firstZombieId, secondZombieId, {
      from: alice,
    });
    assert.equal(result.receipt.status, true);
    // expect(result.receipt.status).to.equal(true);
  });
});
