import React from "react";
import Link from "next/link";

const Navbar = () => {
  return (
    <ul className="flex justify-center gap-5 py-4 px-4">
      <li>
        <Link className="hover:text-yellow-200" href="dashboard">
          Dashboard
        </Link>
      </li>
      <li>
        <Link className="hover:text-yellow-200" href="lab">
          Laboratory
        </Link>
      </li>
      <li>
        <Link className="hover:text-yellow-200" href="coop">
          Co-op
        </Link>
      </li>
    </ul>
  );
};
export default Navbar;
