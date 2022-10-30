import React from "react";

type Props = {
  children: string;
  disabled?: boolean;
  className?: string;
  onClick: () => void;
};

const Button = ({ children, disabled, className, onClick }: Props) => {
  return (
    <button
      disabled={disabled}
      className={`p-4 font-semibold tracking-wider rounded-lg bg-purple-700 ${className}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
