import { useMsal } from "@azure/msal-react";
import { loginRequest } from "../authConfig";
import Button from 'react-bootstrap/Button';

/**
 * Renders a drop down button with child buttons for logging in with a popup or redirect
 */
export const SignInButton = () => {
    const { instance } = useMsal();

    const handleLogin = () => {
        instance.loginRedirect(loginRequest).catch(e => {
            console.log(e);
        });
    }
    return (
        <Button variant="primary" onClick={() => handleLogin()}>Sign In</Button>
    )
}