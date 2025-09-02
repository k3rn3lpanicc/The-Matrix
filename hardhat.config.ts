import { HardhatUserConfig } from "hardhat/config";
require("dotenv").config();
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
    },
    "blast-mainnet": {
      // url: "https://rough-light-valley.blast-mainnet.quiknode.pro/517618771d93a49734a974c3806dddb06c0018ab/",
      // url : "https://rpc.blast.io",
      url: "https://rpc.ankr.com/blast",
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 1500193917,
    },
    // for Sepolia testnet
    "blast-sepolia": {
      url: "https://compatible-hardworking-film.blast-sepolia.quiknode.pro/11a7baffbf3dd6b36f0df0c70682c20b450bdba4/",
      // url: "https://sepolia.blast.io",
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 8000000000
    },
  },
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  sourcify: {
    enabled: true
  },
  etherscan:{
    apiKey:{
      blast_sepolia: "blast_sepolia",
      "blast-mainnet": process.env.BLAST_API_KEY as string
    },
    customChains: [
      {
        network: "blast_sepolia",
        chainId: 168587773,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
          browserURL: "https://testnet.blastscan.io"
        }
      },{
        network: "blast-mainnet",
        chainId: 81457,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/mainnet/evm/81457/etherscan",
          browserURL: "https://blastscan.io"
        }
      }
    ]
  },
  
};

export default config;
