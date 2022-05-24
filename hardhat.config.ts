import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import "./tasks/accounts";
import "./tasks/clean";

import { resolve } from "path";

import { config as dotenvConfig } from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-etherscan";


require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-web3");


dotenvConfig({ path: resolve(__dirname, "./process.env") });

const chainIds = {
  ganache: 1337,
  goerli: 5,
  hardhat: 31337,
  kovan: 42,
  mainnet: 1,
  bscmainnet: 56,
  matic: 137,
  rinkeby: 4,
  ropsten: 3,
  bsctestnet: 97,
  mumbai:80001 ,
};

// Ensure that we have all the environment variables we need.
let privateKey: string;
if (!process.env.PRIVATE_KEY) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
} else {
  privateKey = process.env.PRIVATE_KEY;
}

let infuraApiKey: string;
if (!process.env.INFURA_API_KEY) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
} else {
  infuraApiKey = process.env.INFURA_API_KEY;
}


function createTestnetConfig(network: keyof typeof chainIds): NetworkUserConfig {
  if (network == "bsctestnet") {
    const url: string = "https://data-seed-prebsc-1-s1.binance.org:8545/";
    
    return {
      accounts: [privateKey],
      chainId: chainIds[network],
      url,
    };
  }
  else if(network == "mumbai"){
    const url: string = "https://rpc-mumbai.maticvigil.com";
    return {
      accounts: [privateKey],
      chainId: chainIds[network],
      url,
    };
    
  }

  else if(network == "matic"){
    const url: string = "https://rpc-mainnet.maticvigil.com";
    const privateKey:any = process.env.PRIVATE_KEY;
    return {
      accounts: [privateKey],
      chainId: chainIds[network],
      url,
    };
    
  }

  else if(network == "bscmainnet"){
    const url: string = "https://bsc-dataseed.binance.org/";
    const privateKey:any = process.env.PRIVATE_KEY;
    return {
      accounts: [privateKey],
      chainId: chainIds[network],
      url,
    };
    
  }
  else {
    const url: string = "https://" + network + ".infura.io/v3/" + infuraApiKey;

    return {
      accounts: [privateKey],
      chainId: chainIds[network],
      url,
    };
  }
}

const config: HardhatUserConfig = {
  defaultNetwork: "develop",
  gasReporter: {
    currency: "USD",
    enabled: process.env.REPORT_GAS ? true : false,
    excludeContracts: [],
    src: "./contracts",
  },
  networks: {
    develop: {
      url: "http://127.0.0.1:8545",
      timeout : 2000000
    },
    goerli: createTestnetConfig("goerli"),
    mainnet: createTestnetConfig("mainnet"),
    kovan: createTestnetConfig("kovan"),
    rinkeby: createTestnetConfig("rinkeby"),
    ropsten: createTestnetConfig("ropsten"),
    bsctestnet: createTestnetConfig("bsctestnet"),
    mumbai: createTestnetConfig("mumbai"),
    bscmainnet: createTestnetConfig("bscmainnet"),
    matic: createTestnetConfig("matic"),
    
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    // apiKey: "ZUQBXSVXNT8RWQDK7Z5NHV4395U5JJFB5M" // matic
    // apiKey: "RQ83XPC9R4JQ9GJFXMIGXFEHZIY1SG1E5V" //mainnet
      apiKey: "FH28YXPI8PWYYQRMGZQNA7FE7UAX8SRA46" //bsc
   // apiKey: "1E4BR12M8S3V56ADI5PRBM7D6M37NJ5DUB" //rinkeby
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          // https://hardhat.org/hardhat-network/#solidity-optimizer-support
          optimizer: {
            enabled: true,
            runs: 1,
          },
        },
      },
      {
        version: "0.8.14",
        settings: {
          // https://hardhat.org/hardhat-network/#solidity-optimizer-support
          optimizer: {
            enabled: true,
            runs: 1,
          },
        },
      }
     
    ],
    
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  mocha: {
    timeout: 200000
  }
};

export default config;