//SPDX-License-Identifier:MIT

//Get funds from users
//Withdraw funds
//Set a minimum funding value in USD
//pragma
pragma solidity ^0.8.8;
//imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
//Error code
error FundMe__NotOwner();

//interface, libraries, contracts

contract FundMe {
    //Types declarations
    using PriceConverter for uint256;

    // event Funded(address indexed from, uint256 amount);
    //State Variable
    mapping(address => uint256) private addressToAmountFunded;

    address[] private funders;

    address private immutable owner;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    AggregatorV3Interface private priceFeed;

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //Limit tinkering / triaging to 20 minutes.
    // Take at least 15 minutes yourself -> or be 100% sure
    //you exhausted all options
    //1. Tinker and try to pinpoint exactly what's going on
    //2.goole the exact error
    //2.5 go to course github repo
    //3. ask question on stackoverflow stack exchange etherum

    function fund() public payable {
        //want to be able to minimum funds limit
        //1. how to send ETH to this contract
        // require(msg.value > 1e18, "Didn't Send Enough"); //1e18 = 1*10**18 == 1,000,000,000,000,000,000
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "You need to sped more ETH!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner,"Sender is not owner!");
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        funders = new address[](0);
        //actually withdraw the funds
        //transfer if transfer is failed due to increase in gas fees it return error
        //    payable(msg.sender).transfer(address(this).balance);
        //     //send if transfer is faild it return bool value
        //    bool sendScuss = payable(msg.sender).send(address(this).balance);
        //    require(sendScuss,"Send Failed");
        //     //call

        //Recommended to pay through call function
        (
            bool callSuccess, /*bytes memory dataReturned*/

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory s_funders = funders;
        //mapping can't be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return addressToAmountFunded[funder];
    }

    function getpriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }

    modifier onlyOwner() {
        // require(msg.sender == owner,"Sender is not owner!"); //check the rules
        if (msg.sender != owner) {
            revert FundMe__NotOwner();
        }
        _; //doing rest of the code
    }

    //what happend if someone send  this contract without call fundme function

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

//1. Enums
//2. Events
//3. Try / Catch
//4. Funciton Selector
//5. abi.encode / decode
//6. Hashing
//7. Yul /  Assembly
