import { createContext, useContext } from "react"; 
 
import AppStatusStore from './appStatusStore'; 
 
interface Store {  
    appStatusStore : AppStatusStore, 
} 
 
export const store: Store = { 
    appStatusStore: new AppStatusStore(), 

} 
 
export const StoreContext = createContext(store) 
 
 
export function useStore() { 
    return useContext(StoreContext) 
}