import React from "react";
import Link from "next/link";
import { useRouter } from "next/router";

import { BanknotesIcon, BeakerIcon, ChartBarIcon, HomeModernIcon } from '@heroicons/react/24/solid'

const routes = [
  { href: "/", label: "Home", icon: <BanknotesIcon className="h-6 w-6" /> },
  { href: "/dashboard", label: "Dashboard", icon: <ChartBarIcon className="h-6 w-6" /> },
  { href: "/lab", label: "Laboratory", icon: <BeakerIcon className="h-6 w-6" /> },
  { href: "/coop", label: "Co-op", icon: <HomeModernIcon className="h-6 w-6" /> },
];

const Navbar = () => {
  const router = useRouter();

  return (
    <ul className="flex justify-center gap-5 py-12 px-4 text-xl">
      {routes.map((route) => (
        <li key={route.href}>
          <Link
            className={`flex items-center ${
              router.pathname === route.href ? "" : "text-gray-500"
            } hover:text-white`}
            href={route.href}
          > 
            {route.icon}
            <div className="ml-2">{route.label}</div>
          </Link>
        </li>
      ))}
    </ul>
  );
};
export default Navbar;
