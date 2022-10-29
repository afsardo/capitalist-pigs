import React from "react";
import Button from "src/components/Button";

const Lab = () => {
  return (
    <>
      <div className="flex flex-col md:flex-row justify-center gap-4 mt-[60px]">
        {/* <div className="flex items-center flex-col gap-4">
        <Image src="/pig_coop.jpeg" alt="co-op" width={600} height={600} />
        <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
          STAKE
        </button>
      </div> */}
        <div className="flex flex-col w-full rounded-lg bg-gray-700 p-4 gap-4">
          <h6>Truffles</h6>
          <p className="text-white/50">
            Merchant is interested in swaping a smart pig for some tasteful
            truffles
          </p>
          <Button
            className="uppercase p-4 mt-auto"
            onClick={() => alert("TODO: STAKE")}
          >
            Swap
          </Button>
        </div>
        <div className="flex flex-col w-full rounded-lg bg-gray-700 p-4 gap-4">
          <h6>Piglets</h6>
          <p className="text-white/50">
            Mutate your piglets into a fat wealthy pig
          </p>
          <Button
            className="uppercase p-4 !bg-orange-700 mt-auto"
            onClick={() => alert("TODO: DELEGATE")}
          >
            Mutate
          </Button>
        </div>
      </div>
    </>
  );
};

export default Lab;
