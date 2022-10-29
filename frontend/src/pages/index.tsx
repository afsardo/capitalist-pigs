import dynamic from "next/dynamic";
import Image from "next/image";
import { useEffect } from "react";

const Test = dynamic(() => import("../components/Test"), {
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

  return <Test />;

  return (
    <div>
      <Test />
      <main>
        <section className="h-screen grid place-items-center text-center">
          <div>
            <h4 className="mb-14 text-2xl uppercase bg-purple-700 font-bold inline-block py-4 px-6">
              How it works
            </h4>
            <div className="animate-bounce text-4xl mb-16">👇</div>
            <div className="flex items-center gap-5 hide">
              <p className="font-bold text-4xl">
                Acquire a <span className="fancy-text-2">PIG...</span>
              </p>
              <span className="text-7xl">🐖</span>
            </div>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center">
          <div className="flex flex-col h-full max-h-72 justify-between max-w-3xl w-full">
            <div className="text-left text-2xl md:text-4xl hide">
              <span className="fancy-text">Stake</span> your pig to{" "}
              <span className="fancy-text-2 font-bold">receive fees...</span>
            </div>
            <div className="text-right text-2xl md:text-4xl hide">
              <span className="fancy-text-2">Hold</span> your pig to{" "}
              <span className="fancy-text font-bold">generate truffles!</span>
            </div>
          </div>
        </section>
        <section className="h-screen grid place-items-center text-center">
          <div>
            <h5 className="tracking-wider mb-12 text-2xl text-white/50">
              You can now use your truffles to...
            </h5>
            <div className="flex flex-col md:flex-row justify-center items-center gap-4 mb-8">
              <div className="rounded-lg bg-green-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={100}
                  height={100}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-red-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={100}
                  height={100}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-yellow-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={100}
                  height={100}
                  alt="piglet"
                />
              </div>
              <div className="rounded-lg bg-pink-700 p-4 hide logo-container hover:scale-125">
                <Image
                  src="/piglet.png"
                  width={100}
                  height={100}
                  alt="piglet"
                />
              </div>
            </div>
            <h5 className="animate-bounce font-bold text-2xl">
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
              CLAIM
            </button>
          </div>
        </section>
      </main>
    </div>
  );
}
