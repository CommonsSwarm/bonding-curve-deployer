import { Box, Flex, Text, } from "@chakra-ui/react";
import { useRouter } from "next/router";
import { ConnectButton } from "@rainbow-me/rainbowkit";


export default function HeaderComponent() {
    // Handle page routing
    const router = useRouter();

    return (
        <Box bg="teal.400" w="100%" p={4} color="white" position="sticky" top="0" zIndex="1000">
            <Flex justify="space-between">
                <Flex align="center">
                    <Text fontSize="xl" mr={4} cursor="pointer" onClick={() => router.push("/")}>
                        ABC Deployer
                    </Text>
                </Flex>
                <Flex align="center">
                    <ConnectButton showBalance={false} />
                </Flex>
            </Flex>
        </Box>
    );
}