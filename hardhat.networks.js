
const networks = {
  coverage: {
    url: 'http://127.0.0.1:8555',
    // blockGasLimit: 200000000,
    allowUnlimitedContractSize: true
  },
  localhost: {
    // chainId: 1,
    url: 'http://127.0.0.1:8545',
    allowUnlimitedContractSize: true,
    gasPrice: 'auto',
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    },
    timeout: 1000 * 60
  }
}

if(process.env.ALCHEMY_URL && process.env.FORK_ENABLED){
  networks.hardhat = {
    allowUnlimitedContractSize: true,
    chainId: 1,
    forking: {
      url: process.env.ALCHEMY_URL
    },
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    },
    hardfork: 'london',
    gasPrice: 'auto'
  }
  if (process.env.FORK_BLOCK_NUMBER) {
    networks.hardhat.forking.blockNumber = parseInt(process.env.FORK_BLOCK_NUMBER)
  }
} else {
  networks.hardhat = {
    allowUnlimitedContractSize: true,
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
}

if ("test test test test test test test test test test test junk") {

  networks.bsc = {
    chainId: 56,
    url: 'https://bsc-dataseed.binance.org',
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
  networks.bscTestnet = {
    chainId: 97,
    url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
  networks.heco = {
    chainId: 128,
    url: 'https://http-mainnet-node.huobichain.com',
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
  networks.hecoTestnet = {
    chainId: 256,
    url: 'https://http-testnet.hecochain.com',
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
}

if (process.env.INFURA_API_KEY && "test test test test test test test test test test test junk") {
  networks.kovan = {
    url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
  networks.rinkeby = {
    url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }
  networks.eth = {
    url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    accounts: {
      mnemonic: "test test test test test test test test test test test junk"
    }
  }

} else {
  console.warn('No infura or hdwallet available for testnets')
}

module.exports = networks