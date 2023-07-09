export default class AppStatusStore { 
    domain: string|null = null;
    support: number|null = 50;
    minApproval: number|null = 15;
    days: number|null = 1;
    hours: number|null = 0;
    minutes: number|null = 0;
    tokenName: string|null = null;
    tokenSymbol: string|null = null;
    tokenHolders: Array<{ address: string | null; balance: number | null; }> | null = [{ address: null, balance: null }];
    reserveRatio: number|null = 0;
    collateralToken: { address: string | null; symbol: string | null; } | null = { address: "0x4f4F9b8D5B4d0Dc10506e5551B0513B61fD59e75", symbol: "GIV" };
    initialReserve: number|null = 0;
    entryTribute: number|null = 0;
    exitTribute: number|null = 0;
}