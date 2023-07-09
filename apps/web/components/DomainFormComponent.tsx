import { Box, Button, InputGroup, Input, InputRightAddon, Flex, Text, Alert, VStack, AlertIcon, HStack } from "@chakra-ui/react";
import { useState } from 'react'
import { store } from "../stores/store";
import { useRouter } from "next/router";

export default function DomainFormComponent() {

    const [domain, setDomain] = useState(store.appStatusStore.domain)

    const router = useRouter()

    function handleDomainChange(event: any) {
        setDomain(event.target.value)
    }

    function handleSubmitButton() {
        store.appStatusStore.domain = domain
        router.push('/template')
    }

    function handleBackButton() {
        router.push('/')
    }

    // If there is no domain, button should be disabled
    return (
        <main>
            <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">

                <VStack spacing={4}>
                    <Text fontSize="xl" as="b" p="1rem" textAlign="center">Claim a name</Text>
                    <InputGroup>
                        <Input placeholder="Type an organization name" value={domain ?? ''} onChange={handleDomainChange} />
                        <InputRightAddon children='.aragonid.eth' />
                    </InputGroup>
                    <Alert status="info" p="1rem">
                        <AlertIcon/>
                        <Text fontSize="xs" as="em">Aragon uses the Ethereum Name Service (ENS) to assign names to organizations. The name you choose will be mapped to your organization’s Ethereum address and cannot be changed after you launch your organization.
                        </Text>
                    </Alert>

                    
                    <HStack>
                    <Button alignSelf="flex-start" onClick={handleBackButton}>Back</Button>
                    <Button alignSelf="flex-end" isDisabled={domain?.trim() === ""} onClick={handleSubmitButton} colorScheme="blue">Next</Button>
                    </HStack>
                </VStack>
            </Box>
        </main>
    )
}