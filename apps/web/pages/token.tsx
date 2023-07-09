import TokenHoldersComponent from "~/components/TokenHolderComponent";
import { Box, Center, Text } from "@chakra-ui/react";

export default function TokenPage() {
    return (
        <main>
            <Center height="100vh" width="100vw">
                <TokenHoldersComponent />
            </Center>
        </main>
    )
}