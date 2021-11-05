import { spaConfig } from "../authConfig";
import { useState, useEffect } from "react";
import { Container } from "react-bootstrap";

type Pet = {
  id: string;
  name: string;
};

export const MicroServiceCall = () => {
  const [fetchResource, setFetchResource] = useState<Boolean>(true);
  const [resource, setResource] = useState<Pet[]>([]);

  useEffect(() => {
    if (fetchResource) {
      setFetchResource(false);

      spaConfig
        .then((config) => fetch(`${config.apiConfig.BaseUrl}resource`))
        .then((r) => r.json())
        .then((o) => setResource(o));
    }
  }, [fetchResource]);

  return (
    <Container>
      <h2>Resource</h2>
      <p>{resource}</p>
    </Container>
  );
};
