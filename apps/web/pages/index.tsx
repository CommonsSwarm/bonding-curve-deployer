import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { Box, Button, Center, InputGroup, Input, InputRightAddon, VStack, Text, Alert, AlertIcon, HStack, Slider, SliderTrack, SliderFilledTrack, SliderThumb } from "@chakra-ui/react";
import { Account } from "../components";
import { useRouter } from "next/router";
import HeaderComponent from "../components/Header";


function Page() {

  const router = useRouter()

  function handleStartButton() {
    router.push('/domain')
  }

    return (
      <>
      <main>
        <HeaderComponent/>
        <Center height="80vh" width="100vw">
          <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
            <VStack spacing={4}>
            <Text fontSize="2xl">Welcome to ABC Deployer!</Text>
            <Text fontSize="xl">Connect your wallet to start creating your DAO with Augmented Bonding Curve</Text>
            <ConnectButton/>
            <Button onClick={handleStartButton}>Start!</Button>
            </VStack>
          </Box >
        </Center>
      </main>
    </>
    )
  }

export default Page;
