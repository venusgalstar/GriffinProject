import React from 'react';
import { images } from '../constants';
import { Navbar } from '../components';
import { Footer } from '../container';
import './mynft.css';

export default function Otherpage() {
  return (
    <div>
      <Navbar />
      <div className="myNFTPage" id="mint">
        <div className="myNFTHolder">
          <div className="mynfts">
            <h1>My NFTs</h1>
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
          </div>

        </div>
      </div>
      <Footer />
    </div>
  );
}
