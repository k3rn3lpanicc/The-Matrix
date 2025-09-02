import { ethers, run } from "hardhat";

const delay = (delayInms: number) => {
  return new Promise((resolve) => setTimeout(resolve, delayInms));
};

async function main() {
  const DuexWallet = "0x02Db08909FD96972CD140Cf08f4aae71aF14D36A";
  const sourceAddress = "0xB06EB598B0d1c65f37E3b5F94B03E4FD91ef33A2";
  const Pills = await ethers.getContractAt("Pills", "0x3f8fFe59CEae8ca186e532501859D73BEc5bCA98");
  const PillPool = await ethers.getContractAt("PillPool", "0x0d9dA66dB7c145E803f7cdB2AdB9fb2eb198DE5D");
  const SourcePool = await ethers.getContractAt("SourcePool", "0xA225C3b3A7AB6143b342ABD3aADC6bf40c25ab62");
  const SecondaryPrizePool = await ethers.getContractAt("SecondaryPrizePool", "0xC86b3f588E054b1f6D606Ad44E9F18158e6e47f6");
  const PrizePool = await ethers.getContractAt("PrizePool", "0x0D6436a7A7FA54FB3e74b17de320Cc3c81693ABa");
  const Matrix = await ethers.getContractAt("Matrix", "0x69ea82e3e950120a8BfC949D8C34D6aDAF97c930");

  // // --------------------------Deploy Pills--------------------------------1
  // console.log(`[ ☕️ ] Deploying the Pills token to chain ...`);
  // const Pills = await ethers.deployContract("Pills", []);
  // console.log(`[ 🟡 ] Pills token deployed to: ${await Pills.getAddress()} , txHash: ${Pills.deploymentTransaction()?.hash} waiting...`);
  // await Pills.waitForDeployment();
  // console.log(`[ ✅ ] Submitted\n`);
  
  // // --------------------------Deploy PillPool--------------------------------2
  // console.log(`[ ☕️ ] Deploying the Pill Pool to chain ...`);
  // const PillPool = await ethers.deployContract("PillPool", [
  //   await Pills.getAddress(),
  // ]);
  // console.log(`[ 🟡 ] PillPool deployed to: ${await PillPool.getAddress()} , txHash: ${PillPool.deploymentTransaction()?.hash} waiting...`);
  // await PillPool.waitForDeployment();
  // console.log(`[ ✅ ] Submitted\n`);

  // // --------------------------Deploy SourcePool--------------------------------3
  // console.log(`[ ☕️ ] Deploying the SourcePool to chain ...`);
  // const SourcePool = await ethers.deployContract("SourcePool", [
  //   sourceAddress
  // ], {
  //   value: 0,
  // });
  // console.log(
  //   `[ 🟡 ] SourcePool deployed to: ${await SourcePool.getAddress()} , txHash: ${SourcePool.deploymentTransaction()?.hash} waiting...`
  // );
  // await SourcePool.waitForDeployment();
  // console.log(`[ ✅ ] Submitted\n`);

  // console.log(`[ 🟡 ] Source token address: ${await SourcePool.sourceToken()}`);
  // console.log(`[ 🟡 ] StSource token address: ${await SourcePool.stSourceToken()}`);

  // // --------------------------Deploy Secondary PrizePool--------------------------------4
  // // await delay(5000);
  // console.log(`[ ☕️ ] Deploying the SecondaryPrizePool to chain ...`);
  // const SecondaryPrizePool = await ethers.deployContract(
  //   "SecondaryPrizePool",
  //   [],
  //   { value: 0 }
  // );
  // console.log(
  //   `[ 🟡 ] SecondaryPrizePool deployed to: ${await SecondaryPrizePool.getAddress()} , txHash: ${SecondaryPrizePool.deploymentTransaction()?.hash} waiting...`
  // );
  // await SecondaryPrizePool.waitForDeployment();
  // console.log(`[ ✅ ] Submitted\n`);

  // // --------------------------Deploy PrizePool--------------------------------5
  // console.log(`[ ☕️ ] Deploying the PrizePool to chain ...`);
  // const PrizePool = await ethers.deployContract(
  //   "PrizePool",
  //   [await SecondaryPrizePool.getAddress()],
  //   { value: 0 }
  // );
  // console.log(`[ 🟡 ] PrizePool deployed to: ${await PrizePool.getAddress()} , txHash: ${PrizePool.deploymentTransaction()?.hash}`);
  // await PrizePool.waitForDeployment();
  // console.log(`[ ✅ ] Submitted\n`);

  // // --------------------------Deploy Matrix--------------------------------7
  // console.log(`[ ☕️ ] Deploying the Matrix to chain ...`);
  // const Matrix = await ethers.deployContract(
  //   "Matrix",
  //   [
  //     await PrizePool.getAddress(),
  //     await SourcePool.getAddress(),
  //     await Pills.getAddress(),
  //     await PillPool.getAddress(),
  //     BigInt(1000) * BigInt(1e18),
  //     await SecondaryPrizePool.getAddress(),
  //     DuexWallet,
  //   ],
  //   { value: 0 }
  // );
  // console.log(`[ ✅ ] Matrix deployed to: ${await Matrix.getAddress()} , txHash: ${Matrix.deploymentTransaction()?.hash} waiting...`);
  // await Matrix.deploymentTransaction()?.wait();
  // console.log(`[ ✅ ] Submitted\n`);

  // console.log(`Deploying the contracts done!\n\n`);

  // // --------------------------Set Game for contracts--------------------------------
  // const tx2 = await SourcePool.setGame(await Matrix.getAddress()); //2
  // console.log(`[ ✅ ] txHash: ${tx2.hash}\n`);
  // await tx2.wait();
  
  // const tx3 = await PrizePool.setGame(await Matrix.getAddress()); //3
  // console.log(`[ 🟡 ] PrizePool set game ...`);
  // await tx3.wait();
  // console.log(`[ ✅ ] txHash: ${tx3.hash}\n`);
  
  // const tx5 = await SecondaryPrizePool.setGame(await Matrix.getAddress()); //5
  // console.log(`[ 🟡 ] SecondaryPrizePool set game ...`);
  // await tx5.wait();
  // console.log(`[ ✅ ] txHash: ${tx5.hash}\n`);
  
  // const tx6 = await Pills.setGame(await Matrix.getAddress()); //7
  // console.log(`[ 🟡 ] Pills set game ...`);
  // await tx6.wait();
  // console.log(`[ ✅ ] txHash: ${tx6.hash}\n`);

  // const tx7 = await PillPool.setGame(await Matrix.getAddress()); //8
  // console.log(`[ 🟡 ] PillPool set game ...`);
  // await tx7.wait();
  // console.log(`[ ✅ ] txHash: ${tx7.hash}\n`);
  
  // const tx8 = await Matrix.setGame(await Matrix.getAddress()); //8
  // console.log(`[ 🟡 ] Matrix set game ...`);
  // await tx8.wait();
  // console.log(`[ ✅ ] txHash: ${tx8.hash}\n`);
  
  // const tx9 = await Pills.setPillPool(await PillPool.getAddress());
  // console.log(`[ 🟡 ] Pills set PillPool ...`);
  // await tx9.wait();
  // console.log(`[ ✅ ] txHash: ${tx9.hash}\n`);

  // console.log(`Set Game for contracts Completed!\n\n`);

  // // --------------------------Transfer OwnerShips to game--------------------------------
  // console.log(`[ 🟡 ] Transfer ownership of PrizePool to game ...`);
  // const transferOwnerShip4 = await PrizePool.transferOwnership(
  //   await Matrix.getAddress()
  // );
  // console.log(
  //   `[ ✅ ] PrizePool transfer ownership to: ${await Matrix.getAddress()}, txHash: ${transferOwnerShip4.hash}\n`
  // );
  // await transferOwnerShip4.wait();
  
  // console.log(`[ 🟡 ] Transfer ownership of PillPool to game ...`);
  // const transferOwnerShip6 = await PillPool.transferOwnership(
  //   await Matrix.getAddress()
  // );
  // console.log(
  //   `[ ✅ ] PillPool transfer ownership to: ${await Matrix.getAddress()}, txHash: ${transferOwnerShip6.hash}\n`
  // );
  // await transferOwnerShip6.wait();

  // console.log(`[ 🟡 ] Transfer ownership of SecondaryPrizePool to game ...`);
  // const transferOwnerShip5 = await SecondaryPrizePool.transferOwnership(
  //   await Matrix.getAddress()
  // );
  // console.log(
  //   `[ ✅ ] SecondaryPrizePool transfer ownership to: ${await Matrix.getAddress()}, txHash: ${transferOwnerShip5.hash}\n`
  // );
  // await transferOwnerShip5.wait();

  // console.log(`[ 🟡 ] Transfer ownership of Pills to game ...`);
  // const transferOwnerShip7 = await Pills.transferOwnership(
  //   await Matrix.getAddress()
  // );
  // console.log(
  //   `[ ✅ ] Pills transfer ownership to: ${await Matrix.getAddress()}, txHash: ${transferOwnerShip7.hash}\n`
  // );
  // await transferOwnerShip7.wait();
  
  // console.log(`[ 🟡 ] Transfer ownership of SourcePool to game ...`);
  // const transferOwnerShip1 = await SourcePool.transferOwnership(
  //   await Matrix.getAddress()
  // );
  // console.log(
  //   `[ ✅ ] SourcePool transfer ownership to: ${await Matrix.getAddress()}, txHash: ${transferOwnerShip1.hash}\n`
  // );
  // await transferOwnerShip1.wait();

  // console.log(`Transferring Ownerships done!\n\n`);

  console.log(`[ 😎 ] Verifying contracts`);
  await run("verify:verify", {
    address: await SourcePool.getAddress(),
    constructorArguments: [
      sourceAddress
    ],
  });
  console.log(`[ 😎 ] SourcePool token: ${await SourcePool.getAddress()}#code`);

  await run("verify:verify", {
    address: await SecondaryPrizePool.getAddress(),
    constructorArguments: [
    ],
  });
  console.log(
    `[ 😎 ] SecondaryPrizePool token: ${await SecondaryPrizePool.getAddress()}#code`
  );

  await run("verify:verify", {
    address: await PrizePool.getAddress(),
    constructorArguments: [await SecondaryPrizePool.getAddress()],
  });
  console.log(`[ 😎 ] PrizePool token: ${await PrizePool.getAddress()}#code`);

  await run("verify:verify", {
    address: await Matrix.getAddress(),
    constructorArguments: [
      await PrizePool.getAddress(),
      await SourcePool.getAddress(),
      await Pills.getAddress(),
      await PillPool.getAddress(),
      BigInt(1000) * BigInt(1e18),
      await SecondaryPrizePool.getAddress(),
      DuexWallet,
    ],
  });
  console.log(`[ 😎 ] Matrix token: ${await Matrix.getAddress()}#code`);
  console.log(`[ 😎 ] Let the game begin!`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
