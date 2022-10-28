import dynamic from "next/dynamic";

const Counter = dynamic(() => import("../components/Counter"), {
  ssr: false,
});

export default function Home() {
  return (
    <div>
      <header>
        <h1>CapitalistPigs</h1>
      </header>

      <main>
        <Counter />
      </main>

      <footer>Powered b Degens, BlazinglyFast™</footer>
    </div>
  );
}
