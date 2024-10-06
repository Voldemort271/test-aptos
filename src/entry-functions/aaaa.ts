import { aptosClient } from "@/utils/aptosClient.ts";
import { MODULE_ADDRESS } from "@/constants.ts";

export const getcount = async (): Promise<string> => {
  try {
    const content = await aptosClient().view<[number]>({
      payload: {
        function: `${MODULE_ADDRESS}::supply_chain::test`, // Use your module and function name
      },
    });
    
    return content[0].toString(); // Convert the result to a string if needed
  } catch (error) {
    console.error(error);
    return "Error occurred while fetching the count"; // Handle errors appropriately
  }
};
