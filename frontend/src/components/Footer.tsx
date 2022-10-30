import React from "react";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

const Footer = () => {
  const pigCount = useAllOutLifeStore((s) => s.pigCount);
  const piggletCount = useAllOutLifeStore((s) => s.piggletCount);
  const truffleCount = useAllOutLifeStore((s) => s.truffleCount);
  const baconCount = useAllOutLifeStore((s) => s.baconCount);

  return (
    <footer className="fixed bottom-0 w-full h-[60px] items-center flex justify-between px-5 bg-transparent backdrop-blur-sm border-t border-white/10 z-30">
      <div className="text-xs">
        © {new Date().getFullYear()} Powered by Degens, BlazinglyFast
      </div>
      <div className="flex space-x-5">
        <div>{pigCount} 🐖</div>
        <div>{piggletCount} 🐷</div>
        <div>{truffleCount} 🌰</div>
        <div>{baconCount} 🥓</div>
      </div>
    </footer>
  );
};
export default Footer;
