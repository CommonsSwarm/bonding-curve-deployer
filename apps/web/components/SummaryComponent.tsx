import { Box, Button, InputGroup, Spinner, Select, Input, InputRightAddon, Flex, Text, Alert, VStack, AlertIcon, HStack, IconButton, Stack } from "@chakra-ui/react";
import { useRouter } from "next/router";
import {
    Accordion,
    AccordionItem,
    AccordionButton,
    AccordionPanel,
    AccordionIcon,
} from '@chakra-ui/react'
import { store } from "~/stores/store";
import {
    Table,
    Thead,
    Tbody,
    Tfoot,
    Tr,
    Th,
    Td,
    TableCaption,
    TableContainer,
} from '@chakra-ui/react'
import { useEffect, useState } from 'react';
import { ethers } from "ethers";


import { usePrepareContractWrite, useContractWrite, useWaitForTransaction } from 'wagmi'

export default function SummaryComponent() {


    // Open window with Aragon
    const openInNewTab = (url) => {
        window.open(url, "_blank", "noreferrer");
      };

    // Process holder adresses and balances
    const addresses = store.appStatusStore?.tokenHolders?.map((holder) => holder.address);
    const balances = store.appStatusStore?.tokenHolders?.map((holder) => {
        if (holder.balance === null) {
          return null;
        }
        const balanceNumber = holder.balance;
        const balanceBigInt = BigInt(balanceNumber);
        const multipliedBalance = balanceBigInt * BigInt(1e18);
        return multipliedBalance.toString();
      });

    // ABI
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

    // Prepare contract
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

    // Execute contract function
    const { data, isLoading, write } = useContractWrite(config)

    // State to store the transaction status
    const [isMined, setIsMined] = useState(false);
    const [isSending, setIsSending] = useState(false);

    // Functions to manage the back button
    const router = useRouter()

    function handleBackButton() {
        router.push('/augmented-bonding-curve')
    }

    // Effect to check the transaction status
    useEffect(() => {
        if (data?.hash) {
            setIsSending(false);
            const provider = new ethers.providers.JsonRpcProvider(process.env.NEXT_PUBLIC_INFURA_URL);
            const interval = setInterval(async () => {
                const receipt = await provider.getTransactionReceipt(data.hash);
                if (receipt && receipt.blockNumber) {
                    setIsMined(true);
                    clearInterval(interval);
                }
            }, 15000); // Check every 5 seconds

        
            return () => clearInterval(interval); // Clean up on unmount
        }
    }, [data]);

    const handleLaunch = () => {
        setIsSending(true);
        write?.();
    }

    return (
        <div>
            {isSending || isLoading ? (
                <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
                    <VStack spacing={4}>
                        <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Creating your DAO...</Text>
                        <Spinner size="xl" />
                    </VStack>
                </Box>
            ) : data && !!data.hash ? (
                <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
                    <VStack spacing={4}>
                        <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Your DAO has been successfully created!</Text>
                        <Button onClick={() => openInNewTab("https://xdai.aragon.blossom.software/#/" + store.appStatusStore.domain)}>See DAO</Button>
                    </VStack>
                </Box>
            ) : (
                <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
                    <VStack spacing={4}>
                        <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Summary</Text>
                        <Text fontSize="xl" as="b" p="1rem" textAlign="center">Make sure your settings are correct</Text>
                        <Accordion width="80%">
                            <AccordionItem>
                                <h2>
                                    <AccordionButton>
                                        <Box flex='1' textAlign='left'>
                                            Organization settings
                                        </Box>
                                        <AccordionIcon />
                                    </AccordionButton>
                                </h2>
                                <AccordionPanel pb={4}>
                                    <Text>
                                        Domain: <Text as="b">{store.appStatusStore.domain + '.aragonid.eth'}</Text>
                                    </Text>
                                </AccordionPanel>
                            </AccordionItem>

                            <AccordionItem>
                                <h2>
                                    <AccordionButton>
                                        <Box flex='1' textAlign='left'>
                                            Governance settings
                                        </Box>
                                        <AccordionIcon />
                                    </AccordionButton>
                                </h2>
                                <AccordionPanel pb={4}>
                                    <Text>
                                        Support: <Text as="b">{store.appStatusStore.support + '%'}</Text>
                                    </Text>
                                    <Text>
                                        Minimum approval: <Text as="b">{store.appStatusStore.minApproval + '%'}</Text>
                                    </Text>
                                    <Text>
                                        Vote duration: <Text as="b">{store.appStatusStore.days + ' days ' + store.appStatusStore.hours + ' hours ' + store.appStatusStore.minutes + ' minutes'}</Text>
                                    </Text>
                                    <Text>
                                        Token name: <Text as="b">{store.appStatusStore.tokenName}</Text>
                                    </Text>
                                    <Text>
                                        Token symbol: <Text as="b">{store.appStatusStore.tokenSymbol}</Text>
                                    </Text>
                                    <Table variant="simple">
                                        <Thead>
                                            <Tr>
                                                <Th>Holder account</Th>
                                                <Th>Balance</Th>
                                            </Tr>
                                        </Thead>
                                        <Tbody>
                                            {store.appStatusStore?.tokenHolders?.map((holder, index) => (
                                                <Tr key={index}>
                                                    <Td>{holder.address || "-"}</Td>
                                                    <Td>{holder.balance !== null ? holder.balance : "-"}</Td>
                                                </Tr>
                                            ))}
                                        </Tbody>
                                    </Table>

                                </AccordionPanel>
                            </AccordionItem>

                            <AccordionItem>
                                <h2>
                                    <AccordionButton>
                                        <Box flex='1' textAlign='left'>
                                            Augmented bonding curve settings
                                        </Box>
                                        <AccordionIcon />
                                    </AccordionButton>
                                </h2>
                                <AccordionPanel pb={4}>
                                    <Text>
                                        Reserve ratio: <Text as="b">{store.appStatusStore.reserveRatio + '%'}</Text>
                                    </Text>
                                    <Text>
                                        Colateral token: <Text as="b">{store.appStatusStore.collateralToken?.symbol}</Text>
                                    </Text>
                                    <Text>
                                        Initial reserve token: <Text as="b">{store.appStatusStore.initialReserve + ' ' + store.appStatusStore.collateralToken?.symbol}</Text>
                                    </Text>
                                    <Text>
                                        Entry tribute: <Text as="b">{store.appStatusStore.entryTribute + '%'}</Text>
                                    </Text>
                                    <Text>
                                        Exit tribute: <Text as="b">{store.appStatusStore.entryTribute + '%'}</Text>
                                    </Text>
                                </AccordionPanel>
                            </AccordionItem>
                        </Accordion>
                        <HStack>
                            <Button alignSelf="flex-start" onClick={handleBackButton}>Back</Button>
                            <Button alignSelf="flex-end" onClick={handleLaunch}>Launch</Button>
                        </HStack>
                    </VStack>
                </Box>
            )}
        </div>
    )
}
