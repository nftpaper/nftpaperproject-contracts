module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      skipDryRun: true,
      production: true,
      gasPrice: 128 //50000000

    }
  },
  compilers: {
    solc: {
      version: "^0.8.0"
    }
  }
};