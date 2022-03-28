const main = async () => {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account: ", deployer.address);

  const CustomToken = await hre.ethers.getContractFactory("CustomToken");
  const customToken = await CustomToken.deploy();
  await customToken.deployed();
  console.log("CustomToken deployed to:", customToken.address);

  const NFTCollection = await hre.ethers.getContractFactory("NFTCollection");
  const nftCollection = await NFTCollection.deploy();
  await nftCollection.deployed();
  console.log("\nNFTCollection deployed to:", nftCollection.address);

  await nftCollection.awardItem(deployer.address, "https://api.npoint.io/0634864660d5d09e1c40");
  await nftCollection.awardItem(deployer.address, "https://api.npoint.io/39d6082ace05aa3bd768");
  await nftCollection.awardItem(deployer.address, "https://api.npoint.io/1ccb83057ef8120d3959");
  
  const UsingERC20 = await hre.ethers.getContractFactory("LotteryGenerator");
  const usingERC20 = await UsingERC20.deploy(customToken.address, nftCollection.address);
  await usingERC20.deployed();
  console.log("\nUsingERC20 deployed to:", usingERC20.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();