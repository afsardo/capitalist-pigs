import React from "react";
import Button from "src/components/Button";
import Select from "src/components/Select";
import Card from "src/components/Card";

const Coop = () => {
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
          <h6>Stake pig</h6>
          <p className="text-white/50">Start earning fees today...</p>
          <div className="mt-auto w-full">
            <Select className="mb-3" />
            <Button
              className="uppercase !bg-orange-700 w-full"
              onClick={() => alert("TODO: STAKE")}
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
            <Select className="mb-3" />
            <Button
              className="uppercase w-full"
              onClick={() => alert("TODO: DELEGATE")}
            >
              Delegate
            </Button>
          </div>
        </Card>
      </div>
    </>
  );
};

export default Coop;
