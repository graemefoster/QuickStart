using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace SimpleMvcApp.Features.NewPet
{
    [Route("/pets/new")]
    public class NewPetController : Controller
    {
        private readonly ILogger<NewPetController> _logger;

        public NewPetController(ILogger<NewPetController> logger)
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
