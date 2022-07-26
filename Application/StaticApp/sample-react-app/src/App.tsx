import {
  AuthenticatedTemplate,
  UnauthenticatedTemplate
} from "@azure/msal-react";
import { SignInButton } from "./components/SignInButton";
import { Nav, Navbar, Container } from "react-bootstrap";
import { BrowserRouter as Router, Switch, Route, Link } from "react-router-dom";
import ListPets from "./components/ListPets"

function App() {
  
  return (
    <div className="App">
      <AuthenticatedTemplate>
        <Router>
          <Navbar bg="dark" expand="lg" variant="dark">
            <Container>
              <Navbar.Brand href="#home">QuickStart</Navbar.Brand>
              <Navbar.Toggle aria-controls="basic-navbar-nav" />
              <Navbar.Collapse id="basic-navbar-nav">
                <Nav className="me-auto">
                  <Nav.Link as={Link} to="/">
                    Home
                  </Nav.Link>
                  <Nav.Link as={Link} to="/list">
                    List Pets
                  </Nav.Link>
                  <Nav.Link as={Link} to="/new">
                    New Pet
                  </Nav.Link>
                </Nav>
              </Navbar.Collapse>
            </Container>
          </Navbar>
          <div>
            <Switch>
              <Route exact path="/">
                <h2>Welcome to Pet World!</h2>
              </Route>
              <Route path="/list">
                <ListPets />
              </Route>
              <Route path="/new">
                <h2>New pet</h2>
              </Route>
            </Switch>
          </div>
        </Router>
      </AuthenticatedTemplate>

      <UnauthenticatedTemplate>
        <Navbar bg="dark" expand="lg" variant="dark">
          <Container>
            <Navbar.Brand href="#home">QuickStart</Navbar.Brand>
            <Navbar.Toggle aria-controls="basic-navbar-nav" />
          </Container>
        </Navbar>
        <SignInButton />
      </UnauthenticatedTemplate>
    </div>
  );
}

export default App;
