import { useEffect, useState } from "react";
import { Wallet } from "fuels";
import {
  // PigsAbi__factory,
  // BaconDistributorAbi__factory,
  // MockContractAbi__factory,
  ContractAbi__factory,
} from "../contracts";
import Button from "./Button";

// The private key of the `owner` in chainConfig.json.
// This enables us to have an account with an initial balance.
const WALLET_SECRET =
  "0x94ffcc53b892684acefaebc8a3d4a595e528a8cf664eeb3ef36f1020b0809d0d";

// The ID of the contract deployed to our local node.
// The contract ID is displayed when the `forc deploy` command is run.
const CONTRACT_ID =
  "0x3b45de1bdcf6772ee535d7a067bd0692b99ac721e745ab8572bf86c9b776c728";

// Create a "Wallet" using the private key above.
const wallet = new Wallet(WALLET_SECRET);

// const contract = PigsAbi__factory.connect(CONTRACT_ID, wallet);
// const contractBacon = BaconDistributorAbi__factory.connect(CONTRACT_ID, wallet);

// 0xd97ac31a1a473e6dd6f7dfdaf773a2a4df452ec3445afd291298b48dcea57cd3
const contractCounter = ContractAbi__factory.connect(
  "0xd97ac31a1a473e6dd6f7dfdaf773a2a4df452ec3445afd291298b48dcea57cd3",
  wallet
);

export default function DashboardPage() {
  const [pigs, setPigs] = useState<any>([]);

  useEffect(() => {
    async function getPigs() {
      // GET PIGS FROM SC
      const { value } = await contract.functions
        .pigs(
          {
            Address: {
              value: WALLET_SECRET,
            },
          },
          1
        )
        .get();

      console.log(value);

      // setPigs(value);
    }

    const mintPig = async () => {
      const res = await contract.functions
        .mint(1, {
          Address: {
            value: WALLET_SECRET,
          },
        })
        .get();

      console.log(res);
    };

    // mintPig();
    // getPigs();
  }, []);

  const mintPig = async () => {
    // const res = await contract.functions
    //   .mint(1, {
    //     Address: {
    //       value: WALLET_SECRET,
    //     },
    //   })
    //   .call();

    const res = await contract.functions
      .gg({
        Address: {
          value: WALLET_SECRET,
        },
      })
      .get();

    console.log(res);
  };

  const increment = async () => {
    const { value } = await contractCounter.functions.counter().get();
    console.log(value);

    await contractCounter.functions.increment(1).call();
  };

  return (
    <div>
      <Button onClick={mintPig}>MINT PIG</Button>
      <Button onClick={increment}>Increment</Button>
      <p>You have {pigs.length} pigs</p>
    </div>
  );
}
