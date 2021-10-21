using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SimpleMvcApp.Services;

namespace SimpleMvcApp.Features.NewPet
{
    [Route("/pets/new")]
    public class NewPetController : Controller
    {
        private readonly ILogger<NewPetController> _logger;
        private readonly PetsClient _client;

        public NewPetController(ILogger<NewPetController> logger, PetsClient client)
        {
            _logger = logger;
            _client = client;
        }

        [Route("")]
        public IActionResult Index()
        {
            return View(new NewPetCommand());
        }

        [Route("")]
        [HttpPost]
        public async Task<IActionResult> New(NewPetCommand newPetCommand)
        {
            await _client.New(newPetCommand);
            return RedirectToAction("Index", "ListPets");
        }
    }
}
