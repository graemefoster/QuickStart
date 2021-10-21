using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace SimpleMvcApp.Infrastructure
{
    public static class HttpClientEx
    {
        public static async Task<T> AsJsonAsync<T>(this Task<HttpResponseMessage> responseMessage)
        {
            var response = await responseMessage;
            response.EnsureSuccessStatusCode();
            return JsonSerializer.Deserialize<T>(await response.Content.ReadAsStringAsync());
        }
    }
}