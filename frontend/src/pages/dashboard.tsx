import React from "react";
import Image from "next/image";

const Dashboard = () => {
  return (
    <div className="flex justify-center">
      <div className="flex items-center flex-col gap-4">
        <Image src="/pig_dashboard.jpeg" alt="dashboard" width={600} height={600} />
        <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
          SELL
        </button>
      </div>
    </div>
  );
};

export default Dashboard;
