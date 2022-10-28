import React from "react";
import Image from "next/image";

import Heading from "src/components/Heading";

const Dashboard = () => {
  return (
    <div>
      <Heading className="mb-5">Dashboard</Heading>

      <div className="flex gap-4">
        <Image src="/pig.jpeg" alt="lab" width={300} height={300} />
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fugit,
          magni! Quae, excepturi. Harum, error culpa? Beatae aliquid ipsum
          recusandae provident minus. Nulla amet aut, earum sapiente
          consequuntur perspiciatis veniam ab.
        </p>
      </div>
    </div>
  );
};

export default Dashboard;
