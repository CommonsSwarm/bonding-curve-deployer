import { Box, Button, InputGroup, Input, InputRightAddon, Text, VStack, HStack, IconButton, FormControl, FormLabel } from "@chakra-ui/react";
import { useState } from 'react'
import { CloseIcon } from "@chakra-ui/icons";
import { useRouter } from "next/router";
import { store } from "../stores/store";

export default function TokenHoldersComponent() {

    // Handle user input variables
    const [tokenName, setTokenName] = useState(store.appStatusStore.tokenName)
    const [tokenSymbol, setTokenSymbol] = useState(store.appStatusStore.tokenSymbol)
    const [tokenHolders, setTokenHolders] = useState(store.appStatusStore.tokenHolders ?? [])

    // Handle chanding holder details
    function handleHolderChange(i: number, event: any, field: boolean) {
        const values = [...tokenHolders];
        values[i][field ? 'address' : 'balance'] = event.target.value;
        setTokenHolders(values);
    }

    // Handle removing holders
    function handleRemoveHolder(i: number) {
        const values = [...tokenHolders];
        if (values.length === 1) {
            values[i] = { address: '', balance: '' };
        } else {
            values.splice(i, 1);
        }
        setTokenHolders(values);
    }
    // Handle page routing & storage of user input variables
    const router = useRouter()

    function handleSubmitButton() {
        store.appStatusStore.tokenName = tokenName
        store.appStatusStore.tokenSymbol = tokenSymbol
        store.appStatusStore.tokenHolders = tokenHolders
        router.push('/augmented-bonding-curve')
    }

    return (
        <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">

            <VStack spacing={4}>
                <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Configure template</Text>
                <Text fontSize="xl" as="b" p="1rem" textAlign="center">Choose your token settings below</Text>

                <HStack width="90%">
                    <FormControl width="70%">
                        <FormLabel>Token name</FormLabel>
                        <Input placeholder="My Organization Token" value={tokenName ?? ''} onChange={(e) => setTokenName(e.target.value)} />
                    </FormControl>
                    <FormControl width="30%">
                        <FormLabel>Token symbol</FormLabel>
                        <Input placeholder="MOT" value={tokenSymbol ?? ''} onChange={(e) => setTokenSymbol(e.target.value)} />
                    </FormControl>
                </HStack>

                <HStack width="90%">
                    <FormControl width="70%">
                        <FormLabel>Token holders</FormLabel>
                        {tokenHolders.map((holder, i) => (
                            <InputGroup key={i} p=".25rem">
                                <Input name="address" placeholder="Account address" value={holder.address ?? ''} onChange={event => handleHolderChange(i, event, true)} />
                                <InputRightAddon>
                                    <IconButton aria-label="Delete" icon={<CloseIcon />} onClick={() => handleRemoveHolder(i)} />
                                </InputRightAddon>

                            </InputGroup>
                        ))}
                    </FormControl>
                    <FormControl width="30%">
                        <FormLabel>Balances</FormLabel>
                        {tokenHolders.map((holder, i) => (
                            <InputGroup p=".25rem">
                                <Input key={i} name="balance" value={holder.balance ?? ''} onChange={event => handleHolderChange(i, event, false)} type="number" />
                            </InputGroup>

                        ))}
                    </FormControl>
                </HStack>

                <Button onClick={() => setTokenHolders([...tokenHolders, { address: '', balance: '' }])}>Add holder</Button>
                <HStack>
                    <Button alignSelf="flex-start" onClick={() => router.push('/template')} colorScheme="blue">Back</Button>
                    <Button alignSelf="flex-end" isDisabled={!tokenName || !tokenSymbol || tokenHolders.length == 1 && tokenHolders[0].address == '' || tokenHolders[0].balance == ''} onClick={handleSubmitButton} colorScheme="blue">Next</Button>
                </HStack>
            </VStack>
        </Box>
    )
}
