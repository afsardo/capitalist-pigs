import type { AppProps } from "next/app";
import Head from "next/head";

import "../styles/globals.css";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <>
      <Head>
        <title>CapitalistPigs</title>
        <meta
          name="description"
          content="CapitalistPigs built by Degens, BlazinglyFast™"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Component {...pageProps} />;
    </>
  );
}
