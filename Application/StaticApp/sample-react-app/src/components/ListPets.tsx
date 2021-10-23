import { useMsal } from "@azure/msal-react";
import { loginRequest, apiEndpoint } from "../authConfig";
import { useState, useEffect } from "react";
import { Container, Table } from "react-bootstrap";

type Pet = {
  id: string;
  name: string;
};

export const ListPets = () => {
  const { instance, accounts } = useMsal();
  const [fetchPets, setFetchPets] = useState<Boolean>(true);
  const [petList, setPetList] = useState<Pet[]>([]);

  useEffect(() => {
    if (fetchPets) {
      setFetchPets(false);
      instance
        .acquireTokenSilent({
          ...loginRequest,
          account: accounts[0],
        })
        .then((response) => {
          return fetch(`${apiEndpoint.petsApiEndpoint}pets`, {
            headers: {
              Authorization: `Bearer ${response.accessToken}`,
            },
          });
        })
        .then((r) => {
          r.json().then((o) => setPetList(o));
        });
    }
  });

  return (
    <Container>
      <h2>Pets</h2>
      <Table striped bordered>
        <thead>
          <tr>
            <th>Pet</th>
          </tr>
        </thead>
        <tbody>
          {petList.map((pet) => (
            <tr>
              <td key={pet.id}>{pet.name}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </Container>
  );
};
