import create from "zustand";
import { persist } from "zustand/middleware";

interface State {
  privateKey: string;
  pigCount: number;
  stakedPigs: number[];
  truffleCount: number;
  piggletCount: number;
  baconCount: number;
  delegatedPigglets: number[];
  actions: {
    mintPig: () => void;
    pigletsIntoPig: () => void;
    trufflesIntoPiglet: () => void;
    setPrivateKey: (key: string) => void;
    stakePig: (pig: number) => void;
    unstakePig: (pig: number) => void;
    delegatePigglet: (piglet: number) => void;
    undelegatePigglet: (piglet: number) => void;
    mintTruffles: (stakedPigs: number) => void;
    mintBacon: (stakedPigs: number) => void;
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
      stakedPigs: [],
      delegatedPigglets: [],
      actions: {
        mintPig: () => set((state) => ({ pigCount: state.pigCount + 1 })),
        pigletsIntoPig: () =>
          set((state) => ({
            pigCount: state.pigCount + 1,
            piggletCount: state.piggletCount - 5,
          })),
        trufflesIntoPiglet: () =>
          set((state) => ({
            piggletCount: state.piggletCount + 1,
            truffleCount: state.truffleCount - 100,
          })),
        setPrivateKey: (key: string) => set(() => ({ privateKey: key })),
        stakePig: (pig: number) =>
          set((state) => {
            const stakedPigs = state.stakedPigs.filter((p) => p != pig);
            return {
              stakedPigs: [...stakedPigs, pig],
            };
          }),
        unstakePig: (pig: number) =>
          set((state) => ({
            stakedPigs: state.stakedPigs.filter((p) => p != pig),
          })),
        delegatePigglet: (pigglet: number) =>
          set((state) => {
            const delegatedPigglets = state.delegatedPigglets.filter(
              (p) => p != pigglet
            );
            return {
              delegatedPigglets: [...delegatedPigglets, pigglet],
            };
          }),
        undelegatePigglet: (pigglet: number) =>
          set((state) => ({
            delegatedPigglets: state.delegatedPigglets.filter(
              (p) => p != pigglet
            ),
          })),
        mintTruffles: (stakedPigs: number) =>
          set((state) => {
            const truffles = state.truffleCount + stakedPigs * 5;
            return {
              truffleCount: truffles,
            };
          }),
        mintBacon: (stakedPigs: number) =>
          set((state) => {
            const bacon = state.baconCount + stakedPigs * 0.05;
            return {
              baconCount: bacon,
            };
          }),
      },
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
