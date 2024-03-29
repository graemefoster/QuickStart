// AppInsights.js
import { ApplicationInsights } from '@microsoft/applicationinsights-web';
import { ReactPlugin } from '@microsoft/applicationinsights-react-js';
import { createBrowserHistory } from 'history';
import { spaConfig } from "./authConfig";

const browserHistory = createBrowserHistory({ basename: '' });
const reactPlugin = new ReactPlugin();

const appinsightsPromise = spaConfig.then(config => {
    const appInsights = new ApplicationInsights({
        config: {
            instrumentationKey: config.apiConfig.AppInsightsKey,
            disableFetchTracking: false,
            enableCorsCorrelation: true,
            enableRequestHeaderTracking: true,
            enableResponseHeaderTracking: true,
                    extensions: [reactPlugin],
            extensionConfig: {
              [reactPlugin.identifier]: { history: browserHistory }
            }
        }
    });
    appInsights.loadAppInsights();

    return appInsights;
})

export { reactPlugin, appinsightsPromise };
