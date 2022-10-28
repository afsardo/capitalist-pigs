import React from "react";
import Link from "next/link";
import { useRouter } from "next/router";

const routes = [
  { href: "/", label: "Home" },
  { href: "/dashboard", label: "Dashboard" },
  { href: "/lab", label: "Laboratory" },
  { href: "/coop", label: "Co-op" },
];

const Navbar = () => {
  const router = useRouter();

  return (
    <ul className="flex justify-center gap-5 py-4 px-4 text-sm">
      {routes.map((route) => (
        <li key={route.href}>
          <Link
            className={`${
              router.pathname === route.href ? "" : "text-gray-500"
            } hover:text-white`}
            href={route.href}
          >
            {route.label}
          </Link>
        </li>
      ))}
    </ul>
  );
};
export default Navbar;
