const chai = require("chai");
const expect = chai.expect;

var utils = require('ethers').utils;

const BN = require('bn.js');
chai.use(require('chai-bn')(BN));

const hre = require("hardhat");
var fs = require('fs');
const toWei = (val) => ethers.utils.parseEther('' + val)

console.log(process.argv)

describe("AssetLockManagerContract", function () {

    beforeEach(async function () {

        //准备必要账户
        [deployer, admin, miner, user, redeemaccount] = await hre.ethers.getSigners()
        owner = deployer
        console.log("deployer account:", deployer.address)
        console.log("owner account:", owner.address)
        console.log("admin account:", admin.address)
        console.log("team account:", miner.address)
        console.log("user account:", user.address)
        console.log("redeemaccount account:", redeemaccount.address)
        
        //deploy library
        UtilsCon = await ethers.getContractFactory("Utils", deployer)
        utils = await UtilsCon.deploy();
        //utils = await UtilsCon.attach("0x8F4ec854Dd12F1fe79500a1f53D0cbB30f9b6134")
        await utils.deployed();

        console.log("+++++++++++++Utils+++++++++++++++ ", utils.address)
        
        //deploy ERC20
        erc20SampleCon = await ethers.getContractFactory("ERC20TokenSample", deployer)
        erc20Sample = await erc20SampleCon.deploy()
        //erc20Sample = await erc20SampleCon.attach("0xC66AB83418C20A65C3f8e83B3d11c8C3a6097b6F")
        await erc20Sample.deployed()

        console.log("+++++++++++++Erc20Sample+++++++++++++++ ", erc20Sample.address)

        //deploy contract
		address = "0xa4bA11f3f36b12C71f2AEf775583b306A3cF784a"
        lockContractCon = await ethers.getContractFactory("ERC20Locker", deployer)
        // lockContractCon = await ethers.getContractFactory("ERC20Locker", {
        //     libraries: {
        //       Utils: utils.address,
        //     }
        // }, deployer)
        lockContract = await lockContractCon.deploy(address, address, 1000, admin.address, 0)
        //lockContract = await lockContractCon.attach("0xeF31027350Be2c7439C1b0BE022d49421488b72C")
        console.log("+++++++++++++LockContract+++++++++++++++ ", lockContract.address)
        // await staking.switchOnContract(true)

        //deploy ERC20
        ed25519Con = await ethers.getContractFactory("Ed25519", deployer)
        ed25519 = await ed25519Con.deploy()
         await ed25519.deployed()
        console.log("+++++++++++++ed25519+++++++++++++++ ", lockContract.address)


        //deploy NearBridge
        NearBridgeCon = await ethers.getContractFactory("NearBridge2", deployer)
        NearBridge = await NearBridgeCon.deploy(1000000000000000, admin.address, 0)
        await NearBridge.deployed()
        console.log("+++++++++++++NearBridge+++++++++++++++ ", lockContract.address)

        //deploy NearProver
        NearProverCon = await ethers.getContractFactory("NearProver", deployer)
        NearProver = await NearProverCon.deploy(NearBridge.address, admin.address, 0)
        await NearProver.deployed()
        console.log("+++++++++++++NearProver+++++++++++++++ ", lockContract.address)

    })

    
    it('block test ', async () => {
        console.log("+++++++++++++block test+++++++++++++++ ", lockContract.address)

        const block0 = fs.readFileSync("./block_index_0.bin");
        await NearBridge.connect(admin).initWithBlock(block0);
        
       /* console.log("start block 1 ", lockContract.address)
        const block1 = fs.readFileSync("./block_index_1.bin");
        await NearBridge.connect(admin).addLightClientBlock(block1);

        console.log("start block 2 ", lockContract.address)
        const block2 = fs.readFileSync("./block_index_2.bin");
        await NearBridge.connect(admin).addLightClientBlock(block2);

        const prov_block1 = fs.readFileSync("./prove_index_1.bin");
        await NearProver.connect(admin).proveOutcome(prov_block1, 2);
        console.log("end prov_block1 1 ", lockContract.address)
*/

       // const block3 = fs.readFileSync("./block_index_3.bin");
     //   await NearBridge.addLightClientBlock(block3);
    })

  /*  it('ed25519 test ', async () => {
        console.log("+++++++++++++ed25519+++++++++++++++ ", lockContract.address)

        {

      
        var k = "5d196f3f0d495ffebe06d09dded803b3f275e131e3f662b3904e4929d07b1af8"
        var r = "0d5f61d895fbe3bc7d19b7877a1cbc8677061757f2c614f576799ba3b6092186"
        var s = "640ac5fb43090676cc359baf77f2a0c6bd42dc089660abcb7e64de1b44d67c00";
        var m1 ="0bc7432ef070a5d9e30fa55a9de5fa0ffd5d9ad11cc860e017195e5632a411aa";
        var m2 ="e10d617d3bb865940a";
        

        const result = await ed25519.check(`0x${k}`, `0x${r}`, `0x${s}`, `0x${m1}`, `0x${m2}`);
        
        console.log("result1 ", result)
        }


        {

      
            var k = "b490f9fa48019403b15adc201b4286af00dc20dedc6506d756b6049da0c225cd"
            var r = "2f5c49f5a0d76e0b8c5e6380f073629f72711fd722c88df992aaf4da9173f96a"
            var s = "bcd8a89b799cf0bb4a24b95460c270a32bd6d3b8458e5992fc1e6db97023920e";
            var m1 ="00e237aa9bebea2bac25ac358025dedccca69729862d0964284812166d8d3846";
            var m2 ="8c0200000000000000";
            
    
            const result = await ed25519.check(`0x${k}`, `0x${r}`, `0x${s}`, `0x${m1}`, `0x${m2}`);
            
            console.log("result2 ", result)
            }

    })*/


/*
    it('bind hashasset must be admin', async () => {
        await lockContract.bindAssetHash(erc20Sample.address, 1, address)
    })

    it('bind success uses admin', async () => {
        // amount cannot be zero
        await lockContract.connect(admin).bindAssetHash(erc20Sample.address, 1, address)
    })

    it('amount cannot be zero', async () => {
        // amount cannot be zero
        await lockContract.lockToken(erc20Sample.address, 0, 0, address)
    })

    // it('amount must be less than ((1 << 128) -1)', async () => {
    //     // amount cannot be zero
    //     await lockContract.lockToken(erc20Sample.address, 0, (1<<128 + 1), address)

    //     console.log(".....")
    // })

    it('erc20 contract must be binded', async () => {
        // amount cannot be zero
        // amount cannot be zero
        await lockContract.connect(admin).bindAssetHash(erc20Sample.address, 1, address)
        await lockContract.lockToken(erc20Sample.address, 0, 1, address)
    })


    it('lock fail because of not allowance', async () => {
        // amount cannot be zero
        // amount cannot be zero
        await lockContract.connect(admin).bindAssetHash(erc20Sample.address, 1, address)
        await lockContract.lockToken(erc20Sample.address, 1, 1, address)
    })

    
    it('lock fail because of allowance is not enough', async () => {
        // amount cannot be zero
        // amount cannot be zero
        await erc20Sample.approve(lockContract.address, 1000)
        await lockContract.connect(admin).bindAssetHash(erc20Sample.address, 1, address)
        await lockContract.lockToken(erc20Sample.address, 1, 2000, address)
    })

    it('lock success', async () => {
        // amount cannot be zero
        await erc20Sample.approve(lockContract.address, 1000)
        await lockContract.connect(admin).bindAssetHash(erc20Sample.address, 1, user.address)
        try {
            const tx = await lockContract.lockToken(erc20Sample.address, 1, 1, user.address)
            // console.log(tx)
            const rc = await tx.wait()
            const event = rc.events.find(event=>event.event === "Locked")
            // const latestBlock = await hre.ethers.provider.getBlock("latest")
            // console.log(latestBlock)

            const latestBlock = await hre.ethers.provider.getBlock(1)
            console.log(latestBlock)
            //await lockContract.parseLog(rc.logs[event.logIndex])
        } catch (error) {
            console.log(error)
        }        
    })*/
});