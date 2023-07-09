import { Box, Button, InputGroup, Input, InputRightAddon, VStack, Text, Alert, AlertIcon, HStack, Slider, SliderTrack, SliderFilledTrack, SliderThumb } from "@chakra-ui/react";
import { useState } from "react";
import {
    FormControl,
    FormLabel,
    FormErrorMessage,
    FormHelperText,
} from '@chakra-ui/react'
import { useRouter } from "next/router";
import { store } from "~/stores/store";

export default function ConfigureTemplateComponent() {

    const router = useRouter()

    const [support, setSupport] = useState(store.appStatusStore.support)
    const [minApproval, setMinApproval] = useState(store.appStatusStore.minApproval)
    const [days, setDays] = useState(store.appStatusStore.days)
    const [hours, setHours] = useState(store.appStatusStore.hours)
    const [minutes, setMinutes] = useState(store.appStatusStore.minutes)

    // Sliders
    function handleSupportChangeInput(event) {
        const value = parseInt(event.target.value, 10);
        if (!isNaN(value)) {
            setSupport(value)
        }
    }

    function handleSupportChangeSlider(value) {
        setSupport(value)
    }

    function handleApprovalChangeInput(event) {
        const value = parseInt(event.target.value, 10);
        if (!isNaN(value)) {
            setMinApproval(value)
        }
    }

    function handleApprovalChangeSlider(value) {
        setMinApproval(value)
    }

    // Time
    function handleDaysChange(event) {
        setDays(event.target.value)
    }

    function handleHoursChange(event) {
        setHours(event.target.value)
    }

    function handleMinutesChange(event) {
        setMinutes(event.target.value)
    }

    // Buttons
    function handleSubmitButton() {
        store.appStatusStore.support = support
        store.appStatusStore.minApproval = minApproval
        store.appStatusStore.days = days
        store.appStatusStore.hours = hours
        store.appStatusStore.minutes = minutes
        router.push('/token')
    }

    function handleBackButton() {
        router.push('/domain')
    }

    return (
        <Box borderWidth="1px" borderRadius="lg" padding="6" boxShadow="lg" width="50vw">
            
            <VStack spacing={4}>
                <Text fontSize="2xl" as="b" p="1rem" textAlign="center">Configure template</Text>
                <Text fontSize="xl" as="b" p="1rem" textAlign="center">Choose your voting settings below</Text>

                <FormControl>
                    <FormLabel>Support %</FormLabel>
                    <HStack justifyContent="space-between" width="100%">
                        <Slider
                            aria-label='slider-ex-1'
                            min={0}
                            max={100}
                            value={support}
                            onChange={handleSupportChangeSlider}
                            flexGrow={1}
                        >
                            <SliderTrack>
                                <SliderFilledTrack />
                            </SliderTrack>
                            <SliderThumb />
                        </Slider>
                        <InputGroup width="20%">
                            <Input value={support} onChange={handleSupportChangeInput} type="number" />
                            <InputRightAddon children="%" />
                        </InputGroup>
                    </HStack>
                </FormControl>

                <FormControl>
                    <FormLabel>Minimum approval %</FormLabel>
                    <HStack justifyContent="space-between" width="100%">
                        <Slider
                            aria-label='slider-ex-1'
                            min={0}
                            max={100}
                            value={minApproval}
                            onChange={handleApprovalChangeSlider}
                            flexGrow={1}
                        >
                            <SliderTrack>
                                <SliderFilledTrack />
                            </SliderTrack>
                            <SliderThumb />
                        </Slider>
                        <InputGroup width="20%">
                            <Input value={minApproval} onChange={handleApprovalChangeInput} type="number" />
                            <InputRightAddon children="%" />
                        </InputGroup>
                    </HStack>
                </FormControl>


                <Text fontSize="sm">Vote duration</Text>
                <HStack>
                    <InputGroup>
                        <Input value={days} onChange={handleDaysChange} type="number" />
                        <InputRightAddon children="Days" />
                    </InputGroup>
                    <InputGroup>
                        <Input value={hours} type="number" onChange={handleHoursChange} />
                        <InputRightAddon children="Hours" />
                    </InputGroup>
                    <InputGroup>
                        <Input value={minutes} type="number" onChange={handleMinutesChange} />
                        <InputRightAddon children="Minutes" />
                    </InputGroup>
                </HStack>
                <Alert status="info" p="1rem">
                    <AlertIcon />
                    <Text fontSize="xs" as="em">The support and minimum approval thresholds are strict requirements, such that votes will only pass if they achieve approval percentages greater than these thresholds.</Text>
                </Alert>
                <HStack>
                    <Button alignSelf="flex-start" onClick={handleBackButton}>Back</Button>
                    <Button alignSelf="flex-end" onClick={handleSubmitButton}>Next</Button>
                </HStack>

            </VStack>
        </Box>
    )
}
