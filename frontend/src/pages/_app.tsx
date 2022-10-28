import type { AppProps } from "next/app";
import Head from "next/head";

import Navbar from "src/components/Navbar";

import "../styles/globals.css";

export default function App({ Component, pageProps }: AppProps) {
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
      <div className="min-h-screen bg-black text-[#F1F7ED]">
        <Navbar />
        <div className="max-w-5xl w-full mx-auto py-4">
          <Component {...pageProps} />
        </div>
      </div>
    </>
  );
}
