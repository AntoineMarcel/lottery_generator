require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

module.exports = {
  solidity: "0.8.4",
  networks: {
    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.PRIVATE_KEY]
    },
    rinkeby: {
      url: process.env.SPEEDY_NODE,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};