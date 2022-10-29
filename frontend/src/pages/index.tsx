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
      <main>
        <section className="h-screen grid place-items-center text-center hide">
          <div>
            <h4 className="mb-14 text-2xl uppercase bg-purple-700 font-bold inline-block p-4">
              How it works
            </h4>
            <div className="animate-bounce text-4xl mb-16">👇</div>
            <div className="flex items-center gap-5">
              <div className="rounded-lg bg-gray-700 p-4">
                <Image src="/pig.jpeg" alt="lab" width={200} height={200} />
              </div>
              <p className="font-bold">
                Acquire a <span className="fancy-text">PIG</span>
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
            <h5 className="tracking-wider mb-12 text-xl">
              You can now use your mucus to...
            </h5>
            <div className="flex justify-center gap-x-4 mb-8">
              <div className="rounded-lg bg-green-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={120}
                  height={120}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-red-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={120}
                  height={120}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-yellow-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={120}
                  height={120}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-pink-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={120}
                  height={120}
                  alt="piglet"
                />
              </div>
            </div>
            <h5 className="animate-bounce font-bold text-xl">
              Create <span className="fancy-text uppercase">tons</span> of
              piglets 🐽
            </h5>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center hide">
          <div>
            <p className="text-white/70 mb-8 text-lg">
              Stop being a peasant today... be a part of the Capitalist Pigs
            </p>
            <button className="bg-purple-700 hover:bg-purple-900 p-4 rounded-xl w-48 font-semibold tracking-widest animate-bounce">
              BUY
            </button>
          </div>
        </section>
      </main>
    </div>
  );
}
