using System.Data.Common;
using System.Threading;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace SimpleApiWithDatabase.Infrastructure
{
    public class GetAadTokenInterceptor : DbConnectionInterceptor
    {
        private readonly ILogger<GetAadTokenInterceptor> _logger;
        private readonly IOptions<ApiSettings> _settings;

        public GetAadTokenInterceptor(ILogger<GetAadTokenInterceptor> logger, IOptions<ApiSettings> settings)
        {
            _logger = logger;
            _settings = settings;
        }

        public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(DbConnection connection,
            ConnectionEventData eventData, InterceptionResult result,
            CancellationToken cancellationToken = new CancellationToken())
        {
            _logger.LogInformation("Fetching AAD Token");

            var cred = new DefaultAzureCredential(new DefaultAzureCredentialOptions()
            {
                ManagedIdentityClientId = _settings.Value.UserAssignedClientId
            });
            var token = await cred.GetTokenAsync(new TokenRequestContext(new[]
                { "https://database.windows.net/" }), cancellationToken);

            ((SqlConnection)connection).AccessToken = token.Token;

            _logger.LogInformation("Attached token to connection");
            return await base.ConnectionOpeningAsync(connection, eventData, result, cancellationToken);
        }

        public override InterceptionResult ConnectionOpening(DbConnection connection, ConnectionEventData eventData,
            InterceptionResult result)
        {
            _logger.LogInformation("Fetching AAD Token (sync)");

            var cred = new DefaultAzureCredential();
            var token = cred.GetToken(new TokenRequestContext(new[]
                { "https://database.windows.net/" }));
            ((SqlConnection)connection).AccessToken = token.Token;

            _logger.LogInformation("Attached token to connection");
            return base.ConnectionOpening(connection, eventData, result);
        }
    }
}