import { Wallet } from "fuels";
import { useRef, useState } from "react";
import { formatWalletAddress } from "src/utils";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";
import Button from "./Button";
import Modal from "./Modal";

const WalletWidget = () => {
  const [isOpen, setIsOpen] = useState(false);

  const privateKey = useAllOutLifeStore((s) => s.privateKey);
  const setPrivateKey = useAllOutLifeStore((s) => s.actions.setPrivateKey);

  const inputRef = useRef<HTMLInputElement>(null);

  const generateWallet = async () => {
    const res = await Wallet.generate();
    setPrivateKey(res.privateKey);
    setIsOpen(false);
  };

  const submit = () => {
    if (inputRef.current) {
      setPrivateKey(inputRef.current.value);
      setIsOpen(false);
    }
  };

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="text-ellipsis overflow-hidden w-[200px] border border-yellow-400 px-3 py-1 rounded-full"
      >
        {privateKey ? formatWalletAddress(privateKey) : "Connect"}
      </button>
      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)} title="Wallet">
        <div className="flex mb-8 gap-2 text-black">
          {privateKey ? (
            <div>Private key: {formatWalletAddress(privateKey)}</div>
          ) : (
            <>
              <input
                ref={inputRef}
                placeholder="Private Key"
                className="px-2 beautiful-input-button"
              />
              <button
                className="bg-white text-black px-2 beautiful-input-button"
                onClick={submit}
              >
                Submit
              </button>
            </>
          )}
        </div>
        <div className="flex gap-4">
          <Button
            className="rounded-full py-2 text-sm"
            onClick={generateWallet}
          >
            Generate Address
          </Button>
          <Button
            className={`rounded-full py-2 text-sm ${
              privateKey === ""
                ? "opacity-30 cursor-auto pointer-events-none"
                : ""
            }`}
            onClick={() => {
              setPrivateKey("");
              setIsOpen(false);
            }}
          >
            Disconnect
          </Button>
        </div>
      </Modal>
    </>
  );
};

export default WalletWidget;
