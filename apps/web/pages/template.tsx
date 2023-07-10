import { Center } from "@chakra-ui/react";
import ConfigureTemplateComponent from "../components/ConfigureTemplateComponent";
import HeaderComponent from "../components/HeaderComponent";

export default function ConfigureTemplatePage() {

    return (
        <main>
            <HeaderComponent />
            <Center height="80vh" width="100vw">
                <ConfigureTemplateComponent/>
            </Center>
        </main>
    )
}