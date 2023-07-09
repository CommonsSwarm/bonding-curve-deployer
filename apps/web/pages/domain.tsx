import DomainFormComponent from "../components/DomainFormComponent"
import { Box, Center, Text } from "@chakra-ui/react";
import HeaderComponent from "../components/Header";

export default function DomainPage() {
    return (
        <main>
            <HeaderComponent/>
            <Center height="80vh" width="100vw">
                <DomainFormComponent />
            </Center>
        </main>
    )
}