// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "../IUniswapV2Router02.sol";///test----
import "../IJoeRouter02.sol";

import "../RewardManagement.sol";
import "./LotteryNFT.sol";
import "./Wallet.sol";

contract Lottery is Ownable {
    using SafeMath for uint256;

    struct CandidateInfo {
        address user;
        uint256 tokenId;
        uint256 remainCount;
    }
    event BuyNFT(address sender, uint256 nCount);
    event CreateNest(address sender, uint256 TYPE, uint256 walletCount, uint256 nestCount);
    event SetPeriodTime(address sender, uint256 period);
    event SetMaxOrderCount(address sender, uint256 count);
    event SetNFTPrice(address sender, uint256 count);
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

    event Received(address sender, uint256 value);
    event Fallback(address sender, uint256 value);

    uint256[5] _tierCount;

    uint256 pauseContract               = 0;
    uint256 MAX_ORDER_COUNT             = 10;               // maximum nft order count
    uint256 ONE_PERIOD_TIME             = 7 * 86400;        // seconds for one day
    uint256 ONETIME_LOTTERY_FEE         = 10**16;
    uint256 _nftPrice                   = 2 * 10**18;       // 2 avax
    uint256 _unit                       = 10**18;
    uint256 _teamWalletFee              = 20;
    uint256 _teamLoyaltyFee             = 250;
    uint256 _winnerLoyalty              = 500;
    uint256 _nextTierLevel              = 0;
    uint256[2] public _avaxBalance;
    uint256[2] public _fireBalance;
    uint256[2] public _nestBalance;
    uint256[2] public _currentNestCount;
    uint256[2] public _walletBalance;
    uint256 public _totalNFT;
    uint256 public _lotteryRewards;
    uint256 public _lotteryCount;
    uint256 public _lastLottery;
    uint256[5] _nftPrices;

    bool pauseCompound                  = false;
    address _teamWallet                 = 0x697A32dB1BDEF9152F445b06d6A9Fd6E90c02E3e; //team wallet
    address _winnerWallet               = 0x697A32dB1BDEF9152F445b06d6A9Fd6E90c02E3e; //winner wallet
    address _backendWallet              = 0xDe08d67dcDfFBC9c016af5F3b8011A87d234523d; // backend wallet
    mapping(uint256 => address)[2] _wallets; 
    mapping(address => uint256) _lotteryFee;

    IERC20 private _usdtToken;
    // IUniswapV2Router02 public _joe02Router; // test ---
    IJoeRouter02        public _joe02Router;

    RewardManagement            _rewardMgmt;
    FireToken                   _fire;
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

    constructor(address fireAddress, address payable rewardAddress, address lotteryNFTAddress) {
        _rewardMgmt = RewardManagement(rewardAddress);
        _fire = FireToken(fireAddress);
        _lotteryNFT = LotteryNFT(lotteryNFTAddress);

        setNFTPrice(_nftPrice);
        _totalNFT = _lotteryNFT.totalSupply();
        _joe02Router = IJoeRouter02(0x7E3411B04766089cFaa52DB688855356A12f05D1);//test -----Fuji
        _usdtToken = IERC20(0x08a978a0399465621e667C49CD54CC874DC064Eb);//test ------Fuji
        // _joe02Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); /// test ----Ropsten
        // _usdtToken = IERC20(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);  /// test----Ropsten
        // _joe02Router = IJoeRouter02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        // _usdtToken = IERC20(0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664);
        setTierCount(2000, 4000, 6000, 8000, 10000);

        //test ----
        setNFTPrice(10**15);
        ONE_PERIOD_TIME = 300;
        setTierCount(12, 24, 36, 48, 60);
    }

    function buyLotteryNFT(uint256 nCount) external payable {
        require(msg.value >= _nftPrice * nCount, "insufficient funds");
        require(nCount <= MAX_ORDER_COUNT, "exceed maximum order count");
        require(_totalNFT+nCount <= _tierCount[4], "exceed maximum NFT count");
        // send team fee
        uint256 teamVal = msg.value * _teamWalletFee / 1000;
        payable(_teamWallet).transfer(teamVal);

        // add n2 avax
        _avaxBalance[1] += (msg.value - teamVal);

        uint256 reserveFire = checkFireCondition() * 10**18;
        uint256 reserveAvax;
        if(reserveFire > 0) {
            //swap from avax to 1 fire.
            reserveAvax = getAvaxForFireIn(reserveFire);
            swapAvaxForTokens(reserveAvax, reserveFire);
            _avaxBalance[1] -= reserveAvax;
            _fireBalance[1] += reserveFire;
        }

        if(checkNestCondition(1) == true) {
            createNest(1);
        }

        // mint nCount NFT
        for(uint256 i=0; i<nCount; i++) {
            _lotteryNFT.mint(msg.sender);
        }
        if(_totalNFT+nCount >= _tierCount[_nextTierLevel]) {
            changeTier();
        }
        _totalNFT+=nCount;
        emit BuyNFT(msg.sender, nCount);
    }

    function createNest(uint256 TYPE) public {
        if(pauseCompound == true) return;
        Wallet wallet;
        if(_currentNestCount[TYPE] % 100 == 0) {
            // create new wallet
            wallet = new Wallet(address(this), address(_rewardMgmt), address(_fire));
            _wallets[TYPE][_walletBalance[TYPE]] = address(wallet);
            _walletBalance[TYPE]++;
            _currentNestCount[TYPE] = 0;
        } else {
            // import existing wallet
            wallet = Wallet(payable(_wallets[TYPE][_walletBalance[TYPE]-1]));
        }
        uint256 fee = _rewardMgmt.getNodeMaintenanceFee();
        uint256 nodePrice = _rewardMgmt.getNodePrice();
        _fire.transfer(address(wallet), nodePrice);
        wallet.buyNode{value:fee}(1);
        _fireBalance[TYPE] -= nodePrice;
        _avaxBalance[TYPE] -= fee;
        _nestBalance[TYPE]++;
        _currentNestCount[TYPE]++;
        emit CreateNest(msg.sender, TYPE, _walletBalance[TYPE], _currentNestCount[TYPE]);
    }

    function changeTier() public onlyMultiSignWallet{
        for(uint256 i=0; i<_walletBalance[1]; i++) {
            _wallets[0][_walletBalance[0]+i] = _wallets[1][i];
            _wallets[1][i] = address(0);
        }
        _avaxBalance[0] += _avaxBalance[1];
        _avaxBalance[1] = 0;
        _fireBalance[0] += _fireBalance[1];
        _fireBalance[1] = 0;
        _nestBalance[0] += _nestBalance[1];
        _nestBalance[1] = 0;
        _walletBalance[0] += _walletBalance[1];
        _walletBalance[1] = 0;
        if(_currentNestCount[1] > 0) {
            _currentNestCount[0] = _currentNestCount[1];
            _currentNestCount[1] = 0;
        }
        _nextTierLevel++;
        emit ChangeTier(msg.sender, getTier(_totalNFT));
    }

    function payLotteryFee() external payable {
        require(msg.value >= ONETIME_LOTTERY_FEE, "insufficient lottery fee");
        uint256 nCount = msg.value / ONETIME_LOTTERY_FEE;
        if(_lotteryFee[msg.sender] < _lotteryCount) {
            _lotteryFee[msg.sender] = _lotteryCount;
        }
        _lotteryFee[msg.sender] += nCount;
        emit PayLotteryFee(msg.sender, nCount);
    }

    function payWallet(uint256 walletIndex) external payable {
        uint256 idx;
        uint256 TYPE;
        (TYPE, idx) = getIndexTypeFromGlobalIndex(walletIndex);
        _avaxBalance[TYPE] += msg.value;
        Wallet wallet = Wallet(payable(_wallets[TYPE][idx]));
        uint256 fee = wallet.getNestCount() * _rewardMgmt.getNodeMaintenanceFee();
        wallet.payAllNodeFee{value:fee}(RewardManagement.MODE_FEE.THREE_MONTH);
        require(_avaxBalance[TYPE] >= fee, "no enough avax for pay fee");
        _avaxBalance[TYPE] -= fee;
    }

    function claimWallet(uint256 walletIndex) external payable {
        uint256 idx;
        uint256 TYPE;
        (TYPE, idx) = getIndexTypeFromGlobalIndex(walletIndex);
        _avaxBalance[TYPE] += msg.value;
        Wallet wallet = Wallet(payable(_wallets[TYPE][idx]));
        uint256 claimFee = wallet.getNestCount() * _rewardMgmt.getClaimFee();
        uint256 rewards = wallet.claimAll{value:claimFee}();
        require(_avaxBalance[TYPE] >= claimFee, "no enough avax for claim fee");
        _avaxBalance[TYPE] -= claimFee;
        _fireBalance[TYPE] += rewards;
   }

    function getWallet(uint256 walletIndex) external view returns(address) {
        uint256 idx;
        uint256 TYPE;
        (TYPE, idx) = getIndexTypeFromGlobalIndex(walletIndex);
        return _wallets[TYPE][idx];
    }

    function getWalletReward(uint256 walletIndex) external view returns(uint256) {
        uint256 idx;
        uint256 TYPE;
        (TYPE, idx) = getIndexTypeFromGlobalIndex(walletIndex);
        RewardManagement.RewardInfo memory rwInfo = _rewardMgmt.getRewardAmount(_wallets[TYPE][idx]);
        uint256 reward;
        for(uint256 i=0; i<rwInfo.nodeRewards.length; i++) {
            reward += rwInfo.nodeRewards[i];
        }
        return reward;
    }

    function getIndexTypeFromGlobalIndex(uint256 walletIndex) private view returns(uint256 TYPE, uint256 idx) {
        require(walletIndex < _walletBalance[0] + _walletBalance[1], "exceed total wallet count");
        idx = walletIndex;
        if(walletIndex >= _walletBalance[0]) {
            idx -= _walletBalance[0];
            TYPE = 1;
        }
        return (TYPE, idx);        
    }

    function startLottery() external onlyBackendWallet disablePause{
        require(block.timestamp - _lastLottery >= ONE_PERIOD_TIME, "insufficient lottery period");
        
        //save lottery rewards
        _lotteryRewards = _fireBalance[0]; 
        //calculate teamReward, winnerReward
        uint256 teamReward = _lotteryRewards * _teamLoyaltyFee / 1000;
        uint256 winnerReward = _lotteryRewards * _winnerLoyalty / 1000;

        //increase lottery count;
        _lotteryCount++;
        //update last lottery time;
        _lastLottery = block.timestamp;
        if(_fireBalance[0] >= teamReward && _fire.balanceOf(address(this)) >= teamReward) {
            _fire.transfer(_teamWallet, teamReward);
            _fireBalance[0] -= teamReward;
        }
        if(_fireBalance[0] >= winnerReward && _fire.balanceOf(address(this)) >= winnerReward) {
            _fire.transfer(_winnerWallet, winnerReward);
            _fireBalance[0] -= winnerReward;
        }
        while(checkNestCondition(0) == true) {
            createNest(0);
        }       
        while(checkNestCondition(1) == true) {
            createNest(1);
        }
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

    function getWalletCount() external view returns(uint256) {
        return _walletBalance[0] + _walletBalance[1];
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

    function checkFireCondition() public view returns(uint256) {
        uint256 nestFee = _rewardMgmt.getNodeMaintenanceFee();
        if(nestFee > _avaxBalance[1]) return 0;
        uint256 avaxForFire = getAvaxForFireOut(_avaxBalance[1] - nestFee);
        return avaxForFire / (10**_fire.decimals());
    }

    function checkNestCondition(uint256 TYPE) public view returns(bool condition) {
        uint256 nodePrice = _rewardMgmt.getNodePrice();
        uint256 nodeFee = _rewardMgmt.getNodeMaintenanceFee();
        if(_fire.balanceOf(address(this)) < nodePrice || _fireBalance[TYPE] < nodePrice) {
            return false;
        }
        if(address(this).balance < nodeFee || _avaxBalance[TYPE] < nodeFee) {
            return false;
        }
        return true;
    }

    function transferAssetOwner(address asset, address to) external onlyMultiSignWallet {
        Ownable(asset).transferOwnership(to);
    }

    function getNFTPrice() public view returns(uint256) {
        return _nftPrices[getTier(_totalNFT+1)-1];
    }

    function setNFTPrice(uint256 newPrice) public onlyMultiSignWallet disablePause{
        _nftPrice = newPrice;
        _nftPrices[0] = _nftPrice;
        _nftPrices[1] = _nftPrice + _unit/2;
        _nftPrices[2] = _nftPrice + _unit;
        _nftPrices[3] = _nftPrice + 3 * _unit/2;
        _nftPrices[4] = _nftPrice + 2 * _unit;
        emit SetNFTPrice(msg.sender, newPrice);
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

    function getAvaxForUSD(uint usdAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(_usdtToken);
        // path[1] = _joe02Router.WETH();// test ----
        path[1] = _joe02Router.WAVAX();
        return _joe02Router.getAmountsOut(usdAmount, path)[1];
    }

    function getAvaxForFireIn(uint fireAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        // path[0] = _joe02Router.WETH();/// test ----
        path[0] = _joe02Router.WAVAX();
        path[1] = address(_fire);
        return _joe02Router.getAmountsIn(fireAmount, path)[0];
    }

    function getAvaxForFireOut(uint avaxAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        // path[0] = _joe02Router.WETH();/// test ----
        path[0] = _joe02Router.WAVAX();
        path[1] = address(_fire);
        return _joe02Router.getAmountsOut(avaxAmount, path)[1];
    }

    function getFireForAvaxOut(uint fireAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(_fire);
        // path[1] = _joe02Router.WETH();/// test ----
        path[1] = _joe02Router.WAVAX();
        return _joe02Router.getAmountsOut(fireAmount, path)[1];
    }

    function swapTokensForAVAX(uint256 tokenAmount) public {
        address[] memory path = new address[](2);
        path[0] = address(_fire);
        path[1] = _joe02Router.WAVAX();
        // path[1] = _joe02Router.WETH(); /// test ---

        _fire.approve(address(_joe02Router), tokenAmount);
                    
        // _joe02Router.swapExactTokensForETHSupportingFeeOnTransferTokens(// test ---
        _joe02Router.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of WAVAX
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAvaxForTokens(uint256 avaxAmount, uint256 fireAmountOut) public {
        address[] memory path = new address[](2);
        path[0] = _joe02Router.WAVAX();
        // path[0] = _joe02Router.WETH(); /// test ---
        path[1] = address(_fire);

        // _joe02Router.swapETHForExactTokens{value:avaxAmount}(// test ---
        _joe02Router.swapAVAXForExactTokens{value:avaxAmount}(
            fireAmountOut, // accept any amount of FIRE
            path,
            address(this),
            block.timestamp
        );
    }

    function withdraw(address tokenAddress, uint256 amount, address payable to) external onlyMultiSignWallet disablePause {
        uint256 balance;
        if(tokenAddress != address(0)) {
            balance = ERC20(tokenAddress).balanceOf(address(this));
            if(balance < amount) {
                amount = balance;
            }
            ERC20(tokenAddress).transfer(to, amount);
        } else {
            balance = address(this).balance;
            if(balance < amount) {
                amount = balance;
            }
            to.transfer(amount);
        }
    }
}
