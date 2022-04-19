// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LotteryNFT.sol";

contract Lottery is Ownable {
    using SafeMath for uint256;

    struct CandidateInfo {
        address user;
        uint256 tokenId;
        uint256 remainCount;
    }

    struct WinnerInfo {
        address user;
        uint256 tokenId;
    }

    struct NFTInfo {
        uint256 tokenId;
        uint256 createTime;
    }

    event BuyNFT(address sender, uint256 nCount);
    event CreateNest(address sender, uint256 TYPE, uint256 walletCount, uint256 nestCount);
    event SetPeriodTime(address sender, uint256 period);
    event SetMaxOrderCount(address sender, uint256 count);
    event SetNFTPrice(address sender, uint256 newPrice1, uint256 newPrice2, uint256 newPrice3, uint256 newPrice4, uint256 newPrice5);
    event SetLotteryFee(address sender, uint256 lotteryFee);
    event SetContractStatus(address sender, uint256 _newPauseContract);
    event SetTierCount(address sender, uint256 tier1, uint256 tier2, uint256 tier3, uint256 tier4, uint256 tier5);
    event SetTeamWalletFee(address sender, uint256 fee);
    event SetTeamWallet(address sender, address wallet);
    event SetWinnerWallet(address sender, address wallet);
    event SetLotteryFee(address sender, uint256 winnerFee, uint256 teamFee);
    event PayLotteryFee(address sender, uint256 nCount);
    event ChangeTier(address sender, uint256 nTier);
    event SetBackendWallet(address sender, address wallet);
    event SetSplitRate(address sender, uint256 splitRate);
    event SetMinRepeatCount(address sender, uint256 minCount);

    event Received(address sender, uint256 value);
    event Fallback(address sender, uint256 value);

    uint256[5] _tierCount;

    uint256 pauseContract               = 0;
    uint256 MAX_ORDER_COUNT             = 20;               // maximum nft order count
    uint256 ONE_PERIOD_TIME             = 7 * 86400;        // seconds for one day
    uint256 ONETIME_LOTTERY_FEE         = 10**16;
    uint256 _nftPrice                   = 2 * 10**18;       // 2 avax
    uint256 _unit                       = 10**18;
    uint256 _teamWalletFee              = 20;
    uint256 _teamLoyaltyFee             = 250;
    uint256 _winnerLoyalty              = 500;
    uint256 _splitRate                  = 500;              // rate of balance0, / 1000
    uint256 _nextTierLevel              = 0;
    uint256 _minRepeatCount             = 4;
    uint256[2] public _avaxBalance;
    uint256[2] public _walletBalance;
    uint256 public _totalNFT;
    uint256 public _lotteryRewards;
    uint256 public _lotteryCount;
    uint256 public _lastLottery;
    uint256[5] _nftPrices;

    address _teamWallet                 = 0x697A32dB1BDEF9152F445b06d6A9Fd6E90c02E3e; // team wallet
    address _winnerWallet               = 0x697A32dB1BDEF9152F445b06d6A9Fd6E90c02E3e; // winner wallet
    address _backendWallet              = 0xDe08d67dcDfFBC9c016af5F3b8011A87d234523d; // backend wallet
    mapping(uint256 => address)[2] _wallets;
    mapping(address => uint256) _lotteryFee;
    mapping(uint256 => uint256) _winnerCounts;
    mapping(uint256 => uint256) _createTime;
    mapping(uint256 => mapping(uint256 =>WinnerInfo)) _winners;

    LotteryNFT                  _lotteryNFT;

    /**
    * @dev Throws if called by any account other than the multi-signer.
    */
    modifier onlyMultiSignWallet() {
        require(owner() == _msgSender(), "Multi-signer: caller is not the multi-signer");
        _;
    }

    /**
    * @dev Throws if called by any account other than the multi-signer.
    */
    modifier onlyBackendWallet() {
        require(_backendWallet == _msgSender() || owner() == _msgSender(), "caller is not the backend wallet");
        _;
    }

    /**
    * @dev pause bond and redeem when pauseContract set 1
    */
    modifier disablePause() {
        require(pauseContract == 0, "Contract Paused");
        _;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable { 
        emit Fallback(msg.sender, msg.value);
    }

    constructor(address lotteryNFTAddress) {
        _lotteryNFT = LotteryNFT(lotteryNFTAddress);

        setNFTPrice(_nftPrice, _nftPrice + 5*10**17, _nftPrice + 10*10**17, _nftPrice + 15*10**17, _nftPrice + 20*10**17);
        _totalNFT = _lotteryNFT.totalSupply();
        setTierCount(2000, 4000, 6000, 8000, 10000);

        //test ----
        setNFTPrice(10**15, 10**15 + 5*10**16, 10**15 + 10*10**16, 10**15 + 15*10**16, 10**15 + 20*10**16);
        ONE_PERIOD_TIME = 300;
        setTierCount(12, 24, 36, 48, 60);
    }

    function buyLotteryNFT(uint256 nCount) external payable {
        require(msg.value >= _nftPrice * nCount, "insufficient funds");
        require(nCount <= MAX_ORDER_COUNT, "exceed maximum order count");
        require(_totalNFT+nCount <= _tierCount[4], "exceed maximum NFT count");
        // send team fee
        uint256 teamVal = _nftPrice * nCount * _teamWalletFee / 1000;
        if(teamVal > 0) {
            payable(_teamWallet).transfer(teamVal);
        }

        // split balance
        uint256 val = (_nftPrice * nCount - teamVal);
        _avaxBalance[0] += val * _splitRate / 1000;
        _avaxBalance[1] += val - (val * _splitRate / 1000);

        uint256 tokenId;
        // mint nCount NFT
        for(uint256 i=0; i<nCount; i++) {
            tokenId = _lotteryNFT.mint(msg.sender);
            _createTime[tokenId] = block.timestamp;
        }
        if(_totalNFT+nCount >= _tierCount[_nextTierLevel]) {
            changeTier();
        }
        _totalNFT+=nCount;
        emit BuyNFT(msg.sender, nCount);
    }

    function changeTier() public onlyMultiSignWallet{
        _nextTierLevel++;
        emit ChangeTier(msg.sender, getTier(_totalNFT));
    }

    function getAllNFT(address owner) external view returns(NFTInfo[] memory) {
        uint256 ct = _lotteryNFT.balanceOf(owner);
        NFTInfo[] memory res = new NFTInfo[](ct);
        for(uint256 i=0; i<ct; i++) {
            res[i].tokenId = _lotteryNFT.tokenOfOwnerByIndex(owner, i);
            res[i].createTime = _createTime[res[i].tokenId];
        }
        return res;
    }

    function payLotteryFee() external payable {
        require(msg.value >= ONETIME_LOTTERY_FEE, "insufficient lottery fee");
        uint256 nCount = msg.value / ONETIME_LOTTERY_FEE;
        require(nCount >= _minRepeatCount, "lower than mininum repeat count");
        if(_lotteryFee[msg.sender] < _lotteryCount) {
            _lotteryFee[msg.sender] = _lotteryCount;
        }
        _lotteryFee[msg.sender] += nCount;
        emit PayLotteryFee(msg.sender, nCount);
    }

    function startLottery() external onlyBackendWallet disablePause{
        require(block.timestamp - _lastLottery >= ONE_PERIOD_TIME, "insufficient lottery period");
        
        //increase lottery count;
        _lotteryCount++;
        //update last lottery time;
        _lastLottery = block.timestamp;
    }

    function getWinners(uint256 lotteryIndex) external view returns(WinnerInfo[] memory winners){
        winners = new WinnerInfo[](_winnerCounts[lotteryIndex]);
        for(uint256 i=0; i<_winnerCounts[lotteryIndex]; i++) {
            winners[i] = _winners[lotteryIndex][i];
        }
        return winners;
    }

    function setWinners(uint256 lotteryIndex, WinnerInfo[] memory winners) external onlyBackendWallet{
        require(lotteryIndex < _lotteryCount, "invalid lottery index");
        for(uint256 i=0; i<winners.length; i++) {
            _winners[lotteryIndex][i] = winners[i];
        }
        _winnerCounts[lotteryIndex] = winners.length;
    }

    function getCandidates(uint256 nStart, uint256 nCount) external view returns(CandidateInfo[] memory) {
        if(nCount == 0) {// when nCount == 0, get all candidates.
            nCount = _totalNFT;
        }
        if(nStart + nCount > _totalNFT) {
            nCount = _totalNFT - nStart;
        }
        CandidateInfo[] memory candidates = new CandidateInfo[](nCount);
        for(uint256 i = 0; i < nCount; i++) {
            candidates[i].tokenId = nStart + i;
            candidates[i].user = _lotteryNFT.ownerOf(candidates[i].tokenId);
            if(_lotteryFee[candidates[i].user] > _lotteryCount) {
                candidates[i].remainCount = _lotteryFee[candidates[i].user] - _lotteryCount;
            }
        }
        return candidates;
    }

    function getTier(uint256 nftCount) public view returns(uint256) {
        if(nftCount <= _tierCount[0]) return 1;
        if(nftCount <= _tierCount[1]) return 2;
        if(nftCount <= _tierCount[2]) return 3;
        if(nftCount <= _tierCount[3]) return 4;
        if(nftCount <= _tierCount[4]) return 5;
        return 6;
    }

    function getTierCount() external view returns(uint256, uint256, uint256,uint256, uint256) {
        return (_tierCount[0], _tierCount[1], _tierCount[2], _tierCount[3], _tierCount[4]);
    }

    function setTierCount(uint256 tier1, uint256 tier2, uint256 tier3, uint256 tier4, uint256 tier5) public onlyMultiSignWallet{
        _tierCount[0] = tier1;
        _tierCount[1] = tier2;
        _tierCount[2] = tier3;
        _tierCount[3] = tier4;
        _tierCount[4] = tier5;
        emit SetTierCount(msg.sender, tier1, tier2, tier3, tier4, tier5);
    }

    function transferAssetOwner(address asset, address to) external onlyMultiSignWallet {
        Ownable(asset).transferOwnership(to);
    }

    function getNFTPrice() public view returns(uint256) {
        return _nftPrices[getTier(_totalNFT+1)-1];
    }

    function setNFTPrice(uint256 newPrice1, uint256 newPrice2, uint256 newPrice3, uint256 newPrice4, uint256 newPrice5) public onlyMultiSignWallet disablePause{
        _nftPrice = newPrice1;
        _nftPrices[0] = newPrice1;
        _nftPrices[1] = newPrice2;
        _nftPrices[2] = newPrice3;
        _nftPrices[3] = newPrice4;
        _nftPrices[4] = newPrice5;
        emit SetNFTPrice(msg.sender, newPrice1, newPrice2, newPrice3, newPrice4, newPrice5);
    }

    function getLotteryFee() external view returns(uint256) {
        return ONETIME_LOTTERY_FEE;
    }

    function setLotteryFee(uint256 lotteryFee) external onlyMultiSignWallet disablePause{
        ONETIME_LOTTERY_FEE = lotteryFee;
        emit SetLotteryFee(msg.sender, lotteryFee);
    }

    function getPeriodTime() external view returns(uint256) {
        return ONE_PERIOD_TIME;
    }

    function setPeriodTime(uint256 period) external onlyMultiSignWallet disablePause{
        ONE_PERIOD_TIME = period;
        emit SetPeriodTime(msg.sender, period);
    }

    function getTeamWalletFee() external view returns(uint256) {
        return _teamWalletFee;
    }

    function setTeamWalletFee(uint256 fee) external onlyMultiSignWallet disablePause{
        _teamWalletFee = fee;
        emit SetTeamWalletFee(msg.sender, fee);
    }

    function getLoyaltyFee() external view returns(uint256, uint256) {
        return (_winnerLoyalty, _teamLoyaltyFee);
    }

    function setLoyaltyFee(uint256 winnerFee, uint256 teamFee) external onlyMultiSignWallet disablePause{
        require(winnerFee <= 1000, "winnerFee is too high.");
        require(teamFee <= 1000, "teamFee is too high.");
        require(winnerFee + teamFee <= 1000, "invalid parameter.");
        _winnerLoyalty = winnerFee;
        _teamLoyaltyFee = teamFee;
        emit SetLotteryFee(msg.sender, winnerFee, teamFee);
    }

    function getTeamWallet() external view returns(address) {
        return _teamWallet;
    }

    function setTeamWallet(address team) external onlyMultiSignWallet disablePause{
        _teamWallet = team;
        emit SetTeamWallet(msg.sender, team);
    }

    function getWinnerWallet() external view returns(address) {
        return _winnerWallet;
    }

    function setWinnerWallet(address addr) external onlyMultiSignWallet disablePause{
        _winnerWallet = addr;
        emit SetWinnerWallet(msg.sender, addr);
    }

    function getMaxOrderCount() external view returns(uint256) {
        return MAX_ORDER_COUNT;
    }

    function setMaxOrderCount(uint256 count) external onlyMultiSignWallet disablePause{
        MAX_ORDER_COUNT = count;
        emit SetMaxOrderCount(msg.sender, count);
    }

    function getContractStatus() external view returns (uint256) {
        return pauseContract;
    }

    function setContractStatus(uint256 _newPauseContract) external onlyMultiSignWallet disablePause {
        pauseContract = _newPauseContract;
        emit SetContractStatus(msg.sender, _newPauseContract);
    }

    function getBackendWallet() external view returns (address) {
        return _backendWallet;
    }

    function setBackendWallet(address wallet) external onlyMultiSignWallet disablePause {
        _backendWallet = wallet;
        emit SetBackendWallet(msg.sender, wallet);
    }

    function getSplitRate() external view returns (uint256) {
        return _splitRate;
    }

    function setSplitRate(uint256 splitRate) external onlyMultiSignWallet disablePause {
        _splitRate = splitRate;
        emit SetSplitRate(msg.sender, splitRate);
    }

    function getMinRepeatCount() external view returns (uint256) {
        return _minRepeatCount;
    }

    function setMinRepeatCount(uint256 minCount) external onlyMultiSignWallet disablePause {
        _minRepeatCount = minCount;
        emit SetMinRepeatCount(msg.sender, minCount);
    }

    function withdraw(address tokenAddress, uint256 amount, address payable to) external onlyMultiSignWallet {
        uint256 balance;
        if(tokenAddress != address(0)) {
            balance = IERC20(tokenAddress).balanceOf(address(this));
            if(balance < amount) {
                amount = balance;
            }
            IERC20(tokenAddress).transfer(to, amount);
        } else {
            balance = address(this).balance;
            if(balance < amount) {
                amount = balance;
            }
            to.transfer(amount);
        }
    }
}
