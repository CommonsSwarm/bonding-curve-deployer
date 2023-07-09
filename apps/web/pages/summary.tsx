import { Box, Center, Text } from "@chakra-ui/react";
import HeaderComponent from "../components/Header";
import SummaryComponent from "../components/SummaryComponent";

export default function SummaryPage() {
    return (
        <main>
            <HeaderComponent/>
            <Center height="80vh" width="100vw">
                <SummaryComponent />
            </Center>
        </main>
    )
}