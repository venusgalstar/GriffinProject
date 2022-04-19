// var mysql = require("mysql");
var mysql = require('sync-mysql');
var express = require("express");
var config = require('./config.json');
var Web3 = require("web3");
var lotteryAbi = require("./contract/LotteryAbi.json");
var rewardAbi = require("./contract/RewardManagement.json");
var moment = require("moment");
var express = require('express');
var cors = require('cors');
const bodyparser = require('body-parser');

// init web3
var web3 = new Web3(new Web3.providers.HttpProvider(config.RPC_URL2));
var signer = web3.eth.accounts.privateKeyToAccount(config.PRIVATE_KEY);
var LotteryContract = new web3.eth.Contract(lotteryAbi, config.LOTTERY_ADDRESS);
var RewardContract = new web3.eth.Contract(rewardAbi, config.REWARD_ADDRESS);

var DB = new mysql({
    host: config.HOST,
    user: config.USER,
    password: config.PASSWORD,
    database: config.DATABASE
});

var txHash = null;

const sleep = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const sendTx = async (account, tx, gasPrice, value) => {
    var gas = 2100000;
    const data = tx.encodeABI();
    var nonce = await web3.eth.getTransactionCount(account.address);
    nonce = web3.utils.toHex(nonce + 1);
    var gasFee = await tx.estimateGas({ from: account.address, value: value });
    console.log("gas fee:", gasFee);

    const option = {
        from: account.address,
        to: tx._parent._address,
        data: data,
        gas: gasFee * 5,
        // gas: gas,
        // nonce: nonce,
        gasPrice: web3.utils.toHex(gasPrice),
        // chain: await web3.eth.getChainId(),
        // hardfork: 'berlin',
        value
    };

    if (!txHash) {
        const signedTx = await web3.eth.accounts.signTransaction(option, account.privateKey);
        await web3.eth.sendSignedTransaction(signedTx.rawTransaction)
            .on('transactionHash', function (hash) {
                console.log("transaction hash:", hash);
                txHash = hash;
            })
            .on('confirmation', function (confirmationNumber, receipt) {
                txHash = null;
                // console.log("confirm transaction: ", confirmationNumber);
                return true;
            })
            .on('receipt', function (receipt) {
                txHash = null;
                console.log("reciept: ", receipt);
            })
            .on('error', function (error, receipt) {
                txHash = null;
                console.log("send transaction error:", error);
                return false;
            });
    } else {
        console.log("another transaction is running!");
    }
    return true;
}

const getNextLotteryTime = () => {

    var ret1 = DB.query("SELECT DATE_ADD(`date`, INTERVAL 7 DAY) AS next_date FROM winners ORDER BY lottery_count DESC");
    if (ret1.length > 0) {
        return ret1[0].next_date;
    } else if (ret1.length == 0) {
        var ret2 = DB.query("SELECT first_start FROM first_start");
        if (ret2.length == 0) {
            return null;
        } else {
            ret2[0].first_start;
        }
    }
}


const syncWalletAndClaim = async () => {
    try {
        var result = DB.query("SELECT IFNULL(MAX(wallet_index), -1) AS cnt FROM claim_history");
        var maxIndex = result[0].cnt;
        var count = await LotteryContract.methods.getWalletCount().call();
        if (count - 1 > maxIndex) {
            var start = maxIndex + 1;
            for (var i = start; i < count; i++) {
                var address = await LotteryContract.methods.getWallet(i).call();
                var date = moment().format("YYYY-MM-DD H:mm:ss");
                var queryStr = `INSERT INTO claim_history(wallet_index, address, claim_time) VALUES (${i}, "${address}", "${date}")`;
                DB.query(queryStr);
            }
        }
        await claimWallet();
    } catch (e) {
        console.log("sync wallet error:", e);
    } finally {
        setTimeout(syncWalletAndClaim, 10000);
    }
}

const claimWallet = async (force = false) => {

    try {

        var ret = DB.query("SELECT * FROM claim_history WHERE DATE_ADD(`claim_time`, INTERVAL ? DAY) < CURRENT_TIMESTAMP",
            [config.CLAIM_PERIOD_DAY]);

        var next_lottery_time = getNextLotteryTime();
        next_lottery_time = next_lottery_time == null ? moment("2030-01-01 00:00:00") : moment(next_lottery_time);
        var current_time = moment();

        var diff = next_lottery_time.diff(current_time, 'hours');
        if (diff > 24 || force) {
            for (var i = 0; i < ret.length; i++) {
                var address = ret[i].address;
                var reward = await RewardContract.methods.getRewardAmount(address).call();

                var nodeRewards = [];
                for (var index in reward.nodeRewards) {
                    nodeRewards.push(Number(web3.utils.fromWei(reward.nodeRewards[index])) * 1);
                }

                var cnt = 0, sum = 0;
                for (var j in nodeRewards) {
                    sum += nodeRewards[j];
                    if (sum < 100) {
                        cnt++;
                    } else {
                        break;
                    }
                }
                var fee = await RewardContract.methods.getClaimFee().call();
                var tx = LotteryContract.methods.claimWallet(ret[i].wallet_index);
                await sendTx(signer, tx, 30000000000, fee * cnt);

                DB.query(`UPDATE claim_history SET claim_time = CURRENT_TIMESTAMP WHERE id = ${ret[i].id}`);
                sleep(50000);
            }
        }
    } catch (e) {
        console.log("claim error: ", e)
    }
}

