using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Identity.Web;
using SimpleMvcApp.Features.ListPets;
using SimpleMvcApp.Features.NewPet;
using SimpleMvcApp.Infrastructure;

namespace SimpleMvcApp.Services
{
    public class PetsClient
    {
        public readonly string ServiceName = nameof(PetsClient);

        private readonly HttpClient _client;
        private readonly ILogger<PetsClient> _logger;
        private readonly ITokenAcquisition _tokenAcquisition;
        private readonly IOptions<ApiSettings> _settings;

        public PetsClient(
            HttpClient client,
            ILogger<PetsClient> logger,
            ITokenAcquisition tokenAcquisition,
            IOptions<ApiSettings> settings)
        {
            _client = client;
            _logger = logger;
            _tokenAcquisition = tokenAcquisition;
            _settings = settings;
        }

        public async Task<ReferenceItem[]> GetAll()
        {
            _logger.LogDebug("Fetching all pets");
            var token = await _tokenAcquisition.GetAccessTokenForUserAsync(new[] { _settings.Value.Scope });
            var req = new HttpRequestMessage(HttpMethod.Get, "pets");
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            req.Headers.Add("Ocp-Apim-Subscription-Key", _settings.Value.SubscriptionKey);
            return await _client.SendAsync(req).AsJsonAsync<ReferenceItem[]>();
        }

        public async Task New(NewPetCommand newPetCommand)
        {
            _logger.LogDebug("Adding new pet");
            var token = await _tokenAcquisition.GetAccessTokenForUserAsync(new[] { _settings.Value.Scope });
            var req = new HttpRequestMessage(HttpMethod.Post, "pets");
            req.Content = new StringContent(JsonSerializer.Serialize(newPetCommand), Encoding.UTF8, "application/json");
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            req.Headers.Add("Ocp-Apim-Subscription-Key", _settings.Value.SubscriptionKey);
            await _client.SendAsync(req);
        }
    }
}