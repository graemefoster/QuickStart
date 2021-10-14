using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SimpleMvcApp.Features.NewPet;

namespace SimpleMvcApp.Features.ListPets
{
    [Route("/pets/list")]
    public class ListPetsController : Controller
    {
        private readonly ILogger<NewPetController> _logger;

        public ListPetsController(ILogger<NewPetController> logger)
        {
            _logger = logger;
        }

        [Route("")]
        public IActionResult Index()
        {
            return View();
        }
    }
}
