import React from "react";
import Image from "next/image";

const Coop = () => {
  return (
    <div className="flex justify-center">
      <div className="flex items-center flex-col gap-4">
        <Image src="/pig_coop.jpeg" alt="co-op" width={600} height={600} />
        <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
          STAKE
        </button>
      </div>
    </div>
  );
};

export default Coop;
