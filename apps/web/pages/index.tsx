import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";
import { Box, Button, Center, InputGroup, Input, InputRightAddon, VStack, Text, Alert, AlertIcon, HStack, Slider, SliderTrack, SliderFilledTrack, SliderThumb } from "@chakra-ui/react";
import { Account } from "~/components";
import { useRouter } from "next/router";



function Page() {
  const { isConnected } = useAccount();

  const router = useRouter()

  function handleStartButton() {
    router.push('/domain')
  }

  if(isConnected) {
    return (
      <>
      <main>
        <Center height="100vh" width="100vw">
          <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
            <h1>wagmi + RainbowKit + Next.js</h1>
            <ConnectButton/>
            <Button onClick={handleStartButton}>Start!</Button>
          </Box >
        </Center>
      </main>
    </>
    )
  }
  return (
    <>
      <main>
        <Center height="100vh" width="100vw">
          <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
            <h1>wagmi + RainbowKit + Next.js</h1>

            <ConnectButton />
            {isConnected && <Account /> }
          </Box >
        </Center>
      </main>
    </>
  );
}

export default Page;
