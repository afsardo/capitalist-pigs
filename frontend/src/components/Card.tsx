import React from "react";

const Card = ({ children, className }: any) => {
  return (
    <div
      className={`bg-gray-700 p-4 rounded-lg hover:-translate-y-1 duration-300 ${className}`}
    >
      {children}
    </div>
  );
};

export default Card;
