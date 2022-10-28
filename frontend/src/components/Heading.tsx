import React from "react";

const Heading = ({
  children,
  className,
}: {
  children: string;
  className?: string;
}) => {
  return (
    <h3 className={`tracking-wider text-2xl uppercase font-bold ${className}`}>
      <span className="bg-gradient-to-r from-pink-600 to-purple-600 bg-clip-text text-transparent">
        {children}
      </span>
    </h3>
  );
};

export default Heading;
