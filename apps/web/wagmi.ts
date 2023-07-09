import { getDefaultWallets } from "@rainbow-me/rainbowkit";
import { configureChains, createClient, Chain, Client } from "wagmi";
import { gnosis } from "wagmi/chains";
import { publicProvider } from "wagmi/providers/public";

const { chains, provider, webSocketProvider } = configureChains(
  [gnosis],
  [publicProvider()]
) as { chains: Chain[], provider: any, webSocketProvider: any };

const { connectors } = getDefaultWallets({
  appName: "My wagmi + RainbowKit App",
  chains,
});

export const client: Client = createClient({
  autoConnect: true,
  connectors,
  provider,
  webSocketProvider,
});

export { chains };
