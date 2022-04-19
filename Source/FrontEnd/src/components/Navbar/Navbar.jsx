import React from 'react';
import { GiHamburgerMenu } from 'react-icons/gi';
import { Link } from 'react-router-dom';
import images from '../../constants/images';
import './Navbar.css';

/**
  * page changes router
  * Add Link tag from react router dom
  * and pass "to" to page which you want to go
  */

const Navbar = () => {
  const [toggleMenu, setToggleMenu] = React.useState(false);
  return (
    <nav className="app__navbar">
      <div className="app__navbar-logo">
        <a href="/"><img src={images.griffinTopLogo} alt="Griffin Kingdom Logo" /></a>
      </div>
      <ul className="app__navbar-links">
        <Link to="/mint"><li className="p__opensans">Mint</li></Link>
        <li className="p__opensans"><a href="/#tiers">Tiers</a></li>
        <li className="p__opensans"><a href="/#winners">Winners</a></li>
        <li className="p__opensans"><a href="/mynft">My NFT</a></li>
        <li className="p__opensans"><a href="/#faq">FAQ</a></li>
      </ul>
      <div className="app__navbar-login">
        <a className="socialHead" href="http://discord.com" target="_blank" rel="noreferrer"><i className="fab fa-discord" aria-label="Discord" /></a>
        <a className="socialHead" href="http://twitter.com" target="_blank" rel="noreferrer"><i className="fab fa-twitter" aria-label="Twitter" /></a>
        <a className="socialHead" href="https://medium.com/@Griffin_Kingdom" target="_blank" rel="noreferrer"><i className="fab fa-medium" aria-label="Medium" /></a>
        <span className="headPrice">$FIRE  700</span>
        <span className="headPrice">AVAX  97</span>
        <button type="button" className="connectWallet">CONNECT WALLET</button>
      </div>
      <div className="app__navbar-smallscreen">
        <GiHamburgerMenu color="#fff" fontSize={27} onClick={() => setToggleMenu(true)} />
        {toggleMenu && (
          <div className="app__navbar-smallscreen_overlay flex__center slide-bottom">
            <button className="overlay__close" onClick={() => setToggleMenu(false)} type="button">X</button>
            <ul className="app__navbar-smallscreen_links">
              <li><a href="/" onClick={() => setToggleMenu(false)}>Home</a></li>
              <li><a href="/mint" onClick={() => setToggleMenu(false)}>Mint</a></li>
              <li><a href="/#tiers" onClick={() => setToggleMenu(false)}>Tiers</a></li>
              <li><a href="/#winners" onClick={() => setToggleMenu(false)}>Winners</a></li>
              <li><a href="/mynft" onClick={() => setToggleMenu(false)}>My NFT</a></li>
              <li><a href="/#faq" onClick={() => setToggleMenu(false)}>FAQ</a></li>
              <li><a href="http://discord.com" onClick={() => setToggleMenu(false)}><i className="fab fa-discord" aria-label="Discord" /></a></li>
              <li><a href="http://twitter.com" onClick={() => setToggleMenu(false)}><i className="fab fa-twitter" aria-label="Twitter" /></a></li>
              <li><a href="https://medium.com/@Griffin_Kingdom" onClick={() => setToggleMenu(false)}><i className="fab fa-medium" aria-label="Medium" /></a></li>
            </ul>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;
