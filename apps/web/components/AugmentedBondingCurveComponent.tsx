import { Box, Button, InputGroup, Select, Input, InputRightAddon, Text, VStack, HStack, FormControl, FormLabel} from "@chakra-ui/react";
import { useState } from 'react'
import { useRouter } from "next/router";
import { store } from "../stores/store";

export default function AugmentedBondingCurveComponent() {

    // Handle user input variables
    const [reserveRatio, setReserveRatio] = useState(store.appStatusStore.reserveRatio)
    const [colateralToken, setColateralToken] = useState(store.appStatusStore.collateralToken)
    const [initialReserve, setInitialReserve] = useState(store.appStatusStore.reserveRatio)
    const [entryTribute, setEntryTribute] = useState(store.appStatusStore.entryTribute)
    const [exitTribute, setExitTribute] = useState(store.appStatusStore.exitTribute)

    // Token addresses. Store in a more secure way in the future?
    const collateralTokenList = [
        { address: "0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d", symbol: "WXDAI" },
        { address: "0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83", symbol: "USDC" },
        { address: "0x9C58BAcC331c9aa871AFD802DB6379a98e80CEdb", symbol: "GNO" },
        { address: "0x4f4F9b8D5B4d0Dc10506e5551B0513B61fD59e75", symbol: "GIV" },
    ];

    // Handle token selection
    const handleCollateralTokenChange = (event: any) => {
        const selectedToken = collateralTokenList.find((token) => token.symbol === event.target.value);
        setColateralToken(selectedToken || { address: null, symbol: null });
    };
    
    // Handle page routing & storage of user input variables
    const router = useRouter()
    
    function handleNextButton() {
        store.appStatusStore.reserveRatio = reserveRatio
        store.appStatusStore.collateralToken = colateralToken
        store.appStatusStore.initialReserve = initialReserve
        store.appStatusStore.entryTribute = entryTribute
        store.appStatusStore.exitTribute = exitTribute
        router.push('/summary')
    }

    return (
        <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">

            <VStack spacing={4}>
                <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Configure template</Text>
                <Text fontSize="xl" as="b" p="1rem" textAlign="center">Choose your bonding curve settings below</Text>
                <VStack spacing={3}>
                    <FormControl>
                        <FormLabel>Reserve ratio</FormLabel>
                        <InputGroup>
                            <Input value={reserveRatio || 0} onChange={(e) => setReserveRatio(Number(e.target.value))} type="number" />
                            <InputRightAddon children="%" />
                        </InputGroup>
                    </FormControl>
                    <FormControl>
                        <FormLabel>Colateral token</FormLabel>
                        <Select placeholder="Select token" value={colateralToken?.symbol || ''} onChange={handleCollateralTokenChange}>
                            {collateralTokenList.map((token) => (
                                <option key={token.address} value={token.symbol}>
                                    {token.symbol}
                                </option>
                            ))}
                        </Select>
                    </FormControl>
                    <FormControl>
                        <FormLabel>Initial reserve token</FormLabel>
                        <InputGroup>
                            <Input value={initialReserve ?? 0} onChange={(e) => setInitialReserve(Number(e.target.value))} type="number" />
                            <InputRightAddon children={colateralToken?.symbol} />
                        </InputGroup>
                    </FormControl>
                    <HStack spacing={8}>
                        <FormControl>
                            <FormLabel>Entry tribute</FormLabel>
                            <InputGroup>
                                <Input value={entryTribute ?? 0} onChange={(e) => setEntryTribute(Number(e.target.value))} type="number" />
                                <InputRightAddon children="%" />
                            </InputGroup>
                        </FormControl>
                        <FormControl>
                            <FormLabel>Exit tribute</FormLabel>
                            <InputGroup>
                                <Input value={exitTribute ?? 0} onChange={(e) => setExitTribute(Number(e.target.value))} type="number" />
                                <InputRightAddon children="%" />
                            </InputGroup>
                        </FormControl>
                    </HStack>
                </VStack>

                <HStack>
                    <Button alignSelf="flex-start" onClick={() => router.push('/token')} colorScheme="blue">Back</Button>
                    <Button alignSelf="flex-end" isDisabled={!reserveRatio || !colateralToken || !initialReserve || !entryTribute || !exitTribute} onClick={handleNextButton} colorScheme="blue">Next</Button>
                </HStack>
            </VStack>
        </Box>
    )
}