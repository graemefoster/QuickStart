import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import { PublicClientApplication } from "@azure/msal-browser";
import { MsalProvider } from "@azure/msal-react";
import reportWebVitals from "./reportWebVitals";
import { msalConfig } from "./authConfig";
import "bootstrap/dist/css/bootstrap.css";

/**
 * Initialize a PublicClientApplication instance which is provided to the MsalProvider component
 * We recommend initializing this outside of your root component to ensure it is not re-initialized on re-renders
 */
const msalInstance = new PublicClientApplication(msalConfig);

ReactDOM.render(
  <React.StrictMode>
    <MsalProvider instance={msalInstance}>
      <App />
    </MsalProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
