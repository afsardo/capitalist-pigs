import type { AppProps } from "next/app";
import Head from "next/head";
import Footer from "src/components/Footer";
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
      <div className="min-h-screen bg-black text-[#F1F7ED] flex flex-col">
        <Navbar />
        <div className="mt-[80px] mb-[80px] max-w-5xl w-full mx-auto py-4 flex-1 px-4">
          <Component {...pageProps} />
        </div>
        <Footer />
      </div>
    </>
  );
}
