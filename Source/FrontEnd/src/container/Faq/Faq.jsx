/* eslint-disable react/jsx-closing-tag-location */
/* eslint-disable react/jsx-indent */
import React from 'react';

import './Faq.css';

const Faq = () => (
  <div className="faq" id="faq">
    <h2 className="sectionTitle">FAQ</h2>
    {/* GENERAL */}
    <h3 className="faqSubhead">General</h3>
    <div className="faqHolder">
      {/* <details open> */}
      <details>
        <summary>What is Griffin Kingdom?</summary>
        <div className="faq__content">
          <p>The Griffin Kingdom is an exciting new opportunity for investors to diversify their crypto investment profile. Holding one of our NFTs allows you to participate in our weekly AirDrops, where you will receive a Phoenix Nest. Our vision is to create a Kingdom that will enable every holder to win life-changing giveaways!</p>
        </div>
      </details>
      <details>
        <summary>What is the $FIRE token?</summary>
        <div className="faq__content">
          <p>$FIRE is a token that is designed to generate high-yield rewards by combining investment capital into DeFi yield protocols, decentralized reserve currency, and other high-yield, large scale investments that are generally unsuitable for individual investors.</p>
        </div>
      </details>
      <details>
        <summary>What is a Phoenix Nest?</summary>
        <div className="faq__content">
          <p>A Nest is a term used to describe an initial deposit holding. When you create a Nest, you are depositing funds to the treasury to be used for the project&apos;s investments.</p>
        </div>
      </details>
      <details>
        <summary>Why is $FIRE on the Avalanche Chain?</summary>
        <div className="faq__content">
          <p>Our goal is to bring DeFi into the average household. Ethereum&apos;s high gas fees make it impossible for most people to access the Ethereum network. bWe want $FIRE to be accessible to everyone, including smallholders, so we chose to be on the Avalanche Chain. However, this does not prevent us from taking advantage of DeFi yield protocols on Ethereum.</p>
        </div>
      </details>
      <details>
        <summary>What are the benefits of owning a Griffin Kingdom NFT?</summary>
        <div className="faq__content">
          <p>The benefit of owning a Griffin Kingdom NFT is that you will have eligibility to participate in our weekly Nest AirDrop and have whitelist placement for any future Griffin Kingdom Products and Services.</p>
        </div>
      </details>
      <details>
        <summary>Is Griffin Kingdom affiliated with Phoenix Community Capital (PCC)?</summary>
        <div className="faq__content">
          <p>Yes! PCC and Griffin Kingdom are partnered together on this project to provide an outstanding NFT and giveaway system. PCC is the manager of the Griffin Kingdom treasury. </p>
        </div>
      </details>
    </div>

{/* MINTING */}
<h3 className="faqSubhead">Minting</h3>
    <div className="faqHolder">
      <details>
        <summary>What is the breakdown of the mint profits?</summary>
        <div className="faq__content">
          <p>100% of the profits go towards creating Phoenix Nests and Phoenix NFTs (Master NFT and Grandmaster NFT).<br />
            The distribution of Nest rewards is as follows,<br />
            50% of rewards go to winners.<br />
            25% of rewards go to compounding.<br />
            25% of rewards go-to team wallet (used to pay staff and developers).<br />
          </p>
        </div>
      </details>
      <details>
        <summary>How do I mint an NFT?</summary>
        <div className="faq__content">
          <p>You can mint an NFT by connecting to the Griffin Kingdom site using your wallet, such as Metamask. Ensure you are on the Avalanche Network and from there, click Mint and the number of NFTs you would like to mint.</p>
        </div>
      </details>
      <details>
        <summary>Which NFT will I get?</summary>
        <div className="faq__content">
          <p>You will receive an NFT at random.</p>
        </div>
      </details>
      <details>
        <summary>Why does Minting cost increase per tier?</summary>
        <div className="faq__content">
          <p>The pricing structure was designed to give early adopters an initial discount. The prices are set to ensure we can Air Drop more rewards as each tier progresses. This is for the benefit of the holders of Griffin Kingdom NFTs.</p>
        </div>
      </details>
      <details>
        <summary>What changes with each tier?</summary>
        <div className="faq__content">
          <p>When a tier changes, the price of the NFTs increases. There are no other changes, and we will still be giving away 50% of the rewards from Nests. <br />
          Whitelist cost (Tier 1) - 2 AVA<br />
          Tier 2 - 3 AVAX<br />
          Tier 3 - 3.5 AVAX<br />
          Tier 4 - 4 AVAX<br />
          Tier 5 - 4.5 AVAX
          </p>
        </div>
      </details>
    </div>

{/* AIR DROPS */}
<h3 className="faqSubhead">Air Drops</h3>
    <div className="faqHolder">
      <details>
        <summary>How will the Air Drops work?</summary>
        <div className="faq__content">
          <p>PCC will AirDrop Nests directly into wallets. e.g., like that have done with the 5000 Nests they AirDropped on April 1<sup>st</sup>.</p>
        </div>
      </details>
      <details>
        <summary>What are the weekly Air Drops?</summary>
        <div className="faq__content">
          <p>Each week we will Air Drop each winner a Phoenix Nest.</p>
        </div>
      </details>
      <details>
        <summary>My NFT won; how do I claim the reward?</summary>
        <div className="faq__content">
          <p>The Air Drops will be manually distributed to the wallets of the winners, and you will not need to do anything to obtain your Nest. You may view our Winners on the website, Twitter, or Discord if you wish.</p>
        </div>
      </details>
      <details>
        <summary>I won, but I did not receive my AirDrop. What do I do?</summary>
        <div className="faq__content">
          <p>If you won and did not receive an AirDrop, please reach out to <a href="mailto:support@griffinkingdom.finance">support@griffinkingdom.finance</a>. Please send us the wallet address that contains the NFT that won. </p>
        </div>
      </details>
      <details>
        <summary>If I win an Air Drop, will I still be entered into future Air Drops?</summary>
        <div className="faq__content">
          <p>Yes! Holding a Griffin Kingdom NFT allows you to participate in our Air Drops if you pay your maintenance fees to keep Air Drops status Active.</p>
        </div>
      </details>
      <details>
        <summary>Where will winners be listed?</summary>
        <div className="faq__content">
          <p>The winners will be listed on our Twitter, Discord, and website.</p>
        </div>
      </details>
      <details>
        <summary>What are the NFT maintenance fees?</summary>
        <div className="faq__content">
            <p>You must pay the NFT maintenance fees to maintain active status in the Air Drops. If the maintenance fee goes to zero days, you will no longer be able to participate in the Air Drops until you pay the fee. You do not need to pay the maintenance fee to maintain ownership of your NFT.</p>
        </div>
        </details>
        <details>
        <summary>What is the purpose of the NFT maintenance fees?</summary>
        <div className="faq__content">
            <p>Griffin Kingdom NFT maintenance fees are used for Phoenix Nest maintenance and claiming fees. These fees are required for sustainability and to continue Air Drops past 100% of NFTs sold.</p>
        </div>
        </details>
        <details>
        <summary>How do I pay my maintenance fee?</summary>
        <div className="faq__content">
            <p>You can manage your NFT maintenance fees on the View My NFT page. You can pay the fee in 30, 60, and 90 days increments.</p>
        </div>
        </details>
        <details>
        <summary>Does one faction have more of a chance to win over another?</summary>
        <div className="faq__content">
            <p>No, every Griffin Kingdom NFT has an equal opportunity to win an AirDrop regardless of their faction. Factions are created equally and do not affect win rates. Factions are only for entertainment purposes to keep NFT holders engaged.</p>
        </div>
        </details>
    </div>
  </div>
);

export default Faq;
