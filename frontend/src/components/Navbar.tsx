import React, { useState } from "react";
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
  const [key, setKey] = useState("");

  return (
    <div className="fixed w-full h-[80px] justify-center items-center flex bg-gray-700">
      <ul className="flex justify-center gap-5 text-xl">
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
      <form className="absolute right-5">
        <input className="mr-3 text-black" value={key} placeholder="private key" onChange={(e) => setKey(e.target.value)} />
        <button className="bg-white text-black px-2 border rounded pointer">✓</button>
      </form>
    </div>
  );
};
export default Navbar;
