import { ethers } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Blacklistable, Matrix, PillPool, Pills, PrizePool, SecondaryPrizePool, Source, SourcePool, USDB } from "../typechain-types";

const delay = (delayInms: number) => {
  return new Promise((resolve) => setTimeout(resolve, delayInms));
};

describe("Matrix Contracts", function () {
    let owner: HardhatEthersSigner, addr1: HardhatEthersSigner, addr2: HardhatEthersSigner, addr3: HardhatEthersSigner, duex: HardhatEthersSigner, teamWallet: HardhatEthersSigner;
    let pills: Pills;
    let source: Source;
    let sourcePool: SourcePool;
    let secondaryPrizePool: SecondaryPrizePool;
    let prizePool: PrizePool;
    let pillPool : PillPool;
    let matrix: Matrix;
    let usdbToken: USDB;

    beforeEach(async function () {
    [owner, addr1, addr2, addr3, duex, teamWallet] = await ethers.getSigners();
    
    // deploy usdb
    const USDBToken = await ethers.getContractFactory("USDB");
    usdbToken = await USDBToken.deploy(10000000000);
    await usdbToken.waitForDeployment();
    
    // deploy pills
    const Pills = await ethers.getContractFactory("Pills");
    pills = await Pills.deploy();
    await pills.waitForDeployment();
    
    // deploy pill pool
    const PillPool = await ethers.getContractFactory("PillPool");
    pillPool = await PillPool.deploy(await pills.getAddress());
    await pillPool.waitForDeployment();  

    // deploy source pool
    const SourcePool = await ethers.getContractFactory("SourcePool");
    sourcePool = await SourcePool.deploy();
    await sourcePool.waitForDeployment();
    
    // deploy secondary prize pool
    const SecondaryPrizePool = await ethers.getContractFactory("SecondaryPrizePool");
    secondaryPrizePool = await SecondaryPrizePool.deploy();
    await secondaryPrizePool.waitForDeployment();
    
    // deploy prize pool
    const PrizePool = await ethers.getContractFactory("PrizePool");
    prizePool = await PrizePool.deploy(await secondaryPrizePool.getAddress());
    await prizePool.waitForDeployment();
    
    
    await usdbToken.transfer(await prizePool.getAddress(), BigInt(100_000) * BigInt(1e18));
    
    const Matrix = await ethers.getContractFactory("Matrix");
    matrix = await Matrix.deploy(await usdbToken.getAddress(),
      await pills.getAddress(),
      await source.getAddress(),
      await prizePool.getAddress(),
      await sourcePool.getAddress(),
      await pillPool.getAddress(),
      await duex.getAddress(),
      BigInt(100000)*BigInt(1e18),
      await teamWallet.getAddress(),
      await secondaryPrizePool.getAddress()
    );
    await matrix.waitForDeployment();

    await pillPool.setGame(await matrix.getAddress());
    await sourcePool.setGame(await matrix.getAddress());
    await prizePool.setGame(await matrix.getAddress());
    await secondaryPrizePool.setGame(await matrix.getAddress());
    await source.setGame(await matrix.getAddress());
    await pills.setGame(await matrix.getAddress());
    await matrix.setGame(await matrix.getAddress());

    await pillPool.transferOwnership(await matrix.getAddress());
    await sourcePool.transferOwnership(await matrix.getAddress());
    await prizePool.transferOwnership(await matrix.getAddress());
    await secondaryPrizePool.transferOwnership(await matrix.getAddress());
    await pills.transferOwnership(await matrix.getAddress());
  });

  it("Should deploy the contracts and connect them together", async function () {
  });

  it("Should Purchase 10 red pills", async function () {
    console.log(" > Pill price before purchase 10 red pills: ", Number(await matrix.getPillPrice())/1e18);
    console.log(" > End Time before purchase: ", Number(await matrix.endTime()));
    await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await matrix.connect(addr1).purchasePill(0, 10);
    expect(await pills.totalBalanceOf(await addr1.getAddress())).to.equal(10);
    expect(await matrix.getPillPrice()).to.equal("1000050000000000000");
    console.log(" > Pill Price after purchase 10 red pills: ", Number(await matrix.getPillPrice())/1e18);
    console.log(" > Duex Wallet Balance: ", Number(await usdbToken.balanceOf(await addr1.getAddress()))/1e18);
    console.log(" > PillPool Balance: ", Number(await usdbToken.balanceOf(await pillPool.getAddress()))/1e18);
    console.log(" > SourcePool Balance: ", Number(await usdbToken.balanceOf(await sourcePool.getAddress()))/1e18);
    console.log(" > End Time after purchase: ", Number(await matrix.endTime()));
  });


  it("Should Purchase 10 blue pills", async function () {
    console.log(" > Pill price before purchase 10 red pills: ", Number(await matrix.getPillPrice())/1e18);
    console.log(" > End Time before purchase: ", Number(await matrix.endTime()));
    await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await matrix.connect(addr1).purchasePill(1, 10);
    expect(await pills.totalBalanceOf(await addr1.getAddress())).to.equal(10);
    expect(await matrix.getPillPrice()).to.equal("1000050000000000000");
    console.log(" > Pill Price after purchase 10 blue pills: ", Number(await matrix.getPillPrice())/1e18);
    console.log(" > Duex Wallet Balance: ", Number(await usdbToken.balanceOf(await addr1.getAddress()))/1e18);
    console.log(" > PillPool Balance: ", Number(await usdbToken.balanceOf(await pillPool.getAddress()))/1e18);
    console.log(" > SourcePool Balance: ", Number(await usdbToken.balanceOf(await sourcePool.getAddress()))/1e18);
    console.log(" > End Time after purchase: ", Number(await matrix.endTime()));
  });

  it("Should add time to end of game by buying pills", async function(){
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // let endTime = Number(await matrix.endTime());
    // await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10)*BigInt(1e18));
    // await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    // await matrix.connect(addr1).purchasePill(1, 10);
    // console.log(" > End Time increase after adding time: ", Number(await matrix.endTime()) - endTime);
  });

  it("Should add time to end of game by buying pills v2", async function(){
    // await usdbToken.connect(owner).transfer(await prizePool.getAddress(), BigInt(1e6)*BigInt(1e18));
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // await delay(5000);
    // let endTime = Number(await matrix.endTime());
    // await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10000)*BigInt(1e18));
    // await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10000)*BigInt(1e18));
    // await matrix.connect(addr1).purchasePill(1, 10);
    // console.log(" > End Time increase after adding time: ", Number(await matrix.endTime()) - endTime);
  });

  it("Should set the top 3 players correctly", async function(){
    await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).transfer(await addr3.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).transfer(await addr2.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr2).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr3).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await matrix.connect(addr1).purchasePill(0, 2);
    await matrix.connect(addr2).purchasePill(0, 2);
    await matrix.connect(owner).purchasePill(0,8);
    await matrix.connect(addr1).purchasePill(0,5);
    await matrix.connect(addr3).purchasePill(0, 1);
    console.log("Owner: ", await owner.getAddress());
    console.log("Addr1: ", await addr1.getAddress());
    console.log("Addr2: ", await addr2.getAddress());
    console.log(" > Top 3 players: ", await matrix.top3Players(0), await matrix.top3Players(1), await matrix.top3Players(2));
    console.log(" > Top 3 players scores: ", await matrix.topThreePlayerPills(0), await matrix.topThreePlayerPills(1), await matrix.topThreePlayerPills(2));
  });

  it("Should divide the prices correctly after game ends", async function(){
    // Buy pills
    await usdbToken.connect(owner).transfer(await addr1.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).transfer(await addr3.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).transfer(await addr2.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr1).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr2).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(owner).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await usdbToken.connect(addr3).approve(await matrix.getAddress(), BigInt(10)*BigInt(1e18));
    await matrix.connect(addr1).purchasePill(0, 2);
    await matrix.connect(addr2).purchasePill(0, 2);
    await matrix.connect(owner).purchasePill(0,8);
    await matrix.connect(addr1).purchasePill(0,5);
    await matrix.connect(addr3).purchasePill(0, 1);
    await matrix.connect(owner).setNextRoundPrizePool("0x4200000000000000000000000000000000000022");
    await expect(matrix.connect(owner).endGame()).to.be.revertedWithCustomError(matrix, `MatrixError`);
    await time.increase(24*3600 + 5);
    await usdbToken.connect(owner).transfer(await secondaryPrizePool.getAddress(), BigInt(100)*BigInt(1e18));
    console.log(" > PrizePool Amount before game ended: ", await usdbToken.balanceOf(await prizePool.getAddress()));
    console.log(" > Top 3 player's amount before game ended: ", await usdbToken.balanceOf(await matrix.top3Players(0)), await usdbToken.balanceOf(await matrix.top3Players(1)), await usdbToken.balanceOf(await matrix.top3Players(2)));
    console.log(" > Last purchaser's amount before game ended: ", await usdbToken.balanceOf(await matrix.latestPurchaser()));
    console.log(" > Duex Wallet amount before game ended: ", await usdbToken.balanceOf(await duex.getAddress()));
    console.log(" > Team Wallet amount before game ended: ", await usdbToken.balanceOf(await teamWallet.getAddress()));
    console.log(" > Next round prize pool before game ended: ", await usdbToken.balanceOf(await matrix.nextRoundPrizePool()));
    
    await matrix.connect(owner).endGame();
    console.log(" > Last purchaser's amount after game ended: ", await usdbToken.balanceOf(await matrix.latestPurchaser()));
    console.log(" > PrizePool Amount after game ended: ", await usdbToken.balanceOf(await prizePool.getAddress()));
    console.log(" > Top 3 players amount after the game ended: ", await usdbToken.balanceOf(await matrix.top3Players(0)), await usdbToken.balanceOf(await matrix.top3Players(1)), await usdbToken.balanceOf(await matrix.top3Players(2)));
    console.log(" > Duex Wallet amount after game ended: ", await usdbToken.balanceOf(await duex.getAddress()));
    console.log(" > Team Wallet amount after game ended: ", await usdbToken.balanceOf(await teamWallet.getAddress()));
    console.log(" > Next round prize pool after game ended: ", await usdbToken.balanceOf(await matrix.nextRoundPrizePool()));
  });

});
