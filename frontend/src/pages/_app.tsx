import type { AppProps } from "next/app";
import Head from "next/head";
import Link from "next/link";

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
      <div>
        <ul>
          <li>
            <Link href="frontpage">Frontpage</Link>
          </li>
          <li>
            <Link href="lab">Laboratory</Link>
          </li>
          <li>
            <Link href="coop">Co-op</Link>
          </li>
        </ul>
        <Component {...pageProps} />
      </div>
    </>
  );
}
