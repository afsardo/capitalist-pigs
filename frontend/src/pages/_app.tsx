import type { AppProps } from "next/app";
import Head from "next/head";
import dynamic from "next/dynamic";
import Footer from "src/components/Footer";

import "../styles/globals.css";
import { useEffect } from "react";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

const Navbar = dynamic(() => import("../components/Navbar"), {
  ssr: false,
});

export default function App({ Component, pageProps }: AppProps) {
  const stakedPigs = useAllOutLifeStore((s) => s.stakedPigs);
  const actions = useAllOutLifeStore((s) => s.actions);

  useEffect(() => {
    const interval = setInterval(() => {
      const stakedAmount = stakedPigs.length;
      if (stakedAmount > 0) {
        actions.mintTruffles(stakedAmount);
        actions.mintBacon(stakedAmount);
      }
    }, 1000);

    return () => {
      clearInterval(interval);
    };
  }, [stakedPigs, actions]);

  return (
    <>
      <Head>
        <title>Capitalist Pigs</title>
        <meta
          name="description"
          content="CapitalistPigs built by Degens, BlazinglyFast™"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="max-w-5xl w-full mx-auto py-4 flex-1 px-4">
          <Component {...pageProps} />
        </div>
        <Footer />
      </div>
    </>
  );
}
