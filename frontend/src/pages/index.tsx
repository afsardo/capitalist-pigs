import dynamic from "next/dynamic";
import Image from "next/image";
import { useEffect } from "react";

import Heading from "src/components/Heading";

const Counter = dynamic(() => import("../components/Counter"), {
  ssr: false,
});

export default function Home() {
  useEffect(() => {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("show");
        } else {
          entry.target.classList.remove("show");
        }
      });
    });

    const sections = document.querySelectorAll(".hide");
    sections.forEach((section) => observer.observe(section));
  }, []);

  return (
    <div>
      <Heading className="mb-5">Capitalist Pigs</Heading>

      <main>
        <Counter />

        <section className="h-screen grid place-items-center text-center hide">
          <div>
            <h4 className="mb-20 text-2xl">
              The whole proccess is pretty straight-forward
            </h4>
            <div className="flex items-center gap-5">
              <div className="rounded-lg bg-gray-700 p-4">
                <Image src="/pig.jpeg" alt="lab" width={200} height={200} />
              </div>
              <p className="font-bold">
                Adquire a <span className="fancy-text">PIG</span>
              </p>
            </div>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center">
          <div className="flex flex-col h-full max-h-72 justify-between max-w-xl w-full">
            <div className="text-left text-2xl hide">
              <span className="fancy-text">Stake</span> your pig to{" "}
              <span className="fancy-text-2 font-bold">receive fees...</span>
            </div>
            <div className="text-right text-2xl hide">
              <span className="fancy-text-2">Hold</span> your pig to{" "}
              <span className="fancy-text font-bold">generate mucus!</span>
            </div>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center">
          <div>
            <h5 className="tracking-wider mb-12">
              You can now use your mucus to...
            </h5>
            <div className="flex justify-center gap-x-4 mb-8">
              <div className="rounded-lg bg-green-700 p-4 hide">
                <Image src="/piglet.png" width={120} height={120} />
              </div>
              <div className="rounded-lg bg-red-700 p-4 delay-200 hide">
                <Image src="/piglet.png" width={120} height={120} />
              </div>
              <div className="rounded-lg bg-yellow-700 p-4 delay-500 hide">
                <Image src="/piglet.png" width={120} height={120} />
              </div>
              <div className="rounded-lg bg-pink-700 p-4 delay-1000 hide">
                <Image src="/piglet.png" width={120} height={120} />
              </div>
            </div>
            <h5 className="animate-bounce font-bold">
              Create <span className="fancy-text uppercase">tons</span> of
              piglets 🐽
            </h5>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center hide">
          <div>
            <p className="text-white/70 mb-8">
              Stop being a peasant today... be a part of the capital PIGS
            </p>
            <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest">
              BUY
            </button>
          </div>
        </section>
      </main>

      <footer>Powered b Degens, BlazinglyFast™</footer>
    </div>
  );
}
