import DomainFormComponent from "../components/DomainFormComponent"
import { Center } from "@chakra-ui/react";
import HeaderComponent from "../components/HeaderComponent";

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