const checkLotteryTime = () => {
    var result = DB.query("SELECT * FROM (SELECT MAX(date) AS max_date FROM winners) A WHERE DATE_ADD(A.max_date, INTERVAL ? DAY) < CURRENT_TIMESTAMP", [config.LOTTERY_PERIOD_DAY]);
    var first_start = DB.query("SELECT * FROM first_start WHERE first_start < CURRENT_TIMESTAMP");
    var lottery_history = DB.query("SELECT * FROM winners");

    if (first_start.length > 0 && lottery_history.length == 0) {
        return true;
    } else if (result.length > 0) {
        return true;
    } else {
        return false;
    }
}

const startLottery = async () => {
    await syncNftStatus();
    var result = DB.query("SELECT * FROM nfts WHERE remainCount > 0 ORDER BY RAND()");
    if (result.length > 0) {
        var totalList = [];
        var winners = [];
        for (var i = 0; i < result.length; i++) {
            totalList.push(result[i].id);
        }
        for (var i = 0; i < Math.min(config.CANDIDATE_NUM, result.length); i++) {
            winners.push(result[i].id);
        }
        var winners = winners.toString();
        var totalList = totalList.toString();
        var date = moment().format("YYYY-MM-DD H:mm:ss");

        var result = DB.query("SELECT IFNULL(MAX(lottery_count), 0) AS cnt FROM winners");
        var cnt = result[0].cnt;

        var lottery_count = Number(cnt) + 1;
        var query = `INSERT INTO winners(winner_ids, attend_ids, lottery_count,  date) VALUES("${winners}", "${totalList}",${lottery_count}, "${date}")`;
        DB.query(query);

    } else {
        console.log("not pay lottery fee!");
    }
}

const syncNftStatus = async () => {
    var nftcount = await LotteryContract.methods._totalNFT().call();
    var interval = config.SCAN_NFT_INTERVAL;
    console.log("sync nft status");
    for (var i = 0; i < nftcount; i += interval) {
        var list = await LotteryContract.methods.getCandidates(i, interval).call();
        for (var j = 0; j < list.length; j++) {
            var result = DB.query("SELECT * FROM nfts WHERE token_id = ?", [list[j].tokenId]);
            var query = "";
            if (result.length > 0) {
                var address = list[j].user.toString();
                query = `UPDATE nfts SET address = "${address}", remainCount = ${list[j].remainCount} WHERE id = ${result[0].id}`;
            } else {
                var address = list[j].user.toString();
                query = `INSERT INTO nfts(address, token_id, remainCount) VALUES ("${address}", ${list[j].tokenId}, ${list[j].remainCount})`;
            }
            DB.query(query);
        }
    }
    if (nftcount >= config.START_NFT_COUNT) {
        var result = DB.query("SELECT * FROM first_start");
        if (result.length == 0) {
            var current_date = new Date();
            var day = current_date.getUTCDay();
            var cDate = moment().format("YYYY-MM-DD 00:00:00");
            var sDate = moment(cDate).add(6 - day + 5, 'days').format("YYYY-MM-DD HH:mm:ss");
            console.log("Set first lottery time");
            DB.query("INSERT INTO first_start(first_start) VALUES(?)", [sDate]);
        }
    } else {
        DB.query("DELETE FROM first_start");
    }
    setTimeout(syncNftStatus, 10000);
}

const syncLotteryCount = async () => {
    try {
        var lotteryCount = await LotteryContract.methods._lotteryCount().call();
        var result = DB.query("SELECT IFNULL(MAX(lottery_count), 0) AS cnt FROM winners");
        var cnt = result[0].cnt;
        console.log("current lottery count:", lotteryCount);
        if (cnt > lotteryCount) {
            console.log("sync lottery count");
            await claimWallet(true);
            console.log("claim successed before starting lottery");
            var tx = LotteryContract.methods.startLottery();
            await tx.estimateGas({ from: signer.address });
            await sendTx(signer, tx, 30000000000, 0);
        }
    } catch (e) {
        console.log("sync lottery count error!");
        console.log(e);
    } finally {
        setTimeout(syncLotteryCount, 30000);
    }
}



const run = async () => {
    if (checkLotteryTime()) {
        console.log('-------------------start lottery-----------------');
        startLottery();
    } else {
        // console.log("no time to start lottery");
    }
    setTimeout(run, 5000);
}

syncLotteryCount();
syncWalletAndClaim();
syncNftStatus();
run();



var app = express();
app.use(cors({ origin: "*" }));

app.post('/start_first_lottery', async (req, res) => {
    if (await startFirstLottery()) {
        res.send({ code: 0 });
    } else {
        res.send({ code: 1 });
    }
});

app.post('/get_lottery_winners', (req, res) => {
    var result = DB.query("SELECT * FROM winners");
    res.send({ code: 0, list: result });
});

app.post('/start_lottery', async (req, res) => {
    await startLottery();
    res.send({code: 0});
});

app.listen(process.env.PORT || config.SERVER_PORT, () => console.log(`Listening on port ${config.SERVER_PORT}...`));

