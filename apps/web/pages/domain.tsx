import DomainFormComponent from "~/components/DomainFormComponent"
import { Box, Center, Text } from "@chakra-ui/react";


export default function DomainPage() {
    return (
        <main>
            <Center height="100vh" width="100vw">
                <DomainFormComponent />
            </Center>
        </main>
    )
}