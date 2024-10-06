import { MODULE_ADDRESS } from "@/constants";
import { InputTransactionData } from "@aptos-labs/wallet-adapter-react";

export type WriteMessageArguments = {
  content: string; // the content of the message
};

export const init = (args: WriteMessageArguments): InputTransactionData => {
  const { content } = args;
  console.log(content);
  return {
    data: {
      function: `${MODULE_ADDRESS}::supply_chain::init_counter`,
      functionArguments: [],
    },
  };
};


export const increase = (args: WriteMessageArguments): InputTransactionData => {
  const { content } = args;
  console.log(content);
  return {
    data: {
      function: `${MODULE_ADDRESS}::supply_chain::increment`,
      functionArguments: [],
    },
  };
};
