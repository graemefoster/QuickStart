/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */

import { Configuration, LogLevel } from "@azure/msal-browser";

type ApiConfig = {
  MicroServiceUrl: string;
  BaseUrl: string;
  Scopes: [string];
};

type SpaConfig = {
  msalConfig: Configuration;
  apiConfig: ApiConfig;
};

/**
 * Configuration object to be passed to MSAL instance on creation.
 * For a full list of MSAL.js configuration parameters, visit:
 * https://github.com/AzureAD/microsoft-authentication-library-for-js/blob/dev/lib/msal-browser/docs/configuration.md
 */
export const spaConfig: Promise<SpaConfig> = new Promise<SpaConfig>(
  (resolve, reject) => {
    fetch("/msalconfig.json").then((r) => {
      r.json().then((val) => {
        val.msalConfig.system = {
          loggerOptions: {
            loggerCallback: (
              level: LogLevel,
              message: string,
              containsPii: boolean
            ) => {
              if (containsPii) {
                return;
              }
              switch (level) {
                case LogLevel.Error:
                  console.error(message);
                  return;
                case LogLevel.Info:
                  console.info(message);
                  return;
                case LogLevel.Verbose:
                  console.debug(message);
                  return;
                case LogLevel.Warning:
                  console.warn(message);
                  return;
              }
            },
          },
        };
        resolve(val);
      });
    });
  }
);
