const hre = require("hardhat");

async function main() {
  const [owner, addr1] = await ethers.getSigners();

  const CustomToken = await hre.ethers.getContractFactory("CustomToken");
  const customToken = await CustomToken.deploy();
  await customToken.deployed();
  console.log("CustomToken deployed to:", customToken.address);
  console.log("I got : " + await customToken.balanceOf(owner.address) + " tokens");

  const NFTCollection = await hre.ethers.getContractFactory("NFTCollection");
  const nftCollection = await NFTCollection.deploy();
  await nftCollection.deployed();
  console.log("\nNFTCollection deployed to:", nftCollection.address);
  console.log("Before award I got : " + await nftCollection.balanceOf(owner.address) + " items");

  await nftCollection.awardItem(owner.address, "https://api.npoint.io/0634864660d5d09e1c40");
  await nftCollection.awardItem(owner.address, "https://api.npoint.io/39d6082ace05aa3bd768");
  await nftCollection.awardItem(owner.address, "https://api.npoint.io/1ccb83057ef8120d3959");
  console.log("After award I got : " + await nftCollection.balanceOf(owner.address) + " items");

  const LotteryGenerator = await hre.ethers.getContractFactory("LotteryGenerator");
  const lotteryGenerator = await LotteryGenerator.deploy(customToken.address, nftCollection.address);
  await lotteryGenerator.deployed();
  console.log("\nLotteryGenerator deployed to:", lotteryGenerator.address);
  console.log("Their is currently : " + (await lotteryGenerator.getAllLoteries()).length + " lotteries");

  await nftCollection.approve(lotteryGenerator.address, 1)
  await lotteryGenerator.launchLottery(1, 2, 1);
  console.log("Their is now : " + (await lotteryGenerator.getAllLoteries()).length + " lotteries");
  console.log("The first lottery has : " + (await lotteryGenerator.getAllLoteries())[0].players.length + " players");

  await customToken.approve(lotteryGenerator.address, 10)
  await lotteryGenerator.newPlayer(0);
  console.log("The first lottery has now: " + (await lotteryGenerator.getAllLoteries())[0].players.length + " players");

  console.log("The winner is: " + (await lotteryGenerator.getAllLoteries())[0].winner);
  await lotteryGenerator.endLotteries([1231,]);
  console.log("The winner is: " + (await lotteryGenerator.getAllLoteries())[0].winner);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
