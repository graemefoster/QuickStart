using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace SimpleMvcApp.Features.NewPet
{
    public class NewPetController : Controller
    {
        private readonly ILogger<NewPetController> _logger;

        public NewPetController(ILogger<NewPetController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
