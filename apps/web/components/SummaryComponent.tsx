import { Box, Button, InputGroup, Select, Input, InputRightAddon, Flex, Text, Alert, VStack, AlertIcon, HStack, IconButton, Stack } from "@chakra-ui/react";
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
import { ethers } from "ethers";

export default function SummaryComponent() {

    const router = useRouter()

    function launchDao() {

    }

    function handleBackButton() {
        router.push('/augmented-bonding-curve')
    }

    return (
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
                    <Button alignSelf="flex-end" onClick={launchDao}>Launch</Button>
                </HStack>
            </VStack>
        </Box>
    )
}