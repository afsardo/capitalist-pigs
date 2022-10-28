import React from "react";
import Image from "next/image";

const Lab = () => {
  return (
    <div>
      <h3 className="text-purple-700 tracking-wider text-2xl uppercase">
        Laboratory
      </h3>
      <Image src="/lab.jpeg" alt="lab" />
    </div>
  );
};

export default Lab;
