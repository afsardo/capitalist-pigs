/* eslint-disable @next/next/no-img-element */
import { useEffect, useState } from "react";
import { Wallet } from "fuels";
import { PigsAbi__factory } from "../contracts";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0x94ffcc53b892684acefaebc8a3d4a595e528a8cf664eeb3ef36f1020b0809d0d";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0x597f725c0cd2e1b83e24e324bc37363f0c6bb2a8daf4bd38fb55fcee60c4e479";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = PigsAbi__factory.connect(CONTRACT_ID, wallet);

export default function DashboardPage() {
  const actions = useAllOutLifeStore((s) => s.actions);
  const pigCount = useAllOutLifeStore((s) => s.pigCount);
  const stakedPigs = useAllOutLifeStore((s) => s.stakedPigs);
  // const [pigs, setPigs] = useState([]);

  useEffect(() => {
    async function getPigs() {
      // GET PIGS FROM SC
      const { value: pigsCount } = await contract.functions
        .balance_of({ Address: { value: WALLET_SECRET } })
        .get();

      if (pigsCount.gt(0)) {
        // @TODO
        // Fetch all pigs
      }
    }
    // getPigs();
  }, []);

  const pigs = [];
  for (let i = 0; i < pigCount; i++) {
    pigs.push(i);
  }

  return (
    <>
      {pigCount <= 0 && <p>You have no pings</p>}
      <div className="my-8 mb-32 grid grid-cols-4 gap-4">
        {pigs.map((pig) => {
          return (
            <div key={pig} className="rounded-xl overflow-hidden relative">
              <img src={`/pigs/${(pig % 9) + 1}.jpeg`} />
              <div className="absolute bottom-1 w-full px-4">
                <div className="bg-black/80 rounded-lg text-center font-medium">
                  #{pig + 1}{" "}
                  {stakedPigs.includes(pig) && (
                    <button
                      onClick={() => actions.unstakePig(pig)}
                      className="font-bold"
                    >
                      (UNSTAKED)
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </>
  );
}
