/* eslint-disable react/jsx-indent */
import React from 'react';
import { images } from '../../constants';

import './Winners.css';

const Winners = () => (
  <div className="winners" id="winners">
    <div className="griffinCrown">
        <img src={images.griffinCrown} alt="Griffin Crown" />
    </div>
    <h2 className="sectionTitle">Winners</h2>
    <div className="winnersContainer">
    <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
      <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
      <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
      <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
      <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
      <div className="winnerHolder"><div className="imageWinner"><img src={images.griffinSample} alt="Griffin NFT" /></div><div className="winInfo"><span className="winnerNum">#4008</span><span className="winDraw">Draw: 1</span><span className="winDate">Draw date: 02/12/2022</span><span className="winHash">Wallet: aB89...93aE</span></div></div>
    </div>
    <div className="winnersSelect">
        <button type="button" className="custom__button mintNow">View All Winners</button>
    </div>

    <div className="nextLottery"><span>Next Air Drop: 07h 23m</span></div>

  </div>
);

export default Winners;
