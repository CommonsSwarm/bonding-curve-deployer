import { Box, Button, InputGroup, Select, Input, InputRightAddon, Flex, Text, Alert, VStack, AlertIcon, HStack, IconButton, Stack } from "@chakra-ui/react";
import { BigNumber } from "ethers";

import { usePrepareContractWrite, useContractWrite, useWaitForTransaction } from 'wagmi'

import { store } from "~/stores/store";

export default function CreateDaoComponent() {

    const addresses = store.appStatusStore?.tokenHolders?.map((holder) => holder.address);
    const balances = store.appStatusStore?.tokenHolders?.map((holder) => {
        if (holder.balance === null) {
          return null;
        }
        const balanceBigInt = BigInt(holder.balance);
        const multipliedBalance = balanceBigInt * BigInt(1e18);
        return multipliedBalance.toString();
      });

    const abi = [
        {
            "inputs": [
              {
                "name": "_tokenName",
                "type": "string"
              },
              {
                "name": "_tokenSymbol",
                "type": "string"
              },
              {
                "name": "_id",
                "type": "string"
              },
              {
                "name": "_holders",
                "type": "address[]"
              },
              {
                "name": "_stakes",
                "type": "uint256[]"
              },
              {
                "name": "_votingSettings",
                "type": "uint64[3]"
              },
              {
                "name": "_fees",
                "type": "uint256[2]"
              },
              {
                "name": "_collateralToken",
                "type": "address"
              },
              {
                "name": "_reserveRatio",
                "type": "uint32"
              },
              {
                "name": "_initialBalance",
                "type": "uint256"
              }
            ],
            "name": "newTokenAndInstance",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
          }
    ]    
 
    const { config, error } = usePrepareContractWrite({
        address: '0x51dCc0B9AD7B77aC87f9Afa5e792dfFB4c8Aa1C8',
        abi: abi,
        functionName: 'newTokenAndInstance', 
        args: [
            store.appStatusStore.tokenName,
            store.appStatusStore.tokenSymbol,
            store.appStatusStore.domain,
            addresses,
            balances,
            [(BigInt(1e16) * BigInt(store.appStatusStore.support)).toString(),
            (BigInt(1e16) * BigInt(store.appStatusStore.minApproval)).toString(),
            Number(store.appStatusStore.days) * 24 * 60 * 60 + Number(store.appStatusStore.hours) * 60 * 60 + Number(store.appStatusStore.minutes) * 60],
            [(BigInt(1e16) * BigInt(store.appStatusStore.entryTribute)).toString(),
            (BigInt(1e16) * BigInt(store.appStatusStore.exitTribute)).toString()],
            store.appStatusStore.collateralToken?.address,
            store.appStatusStore.reserveRatio * 10000,
            0
        ]
      })

      

    const { write } = useContractWrite(config)

      console.log(write)
      console.log(error)

      const { data, isError, isLoading } = useWaitForTransaction({
        hash: write?.data?.hash,
        onSuccess(data) {
            console.log('Success', data)
          },
      })

      if (isLoading) return <div>Processing…</div>
  if (isError) return <div>Transaction error</div>
      console.log(data)

    return(
        <main>
            <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
                <Button onClick={() => write?.()}>Try</Button>
            </Box>
        </main>
    )
}



 
