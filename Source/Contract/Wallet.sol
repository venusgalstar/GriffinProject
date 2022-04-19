// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../RewardManagement.sol";

contract Wallet is Ownable{
    using SafeMath for uint256;

    event Received(address sender, uint256 value);
    event Fallback(address sender, uint256 value);

    uint256 totalNest;
    address _parent;
    IERC20 _fireToken;
    RewardManagement _rewardMgnt;

    constructor(address parent, address rewardMgmt, address fire) {
        _parent = parent;
        _rewardMgnt = RewardManagement(payable(rewardMgmt));
        _fireToken = IERC20(fire);
        _fireToken.approve(parent, 10000 * 10**18);
    }

    function buyNode(uint256 count) external payable{
        totalNest += count;
        _fireToken.approve(address(_rewardMgnt), _fireToken.balanceOf(address(this)));
        _rewardMgnt.buyNode{value:address(this).balance}(count);
    }

    function claimAll() external payable returns(uint256){
        _rewardMgnt.claimAll{value:msg.value}();
        uint256 rewardAmount = _fireToken.balanceOf(address(this));
        _fireToken.transfer(_parent, rewardAmount);
        return rewardAmount;
    }

    function payAllNodeFee(RewardManagement.MODE_FEE mode) external payable{
        _rewardMgnt.payAllNodeFee{value:msg.value}(mode);
    }

    function getNestCount() external view returns(uint256) {
        return totalNest;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable { 
        emit Fallback(msg.sender, msg.value);
    }

    function withdraw(address tokenAddress, uint256 amount, address payable to) external {
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