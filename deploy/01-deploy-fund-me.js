//imports
//main function
//calling of the main function
// we dont use above mentioned only the fol code is being used

// function deployFunc() {
//     console.log("Hi")
// }

// module.exports.default = deployFunc
//above code is ok but we are using new ananmous function

// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre
// writing above mentioned code we just do like this\\\\
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { getNamedAccounts, network, deployments } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //if chainid is x use address y 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    //if chainid is z use address a
    // const ethUsdPriceFeedAdddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAdddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAdddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAdddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    log("----------------------------------------------------")
    log("Deploying FundMe and waiting for confirmations...")

    //we going for localhost network we want to use a mock
    //if the contract doesn't exist, we deploy a minimal version
    const args = [ethUsdPriceFeedAdddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put price feed address
        log: true,
        waitConfirmations: network.config.blockConfrimations || 1,
    })
    log(`FundMe deployed at ${fundMe.address}`)

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        //verify
        await verify(fundMe.address, args)
    }
    log("-------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
