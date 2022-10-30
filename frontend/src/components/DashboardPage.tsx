import { useEffect, useState } from "react";
import { Wallet } from "fuels";
import { PigsAbi__factory } from "../contracts";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0x94ffcc53b892684acefaebc8a3d4a595e528a8cf664eeb3ef36f1020b0809d0d";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0xe12f0467fc3693a5b745caf707a9e35749e96f1eff64f0e2060ec4f3e09ab8c6";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = PigsAbi__factory.connect(CONTRACT_ID, wallet);

export default function DashboardPage() {
  const [pigs, setPigs] = useState([]);

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
    getPigs();
  }, []);

  return <>You have {pigs.length} pigs</>;
}
