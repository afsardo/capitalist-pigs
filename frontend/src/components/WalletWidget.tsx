import { Wallet } from "fuels";
import { useRef, useState } from "react";
import { formatWalletAddress } from "src/utils";
import { useAllOutLifeStore } from "stores/useAllOutLifeStore";
import Button from "./Button";
import Modal from "./Modal";
import { ClipboardIcon } from "@heroicons/react/24/solid";

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

  const copyClipboard = (text: string) => {
    if (navigator) {
      navigator.clipboard.writeText(text);
      alert("Copied!");
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
            <div className="flex items-center gap-4">
              Private key: {formatWalletAddress(privateKey)}
              <ClipboardIcon
                className="w-5 h-5 inline-block cursor-pointer"
                onClick={() => copyClipboard(privateKey)}
              />
            </div>
          ) : (
            <>
              <input
                ref={inputRef}
                placeholder="Private Key"
                className="p-2 rounded-lg flex-1"
              />
              <button
                className="bg-white text-black p-2 rounded-lg hover:bg-white/80"
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
