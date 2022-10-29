import React from "react";

const Footer = () => {
  const assets = {
    pigs: 0,
    piglets: 0,
    truffles: 0,
    bacon: 0,
  };

  return (
    <footer className="fixed bottom-0 w-full h-[40px] items-center flex justify-between px-5 bg-gray-800">
      <div className="text-xs">© 2022 Powered by Degens, BlazinglyFast</div>
      <div className="flex space-x-5">
        <div>{assets.pigs} 🐖</div>
        <div>{assets.piglets} 🐷</div>
        <div>{assets.truffles} 🌰</div>
        <div>{assets.bacon} 🥓</div>
      </div>
    </footer>
  );
};
export default Footer;
