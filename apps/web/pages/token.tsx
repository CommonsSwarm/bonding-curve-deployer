import TokenHoldersComponent from "~/components/TokenHolderComponent";
import { Box, Center, Text } from "@chakra-ui/react";
import HeaderComponent from "~/components/Header";

export default function TokenPage() {
    return (
        <main>
            <HeaderComponent/>
            <Center height="80vh" width="100vw">
                <TokenHoldersComponent />
            </Center>
        </main>
    )
}