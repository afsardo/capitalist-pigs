import dynamic from "next/dynamic";

import Heading from "src/components/Heading";

const Counter = dynamic(() => import("../components/Counter"), {
  ssr: false,
});

export default function Home() {
  return (
    <div>
      <Heading className="mb-5">Capitalist Pigs</Heading>

      <main>
        <Counter />
      </main>

      <footer>Powered b Degens, BlazinglyFast™</footer>
    </div>
  );
}
