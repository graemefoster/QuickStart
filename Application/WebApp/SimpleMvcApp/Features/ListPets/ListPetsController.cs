using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Identity.Web;
using SimpleMvcApp.Features.NewPet;
using SimpleMvcApp.Services;

namespace SimpleMvcApp.Features.ListPets
{
    [Route("/pets/list")]
    public class ListPetsController : Controller
    {
        private readonly ILogger<NewPetController> _logger;
        private readonly PetsClient _client;

        public ListPetsController(ILogger<NewPetController> logger, PetsClient client)
        {
            _logger = logger;
            _client = client;
        }

        [Route("")]
        public async Task<IActionResult> Index()
        {
            return View(new ListPetsViewModel {Pets = await _client.GetAll()});
        }
    }
}
