import React from "react";
import DashboardPage from "src/components/DashboardPage";

const Dashboard = () => {
  return (
    <>
      <div className="flex justify-center mt-[60px]">
        <div className="flex items-center flex-col gap-4">
          <DashboardPage />
        </div>
      </div>
    </>
  );
};

export default Dashboard;
