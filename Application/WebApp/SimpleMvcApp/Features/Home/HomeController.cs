using Microsoft.AspNetCore.Mvc;

namespace SimpleMvcApp.Features.Home
{
    public class HomeController : Controller
    {
        // GET
        public IActionResult Home()
        {
            return RedirectToAction("Index", "ListPets");
        }

        public IActionResult Error()
        {
            return View();
        }
    }
}