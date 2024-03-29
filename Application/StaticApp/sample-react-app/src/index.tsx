import React from "react";
import "./index.css";
import App from "./App";
import { PublicClientApplication } from "@azure/msal-browser";
import { MsalProvider } from "@azure/msal-react";
import reportWebVitals from "./reportWebVitals";
import { spaConfig } from "./authConfig";
import "bootstrap/dist/css/bootstrap.css";
import { createRoot } from 'react-dom/client';

/**
 * Initialize a PublicClientApplication instance which is provided to the MsalProvider component
 * We recommend initializing this outside of your root component to ensure it is not re-initialized on re-renders
 */
spaConfig.then((config) => {
  const msalInstance = new PublicClientApplication(config.msalConfig);
  const container = document.getElementById('root')!;
  const root = createRoot(container);

  root.render(
    <React.StrictMode>
      <MsalProvider instance={msalInstance}>
        <App />
      </MsalProvider>
    </React.StrictMode>);

  // If you want to start measuring performance in your app, pass a function
  // to log results (for example: reportWebVitals(console.log))
  // or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
  reportWebVitals();
});
