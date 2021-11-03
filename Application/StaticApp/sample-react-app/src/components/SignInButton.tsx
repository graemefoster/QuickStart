import { useMsal } from "@azure/msal-react";
import { spaConfig } from "../authConfig";
import Button from "react-bootstrap/Button";

/**
 * Renders a drop down button with child buttons for logging in with a popup or redirect
 */
export const SignInButton = () => {
  const { instance } = useMsal();

  const handleLogin = () => {
    spaConfig.then((config) => {
      instance
        .loginRedirect({ scopes: config.apiConfig.Scopes })
        .catch((e) => {
          console.log(e);
        });
    });
  };
  return (
    <Button variant="primary" onClick={() => handleLogin()}>
      Sign In
    </Button>
  );
};
