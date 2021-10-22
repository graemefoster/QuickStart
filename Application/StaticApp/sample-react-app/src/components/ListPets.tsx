import { useMsal } from "@azure/msal-react";
import { msalConfig, loginRequest } from "../authConfig";
import React, { useState, useEffect } from "react";

interface Pet {
    name: string
}

export const ListPets = () => {
  const { instance, accounts } = useMsal();

  const [ petList, setPetList] = useState<Pet[]>([]);

  useEffect(() => {
    instance
      .acquireTokenSilent({
        ...loginRequest,
        account: accounts[0],
      })
      .then((response) => {
          console.log(response);
          setPetList([{name:'fluffy'}, {name: 'tiddles'}]);
      });
  });

  return <div>Listy Pets { petList.length }</div>;
};
