import React from "react";

type Props = {
  children: string;
  className?: string;
  onClick: () => void;
};

const Button = ({ children, className, onClick }: Props) => {
  return (
    <button
      className={`p-4 font-semibold tracking-wider rounded-lg bg-purple-700 ${className}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
