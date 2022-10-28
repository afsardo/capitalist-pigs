import React from "react";
import Image from "next/image";

import Heading from "src/components/Heading";

const Lab = () => {
  return (
    <div>
      <Heading className="mb-5">Laboratory</Heading>
      <div className="flex gap-2">
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fugit,
          magni! Quae, excepturi. Harum, error culpa? Beatae aliquid ipsum
          recusandae provident minus. Nulla amet aut, earum sapiente
          consequuntur perspiciatis veniam ab.
        </p>
        <Image src="/lab.jpeg" alt="lab" width={400} height={400} />
      </div>
    </div>
  );
};

export default Lab;
