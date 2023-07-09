import { Box, Button, InputGroup, Input, InputRightAddon, Flex, Text, Alert, VStack, AlertIcon, HStack, IconButton, Stack } from "@chakra-ui/react";
import { useState } from 'react'
import {
    FormControl,
    FormLabel,
} from '@chakra-ui/react'
import { CloseIcon } from "@chakra-ui/icons";
import { useRouter } from "next/router";
import { store } from "~/stores/store";

export default function TokenHoldersComponent() {

    const [tokenName, setTokenName] = useState(store.appStatusStore.tokenName)
    const [tokenSymbol, setTokenSymbol] = useState(store.appStatusStore.tokenSymbol)
    const [tokenHolders, setTokenHolders] = useState(store.appStatusStore.tokenHolders)

    const router = useRouter()

    function handleTokenNameChange(event) {
        setTokenName(event.target.value)
    }

    function handleTokenSymbolChange(event) {
        setTokenSymbol(event.target.value)
    }

    function handleAddHolder() {
        setTokenHolders([...tokenHolders, { address: '', balance: '' }])
    }

    function handleHolderChange(i, event) {
        const values = [...tokenHolders];
        values[i][event.target.name] = event.target.value;
        setTokenHolders(values);
    }

    function handleRemoveHolder(i) {
        const values = [...tokenHolders];
        if (values.length === 1) {
            values[i] = { address: '', balance: '' };
        } else {
            values.splice(i, 1);
        }
        setTokenHolders(values);
    }

    function handleSubmitButton() {
        store.appStatusStore.tokenName = tokenName
        store.appStatusStore.tokenSymbol = tokenSymbol
        store.appStatusStore.tokenHolders = tokenHolders
        router.push('/augmented-bonding-curve')
    }

    function handleBackButton() {
        router.push('/template')
    }

    return (
        <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">

            <VStack spacing={4}>
                <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Configure template</Text>
                <Text fontSize="xl" as="b" p="1rem" textAlign="center">Choose your token settings below</Text>

                <HStack>
                    <FormControl width="70%">
                        <FormLabel>Token name</FormLabel>
                        <Input placeholder="My Organization Token" value={tokenName} onChange={handleTokenNameChange} />
                    </FormControl>
                    <FormControl width="30%">
                        <FormLabel>Token symbol</FormLabel>
                        <Input placeholder="MOT" value={tokenSymbol} onChange={handleTokenSymbolChange} />
                    </FormControl>
                </HStack>

                <HStack>
                    <FormControl width="70%">
                        <FormLabel>Token holders</FormLabel>
                        {tokenHolders.map((holder, i) => (
                            <InputGroup key={i} p=".25rem">
                                <Input name="address" placeholder="Account address" value={holder.address} onChange={event => handleHolderChange(i, event)} />
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
                                <Input key={i} name="balance" value={holder.balance} onChange={event => handleHolderChange(i, event)} type="number" />
                            </InputGroup>

                        ))}
                    </FormControl>
                </HStack>

                <Button onClick={handleAddHolder}>Add holder</Button>
                <HStack>
                    <Button alignSelf="flex-start" onClick={handleBackButton}>Back</Button>
                    <Button alignSelf="flex-end" onClick={handleSubmitButton}>Next</Button>
                </HStack>
            </VStack>
        </Box>
    )
}
