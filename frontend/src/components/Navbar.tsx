import React, { useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/router";
import { Disclosure } from "@headlessui/react";
import { Wallet } from "fuels";
import {
  BanknotesIcon,
  BeakerIcon,
  ChartBarIcon,
  HomeModernIcon,
} from "@heroicons/react/24/solid";
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";

import Modal from "./Modal";
import Button from "./Button";
import { formatWalletAddress } from "src/utils";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

const WalletWidget = () => {
  const [isOpen, setIsOpen] = useState(false);

  const privateKey = useAllOutLifeStore((s) => s.privateKey);
  const setPrivateKey = useAllOutLifeStore((s) => s.actions.setPrivateKey);

  const inputRef = useRef<HTMLInputElement>(null);

  const generateWallet = async () => {
    const res = await Wallet.generate();
    setPrivateKey(res.privateKey);
    setIsOpen(false);
  };

  const submit = () => {
    if (inputRef.current) {
      setPrivateKey(inputRef.current.value);
      setIsOpen(false);
    }
  };

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="text-ellipsis overflow-hidden w-[200px] border border-yellow-400 px-3 py-1 rounded-full"
      >
        {privateKey ? formatWalletAddress(privateKey) : "Connect"}
      </button>
      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title="Wallet">
        <div className="flex mb-8 gap-2 text-black">
          {privateKey ? (
            <div>Private key: {formatWalletAddress(privateKey)}</div>
          ) : (
            <>
              <input
                ref={inputRef}
                placeholder="Private Key"
                className="px-2 beautiful-input-button"
              />
              <button className="bg-white text-black px-2 beautiful-input-button" onClick={submit}>
                Submit
              </button>
            </>
          )}
        </div>
        <div className="flex gap-4">
          <Button
            className="rounded-full py-2 text-sm"
            onClick={generateWallet}
          >
            Generate Address
          </Button>
          <Button
            className={`rounded-full py-2 text-sm ${
              privateKey === ""
                ? "opacity-30 cursor-auto pointer-events-none"
                : ""
            }`}
            onClick={() => {
              setPrivateKey("");
              setIsOpen(false);
            }}
          >
            Disconnect
          </Button>
        </div>
      </Modal>
    </>
  );
};

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
                  <WalletWidget />
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
