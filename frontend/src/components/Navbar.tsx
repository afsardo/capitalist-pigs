import React, { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/router";
import useLocalStorage from "hooks/useLocalStorage";
import { Disclosure } from "@headlessui/react";

import {
  BanknotesIcon,
  BeakerIcon,
  ChartBarIcon,
  HomeModernIcon,
} from "@heroicons/react/24/solid";
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";

const routes = [
  { href: "/", label: "Home", icon: <BanknotesIcon className="h-6 w-6" /> },
  {
    href: "/dashboard",
    label: "Dashboard",
    icon: <ChartBarIcon className="h-6 w-6" />,
  },
  {
    href: "/lab",
    label: "Laboratory",
    icon: <BeakerIcon className="h-6 w-6" />,
  },
  {
    href: "/coop",
    label: "Co-op",
    icon: <HomeModernIcon className="h-6 w-6" />,
  },
];

export default function Navbar() {
  const router = useRouter();
  const [newKey, setNewKey] = useState("");
  const [key, setKey] = useLocalStorage("key", null);

  const saveNewKey = () => {
    // TODO: query contract for airdrop
    setKey(newKey);
    setNewKey("");
  };

  const removeKey = () => {
    setKey(null);
  };

  return (
    <Disclosure
      as="nav"
      className="w-full bg-transparent backdrop-blur-sm border-b border-white/10 z-30 fixed inset-0 bottom-auto"
    >
      {({ open, close }) => {
        return (
          <>
            <div className="mx-auto max-w-7xl px-2 sm:px-4 lg:px-8">
              <div className="relative flex h-[60px] items-center justify-between">
                <div className="flex items-center px-2 lg:px-0">
                  <div className="hidden lg:ml-6 lg:block">
                    <ul className="flex justify-center gap-5 text-xl">
                      {routes.map((route) => {
                        const isActive = router.pathname === route.href;

                        return (
                          <li key={route.href}>
                            <Link
                              className={`flex items-center ${
                                isActive
                                  ? "rounded-md px-3 py-2 text-sm font-medium text-purple-700"
                                  : "rounded-md px-3 py-2 text-sm font-medium text-white/30 hover:text-white"
                              }`}
                              href={route.href}
                            >
                              {route.icon}
                              <div
                                className={
                                  isActive ? `ml-2 fancy-text` : "ml-2"
                                }
                              >
                                {route.label}
                              </div>
                            </Link>
                          </li>
                        );
                      })}
                    </ul>
                  </div>
                </div>
                <div className="flex flex-1 justify-center px-2 lg:ml-6 lg:justify-end">
                  <div className="w-full max-w-lg lg:max-w-xs">
                    {!key ? (
                      <form onSubmit={saveNewKey}>
                        <input
                          className="mr-3 text-black"
                          value={newKey}
                          placeholder="private key"
                          onChange={(e) => setNewKey(e.target.value)}
                        />
                        <button className="bg-white text-black px-2 border rounded pointer">
                          ✓
                        </button>
                      </form>
                    ) : (
                      <div>
                        <div>{key}</div>
                        <button
                          className="bg-white text-black px-2 border rounded pointer"
                          onClick={removeKey}
                        >
                          x
                        </button>
                      </div>
                    )}
                  </div>
                </div>
                <div className="flex lg:hidden">
                  {/* Mobile menu button */}
                  <Disclosure.Button className="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white">
                    <span className="sr-only">Open main menu</span>
                    {open ? (
                      <XMarkIcon className="block h-6 w-6" aria-hidden="true" />
                    ) : (
                      <Bars3Icon className="block h-6 w-6" aria-hidden="true" />
                    )}
                  </Disclosure.Button>
                </div>
              </div>
            </div>

            <Disclosure.Panel className="lg:hidden backdrop-blur-md">
              <ul className="space-y-1 px-2 pt-2 pb-3">
                {routes.map((route) => {
                  const isActive = router.pathname === route.href;
                  return (
                    <li key={route.href}>
                      <Disclosure.Button className="w-full">
                        <Link
                          onClick={() => close()}
                          className={`flex items-center ${
                            isActive
                              ? "block rounded-md px-3 py-2 font-medium text-white"
                              : "block rounded-md px-3 py-2 font-medium text-gray-300"
                          }`}
                          href={route.href}
                        >
                          {route.icon}
                          <div
                            className={`${isActive ? "fancy-text" : ""} ml-2`}
                          >
                            {route.label}
                          </div>
                        </Link>
                      </Disclosure.Button>
                    </li>
                  );
                })}
              </ul>
            </Disclosure.Panel>
          </>
        );
      }}
    </Disclosure>
  );
}
