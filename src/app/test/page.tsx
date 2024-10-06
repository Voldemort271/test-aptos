"use client";

import React, { useEffect, useState } from "react";
import { increase } from "@/entry-functions/dhinkachika.ts";
import { aptosClient } from "@/utils/aptosClient.ts";
import { toast } from "@/components/ui/use-toast.ts";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { getcount } from "@/entry-functions/aaaa.ts";

const Test = () => {
  const { account, signAndSubmitTransaction } = useWallet();
  const queryClient = useQueryClient();
  
  const [count, setCount] = useState("initial");
  
  const { data } = useQuery({
    queryKey: ["message-content", account?.address],
    refetchInterval: 10_000,
    queryFn: async () => {
      try {
        const content = await getcount();
        
        return {
          content,
        };
      } catch (error: any) {
        toast({
          variant: "destructive",
          title: "Error",
          description: error,
        });
        return {
          content: "",
        };
      }
    },
  });
  
  
  useEffect(() => {
    if (data) {
      setCount(data.content);
    }
  }, [data]);
  
  const onClickButton = async () => {
    if (!account) {
      return;
    }
    
    try {
      const committedTransaction = await signAndSubmitTransaction(
        increase({
          content: "hi",
        }),
      );
      const executedTransaction = await aptosClient().waitForTransaction({
        transactionHash: committedTransaction.hash,
      });
      await queryClient.invalidateQueries();
      toast({
        title: "Success",
        description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
      });
    } catch (error) {
      console.error(error);
    }
  };
  
  return (
    <div>
      hi
      <button onClick={onClickButton}>Do test</button>
      <div>{count}</div>
    </div>
  );
};

export default Test;
