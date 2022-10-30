import React from "react";

import Button from "src/components/Button";
import Card from "src/components/Card";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";


const Lab = () => {
  const actions = useAllOutLifeStore((s) => s.actions);
  const piggletCount = useAllOutLifeStore((s) => s.piggletCount);
  const trufflesCount = useAllOutLifeStore((s) => s.truffleCount);
  return (
    <>
      <div className="flex flex-col md:flex-row justify-center gap-4 mt-[60px]">
        {/* <div className="flex items-center flex-col gap-4">
        <Image src="/pig_coop.jpeg" alt="co-op" width={600} height={600} />
        <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
          STAKE
        </button>
      </div> */}
        <Card className="flex flex-col w-full gap-4">
          <h6>Truffles</h6>
          <p className="text-white/50">
            Merchant is interested in swaping some tasteful
            truffles for piglets
          </p>
          <Button
            className="uppercase p-4 mt-auto"
            onClick={() => trufflesCount >= 10 ? actions.trufflesIntoPiglet() : null}
          >
            Get me some Piglets!
          </Button>
        </Card>
        <Card className="flex flex-col w-full gap-4">
          <h6>Piglets</h6>
          <p className="text-white/50">
            Mutate your piglets into a fat wealthy pig
          </p>
          <Button
            className="uppercase p-4 !bg-orange-700 mt-auto"
            onClick={() => piggletCount >= 5 ? actions.pigletsIntoPig() : null}
          >
            Transform 5 Piglets into 1 Pig
          </Button>
        </Card>
      </div>
    </>
  );
};

export default Lab;
