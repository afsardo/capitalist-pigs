import React from "react";
import Image from "next/image";

import Button from "src/components/Button";
import Select from "src/components/Select";

const Coop = () => {
  return (
    <>
      <div className="flex flex-col md:flex-row justify-center gap-4">
        {/* <div className="flex items-center flex-col gap-4">
        <Image src="/pig_coop.jpeg" alt="co-op" width={600} height={600} />
        <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
          STAKE
        </button>
      </div> */}
        <div className="flex flex-col w-full rounded-lg bg-gray-700 p-4 gap-4">
          <h6>Stake pig</h6>
          <Select />
          <Button
            className="uppercase p-4 !bg-orange-700"
            onClick={() => alert("TODO: STAKE")}
          >
            Stake
          </Button>
        </div>
        <div className="flex flex-col w-full rounded-lg bg-gray-700 p-4 gap-4">
          <h6>Delegate piglet</h6>
          <Select />
          <Button
            className="uppercase p-4"
            onClick={() => alert("TODO: DELEGATE")}
          >
            Delegate
          </Button>
        </div>
      </div>
    </>
  );
};

export default Coop;
