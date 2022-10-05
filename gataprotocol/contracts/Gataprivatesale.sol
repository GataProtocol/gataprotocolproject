// https://uniswap.org/docs/v2/smart-contracts/pair-erc-20/
// https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2Pair.sol implementation
// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GataPrivateSale is Ownable {
  
    string public constant NAME = "Gata Private Sale"; //name of the contract
    uint256 public  maxCap = 300 * (10**18); // Max cap in BNB

    uint256 public saleStartTime; 
    uint256 public saleEndTime; 

    uint256 public totalBnbReceived; 
 
    address payable public projectOwner; 

    uint256 public maxAllocationPerUser;
    uint256 public minAllocaPerUser;
 
    address[] private whitelist;
    
    mapping(address => uint256) public totalBuy;
    
    address[] public participants;
   
    

    // CONSTRUCTOR
    constructor(
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        address[] memory _whitelist
      ) {

        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;
        
        minAllocaPerUser = 5 * 10 **17;
        
        maxAllocationPerUser = 20 * 10**18;
        
        for (uint256 index = 0; index < _whitelist.length; index++) {
            whitelist.push(_whitelist[index]);
        }
    }

    function setStartTime(uint256 start) external onlyOwner {
        saleStartTime = start;
    }
    function setEndTime(uint256 end) external onlyOwner {
        saleEndTime = end;
    }

    //add the address in Whitelist tier one to invest
    function addWhitelist(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        whitelist.push(_address);
    }

    // check the address in whitelist tier one
    function getWhitelist(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelist.length;
        for (i = 0; i < length; i++) {
            if (whitelist[i] == _address) {
                return true;
            }
        }
        return false;
    }


    // send bnb to the contract address
    receive() external payable {
        if (getWhitelist(msg.sender)) {
            require(block.timestamp <= saleEndTime, "The sale is closed"); 
            require(
                totalBnbReceived + msg.value <= maxCap,
                "buyTokens: purchase would exceed max cap"
            );

            require(
                totalBuy[msg.sender] + msg.value >= minAllocaPerUser,
                "your purchasing Power is so Low"
            );
            require(
                totalBuy[msg.sender] + msg.value <= maxAllocationPerUser,
                "buyTokens:You are investing more than your limit!"
            );
            
            totalBuy[msg.sender] += msg.value;
            participants.push(msg.sender);
            totalBnbReceived += msg.value;
            Address.sendValue(payable(projectOwner), address(this).balance);
        }
        else {
            require(
                block.timestamp >= saleStartTime,
                "The sale is not started yet "
            ); 
            require(block.timestamp <= saleEndTime, "The sale is closed"); 
            require(
                totalBnbReceived + msg.value <= maxCap,
                "buyTokens: purchase would exceed max cap"
            );

            require(
                totalBuy[msg.sender] + msg.value >= minAllocaPerUser,
                "your purchasing Power is so Low"
            );
            require(
                totalBuy[msg.sender] + msg.value <= maxAllocationPerUser,
                "you are investing more than your limit!"
            );
            
            totalBuy[msg.sender] += msg.value;
            participants.push(msg.sender);
            totalBnbReceived += msg.value;
            Address.sendValue(payable(projectOwner), address(this).balance);
        }
    }
}
