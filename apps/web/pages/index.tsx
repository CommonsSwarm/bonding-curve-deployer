import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { Box, Button, Center, VStack, Text } from "@chakra-ui/react";
import { useRouter } from "next/router";
import HeaderComponent from "../components/HeaderComponent";

export default function IndexPage() {

  // Initialize useRouter
  const router = useRouter()

  // Verify if the user is connected to a wallet, to enable/disable start button)
  const { address } = useAccount()

  return (
    <>
      <main>
        <HeaderComponent />
        <Center height="80vh" width="100vw">
          <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
            <VStack spacing={4}>
              <Text fontSize="2xl">Welcome to ABC Deployer!</Text>
              <Text fontSize="xl">Connect your wallet to start creating your DAO with Augmented Bonding Curve</Text>
              <ConnectButton />
              <Button onClick={() => router.push('/organization')} isDisabled={!address}>Start!</Button>
            </VStack>
          </Box >
        </Center>
      </main>
    </>
  )
}