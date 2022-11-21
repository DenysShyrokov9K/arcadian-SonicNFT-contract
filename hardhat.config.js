const dotenv = require("dotenv");
require("@nomicfoundation/hardhat-toolbox");

dotenv.config();

module.exports = {
  solidity: "0.8.9",
  networks: {
    harmony: {
      url: process.env.HARMONY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },

    avalanche: {
      url: process.env.AVALANCHE_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};