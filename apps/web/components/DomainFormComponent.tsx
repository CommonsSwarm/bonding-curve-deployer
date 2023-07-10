import { Box, Button, InputGroup, Input, InputRightAddon, Text, Alert, VStack, AlertIcon, HStack } from "@chakra-ui/react";
import { useState } from 'react'
import { store } from "../stores/store";
import { useRouter } from "next/router";

export default function OrganizationComponent() {

    // Handle domain name 
    const [organization, setOrganization] = useState(store.appStatusStore.organization)

    function handleDomainChange(event: any) {
        setOrganization(event.target.value)
    }

    // Handle page routing & storage of user input variables
    const router = useRouter()

    function handleNextButton() {
        store.appStatusStore.organization = organization
        router.push('/template')
    }

    return (
        <main>
            <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
                <VStack spacing={4}>
                    <Text fontSize="xl" as="b" p="1rem" textAlign="center">Claim a name</Text>
                    <InputGroup>
                        <Input placeholder="Type an organization name" value={organization ?? ''} onChange={handleDomainChange} />
                        <InputRightAddon children='.aragonid.eth' />
                    </InputGroup>
                    <Alert status="info" p="1rem">
                        <AlertIcon/>
                        <Text fontSize="xs" as="em">Aragon uses the Ethereum Name Service (ENS) to assign names to organizations. The name you choose will be mapped to your organization’s Ethereum address and cannot be changed after you launch your organization.
                        </Text>
                    </Alert>
                    <HStack>
                    <Button alignSelf="flex-start" onClick={() => router.push('/')} colorScheme="blue">Back</Button>
                    <Button alignSelf="flex-end" isDisabled={!organization} onClick={handleNextButton} colorScheme="blue">Next</Button>
                    </HStack>
                </VStack>
            </Box>
        </main>
    )
}