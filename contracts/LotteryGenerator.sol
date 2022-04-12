//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract LotteryGenerator is VRFConsumerBase{
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public owner;
    address gelato_ops = 0x8c089073A9594a4FB03Fa99feee3effF0e2Bc58a;

    IERC20 public associatedToken;
    IERC721 public associatedCollection;

    struct lotteryStruct {
        address owner; //who own this lottery ? = who gonna earn tokens and give NFT in exchange
        uint256 tokenPrizeId; //what is the NFT prize ID ?
        address[] players; //list all the players
        uint256 entryPrice; //how many token they need to pay to access this lottery ?
        uint256 totalTokens; //how many tokens will we won by the owner ?
        address winner; //who is the winner of this lottery ?
        uint256 lotteryStart; //when did the lottery started ?
        uint256 lotteryEnd; //when the lottery gonna be ended ?
        bool ended; //is the lottery ended
    }
    event NewPlayer(uint256 index, address indexed from, uint256 timestamp);
    event NewLot(lotteryStruct lot);
    event EndedLot(lotteryStruct lot);

    lotteryStruct[] lotteries;

    constructor(address _associatedToken,address _associatedCollection) VRFConsumerBase(0x8C7382F9D8f56b33781fE506E897a4F1e2d17255,0x326C977E6efc84E512bB9C30f76E30c160eD06FB) {
        associatedToken = IERC20(_associatedToken);
        associatedCollection = IERC721(_associatedCollection);
        owner = msg.sender;
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18;
    }

    function getRandomNumber() external onlyOwner {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        randomResult = randomness;
        expand(randomness, lotteries.length);
    }

    function expand(uint256 randomValue, uint256 n) internal{
        uint256[] memory expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        endLotteries(expandedValues);
    }

    function launchLottery(uint256 _tokenPrizeId, uint256 _entryPrice, uint256 _duration) public {
        require(associatedCollection.ownerOf(_tokenPrizeId) == msg.sender, "You don't own the token");
        require(_duration >= 1, "The lottery must last more than 1 day");
        associatedCollection.transferFrom(msg.sender, address(this), _tokenPrizeId);

        uint256 _lotteryEnd = block.timestamp + (_duration * 1 days);
        address[] memory _emptyPlayers;
        lotteries.push(lotteryStruct(msg.sender,_tokenPrizeId,_emptyPlayers,_entryPrice, 0, address(0), block.timestamp, _lotteryEnd, false));
        emit NewLot(lotteryStruct(msg.sender,_tokenPrizeId, _emptyPlayers,_entryPrice, 0, address(0), block.timestamp, _lotteryEnd, false));
    }

    function endLotteries(uint256[] memory randomWords) private {
        uint8 _numWords = 0;

        for (uint256 index = 0; index < lotteries.length; index++) {
            uint neededDiff = (lotteries[index].lotteryEnd - lotteries[index].lotteryStart) / 60 / 60 / 24;
            uint currentDiff = (block.timestamp - lotteries[index].lotteryStart) / 60 / 60 / 24;
            if(currentDiff >= neededDiff && lotteries[index].ended == false)
            {
                if (lotteries[index].players.length > 0)
                {
                    uint256 s_randomRange = (randomWords[_numWords] % lotteries[index].players.length);
                    _numWords++;
                    lotteries[index].winner = lotteries[index].players[s_randomRange];
                    associatedToken.transfer(lotteries[index].owner, lotteries[index].totalTokens);
                    associatedCollection.transferFrom(address(this), lotteries[index].players[s_randomRange], lotteries[index].tokenPrizeId);
                }
                else
                    associatedCollection.transferFrom(address(this), lotteries[index].owner, lotteries[index].tokenPrizeId);
                lotteries[index].ended = true;
                emit EndedLot(lotteries[index]);
            }
        }
    }

    function newPlayer(uint256 lotteryIndex) public {
        lotteryStruct storage currentLottery = lotteries[lotteryIndex];
        require(currentLottery.ended == false, "Loterry is ended");
        bool success = associatedToken.transferFrom(msg.sender,address(this),currentLottery.entryPrice);
        if (success) {
            currentLottery.players.push(msg.sender);
            currentLottery.totalTokens += currentLottery.entryPrice;
            emit NewPlayer(lotteryIndex, msg.sender, block.timestamp);
        }
    }

    function getAllLoteries() public view returns (lotteryStruct[] memory){
        return lotteries;
    }

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == gelato_ops);
        _;
    }
    
}
