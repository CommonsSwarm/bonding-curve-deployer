import "@rainbow-me/rainbowkit/styles.css";
import { RainbowKitProvider } from "@rainbow-me/rainbowkit";
import type { AppProps } from "next/app";
import NextHead from "next/head";
import * as React from "react";
import { WagmiConfig } from "wagmi";
import { ChakraProvider } from "@chakra-ui/react"
import { store, StoreContext } from "~/stores/store";



import { chains, client } from "../wagmi";

function App({ Component, pageProps }: AppProps) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);
  return (
    <WagmiConfig client={client}>
      <ChakraProvider>
        <StoreContext.Provider value={store}>
          <RainbowKitProvider chains={chains}>
            <NextHead>
              <title>My App</title>
            </NextHead>

            {mounted && <Component {...pageProps} />}
          </RainbowKitProvider>
        </StoreContext.Provider>
      </ChakraProvider>
    </WagmiConfig>
  );
}

export default App;
