import { spaConfig } from "../authConfig";
import { useState, useEffect } from "react";
import { Container } from "react-bootstrap";
import { withAITracking } from '@microsoft/applicationinsights-react-js';
import { reactPlugin } from '../appInsights';

type Resource = {
  name: string;
  pets: [];
};

const MicroServiceCall = () => {
  const [fetchResource, setFetchResource] = useState<Boolean>(true);
  const [resource, setResource] = useState<Resource>();

  useEffect(() => {
    if (fetchResource) {
      setFetchResource(false);

      spaConfig
        .then((config) => fetch(`${config.apiConfig.MicroServiceUrl}resource`))
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

export default withAITracking(reactPlugin, MicroServiceCall)
