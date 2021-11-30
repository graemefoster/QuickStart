import { spaConfig } from "../authConfig";
import { useState, useEffect } from "react";
import { Container } from "react-bootstrap";

type Resource = {
  name: string;
  pets: [];
};

export const MicroServiceCall = () => {
  const [fetchResource, setFetchResource] = useState<Boolean>(true);
  const [resource, setResource] = useState<Resource>();

  useEffect(() => {
    if (fetchResource) {
      setFetchResource(false);

      spaConfig
        .then((config) => fetch(`${config.apiConfig.MicroServiceUrl}resource`, {
          headers: {
            'Ocp-Apim-Subscription-Key' : config.apiConfig.SubscriptionKey
          }
        }))
        .then((r) => r.json())
        .then((o) => setResource(o));
    }
  }, [fetchResource]);

  return (
    <Container>
      <h2>Resource</h2>
      <p>{resource?.name ?? 'Loading'}</p>
    </Container>
  );
};
