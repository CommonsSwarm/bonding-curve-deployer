import AugmentedBondingCurveComponent from "../components/AugmentedBondingCurveComponent";
import { Box, Center, Text } from "@chakra-ui/react";
import HeaderComponent from "../components/HeaderComponent";


export default function AugmentedBondingCurvePage() {
    return (
        <main>
            <HeaderComponent/>
            <Center height="90vh" width="100vw">
                <AugmentedBondingCurveComponent />
            </Center>
        </main>
    )
}