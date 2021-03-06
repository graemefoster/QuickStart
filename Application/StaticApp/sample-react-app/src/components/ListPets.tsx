import { useMsal } from "@azure/msal-react";
import { spaConfig } from "../authConfig";
import { MicroServiceCall } from "./MicroServiceCall";
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

      spaConfig.then(config => {
        instance
        .acquireTokenSilent({
          scopes: config.apiConfig.Scopes,
          account: accounts[0],
        })
        .then((response) => {
          return fetch(`${config.apiConfig.BaseUrl}pets`, {
            headers: {
              Authorization: `Bearer ${response.accessToken}`,
            },
          });
        })
        .then((r) => {
          r.json().then((o) => setPetList(o));
        });
      })
    }
  }, [fetchPets, instance, accounts]);

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
      <MicroServiceCall />
    </Container>
  );
};
