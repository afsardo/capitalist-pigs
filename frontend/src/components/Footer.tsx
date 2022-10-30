import React from "react";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

const Footer = () => {
  const privateKey = useAllOutLifeStore((s) => s.privateKey);
  const stakedPigs = useAllOutLifeStore((s) => s.stakedPigs);
  const delegatedPigglets = useAllOutLifeStore((s) => s.delegatedPigglets);
  const pigCount = useAllOutLifeStore((s) => s.pigCount);
  const piggletCount = useAllOutLifeStore((s) => s.piggletCount);
  const truffleCount = useAllOutLifeStore((s) => s.truffleCount);
  const baconCount = useAllOutLifeStore((s) => s.baconCount);

  return (
    <footer className="fixed bottom-0 w-full h-[120px] items-center flex justify-between px-5 bg-transparent backdrop-blur-sm border-t border-white/10 z-30">
      <div className="text-xs">
        © {new Date().getFullYear()} Powered by Degens, BlazinglyFast
      </div>
      <div className="flex space-x-5 text-lg">
        {privateKey ? (
          <>
            <div>
              {pigCount - stakedPigs.length} / {pigCount} 🐖
            </div>
            <div>
              {piggletCount - delegatedPigglets.length} / {piggletCount} 🐷
            </div>
            <div>{truffleCount.toFixed(2)} 🌰</div>
            <div>{baconCount.toFixed(2)} 🥓</div>
          </>
        ) : null}
      </div>
    </footer>
  );
};
export default Footer;
