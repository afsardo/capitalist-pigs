import create from "zustand";
import { persist } from "zustand/middleware";

interface State {
  privateKey: string;
  pigCount: number;
  truffleCount: number;
  piggletCount: number;
  baconCount: number;
  actions: {
    mintPig: () => void;
    pigletsIntoPig: () => void;
    trufflesIntoPiglet: () => void;
    setPrivateKey: (key: string) => void;
  };
}

export const useAllOutLifeStore = create<State>()(
  persist(
    (set) => ({
      privateKey: "",
      pigCount: 0,
      truffleCount: 0,
      piggletCount: 0,
      baconCount: 0,
      actions: {
        mintPig: () => set((state) => ({ pigCount: state.pigCount + 1 })),
        pigletsIntoPig: () =>
          set((state) => (
            { 
              pigCount: state.pigCount + 1,
              piggletCount: state.piggletCount - 5
            }
          )),
        trufflesIntoPiglet: () =>
          set((state) => (
            { 
              piggletCount: state.piggletCount + 1,
              truffleCount: state.truffleCount - 10
            }
          )),
        setPrivateKey: (key: string) => set(() => ({ privateKey: key })),
      },
      //   increasePopulation: () => set((state) => ({ bears: state.bears + 1 })),
      //   removeAllBears: () => set({ bears: 0 }),
    }),
    {
      name: "__123___",
      partialize: (state) =>
        Object.fromEntries(
          Object.entries(state).filter(([key]) => !["actions"].includes(key))
        ),
    }
  )
);
