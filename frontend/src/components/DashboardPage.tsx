import { useEffect, useState } from "react";
import { Wallet } from "fuels";
import { PigsAbi__factory } from "../contracts/pigs";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0xd97ac31a1a473e6dd6f7dfdaf773a2a4df452ec3445afd291298b48dcea57cd3";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

const contract = PigsAbi__factory.connect(CONTRACT_ID, wallet);

export default function DashboardPage() {
  const [pigs, setPigs] = useState([]);

  useEffect(() => {
    async function getPigs() {

      // GET PIGS FROM SC
      // const { value: pigs } = await contract.functions.pigs({ Address: { value: WALLET_SECRET} }).get();

    }
    getPigs();
  }, []);

  return (
    <>
      You have {pigs.length} pigs
    </>
  );
}
