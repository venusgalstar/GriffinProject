import React from 'react';

import { images } from '../../constants';
import './Header.css';

const Header = () => (
  <div className="app__header app__wrapper section__padding" id="home">
    <div className="app__wrapper_info">
      <h1 className="app__header-h1"><img src={images.griffinLogo} alt="Griffin Kingdom" /></h1>
      <p className="headerSubheading" style={{ margin: '2rem 0' }}>PHOENIX FUTURES PRESENTS</p>
      <a href="/#about" type="button" className="custom__button arrowDown bounce"><i className="fa fa-arrow-down" aria-label="Arrow Down" /></a>
    </div>

  </div>
);

export default Header;
