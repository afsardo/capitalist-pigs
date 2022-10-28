import React from "react";
import Image from "next/image";

const Dashboard = () => {
  return (
    <div>
      <h3 className="text-purple-700 tracking-wider text-2xl uppercase">
        Dashboard
      </h3>
      <Image src="/pig.jpeg" alt="pig" width={400} height={400} />
    </div>
  );
};

export default Dashboard;
