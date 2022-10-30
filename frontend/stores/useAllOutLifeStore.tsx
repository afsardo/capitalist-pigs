import create from "zustand";
import { persist } from "zustand/middleware";

interface State {
  privateKey: string;
  actions: {
    setPrivateKey: (key: string) => void;
  };
}

export const useAllOutLifeStore = create<State>()(
  persist(
    (set) => ({
      privateKey: "",
      actions: {
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
