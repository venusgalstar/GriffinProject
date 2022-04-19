import React from 'react';
import { images } from '../constants';
import { Navbar } from '../components';
import { Footer } from '../container';
import './mint.css';

export default function Otherpage() {
  return (
    <div>
      <Navbar />
      <div className="mintPage" id="mint">
        <div className="mintHolder">
          <div className="minting">
            <h1>Mint Is Live</h1>
            <span className="mintCounter">707 / 10000</span>
            <p className="mintCost">1 Griffin Costs <span>2 AVAX</span></p>
            <p className="mintMax">Max. 20 Mints Per Transaction</p>

            <div className="mintSelect">
              <button type="button" className="selectSize">-</button>
              <p className="mintAmount"><span>1</span> Griffin</p>
              <button type="button" className="selectSize">+</button>
            </div>

            <button type="button" className="custom__button mintNow onMint">Mint Now</button>
          </div>

          <div className="griffinCreature">
            <img src={images.griffinGolden} alt="Golden Griffin" />
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}
