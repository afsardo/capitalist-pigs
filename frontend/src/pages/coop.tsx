import React, { useState } from "react";
import Button from "src/components/Button";
import Select from "src/components/Select";
import Card from "src/components/Card";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

const Coop = () => {
  const [selectedPig, setSelectedPig] = useState<number | null>(null);
  const [selectedPigglet, setSelectedPigglet] = useState<number | null>(null);
  const pigCount = useAllOutLifeStore((s) => s.pigCount);
  const stakedPigs = useAllOutLifeStore((s) => s.stakedPigs);
  const piggletCount = useAllOutLifeStore((s) => s.piggletCount);
  const delegatedPigglets = useAllOutLifeStore((s) => s.delegatedPigglets);
  const actions = useAllOutLifeStore((s) => s.actions);

  const onStake = () => {
    if (selectedPig != null) {
      actions.stakePig(selectedPig);
      setSelectedPig(null);
    }
  };

  const onDelegate = () => {
    if (selectedPigglet != null) {
      actions.delegatePigglet(selectedPigglet);
      setSelectedPigglet(null);
    }
  };

  return (
    <>
      <div className="flex flex-col md:flex-row justify-center gap-4 mt-[60px]">
        <Card className="flex flex-col w-full gap-4">
          <h6>Stake pig</h6>
          <p className="text-white/50">Start earning fees today...</p>
          <div className="mt-auto w-full">
            <Select
              count={pigCount}
              selectedValues={stakedPigs}
              placeholder="Select a pig"
              className="mb-3"
              value={selectedPig}
              onChange={(value) => setSelectedPig(value)}
            />
            <Button
              className="uppercase !bg-orange-700 w-full"
              onClick={onStake}
            >
              Stake
            </Button>
          </div>
        </Card>
        <Card className="flex flex-col w-full gap-4">
          <h6>Delegate piglet</h6>
          <p className="text-white/50">
            Delegate your piglet to an already staked pig and earn a % of the
            accrued fees
          </p>
          <div className="mt-auto w-full">
            <Select
              count={piggletCount}
              selectedValues={delegatedPigglets}
              placeholder="Select a pigglet"
              className="mb-3"
              value={selectedPigglet}
              onChange={(value) => setSelectedPigglet(value)}
            />
            <Button className="uppercase w-full" onClick={onDelegate}>
              Delegate
            </Button>
          </div>
        </Card>
      </div>
    </>
  );
};

export default Coop;
