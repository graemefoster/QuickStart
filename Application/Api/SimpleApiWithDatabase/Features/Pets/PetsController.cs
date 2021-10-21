using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SimpleApiWithDatabase.Domain;
using SimpleApiWithDatabase.Infrastructure;

namespace SimpleApiWithDatabase.Features.Pets
{
    [ApiController]
    [Route("[controller]")]
    public class PetsController : ControllerBase
    {
        private readonly ILogger<PetsController> _logger;
        private readonly PetsContext _petsContext;

        public PetsController(ILogger<PetsController> logger, PetsContext petsContext)
        {
            _logger = logger;
            _petsContext = petsContext;
        }

        [HttpGet]
        [Authorize(Roles = "reader,admin")]
        public Task<Pet[]> Get()
        {
            _logger.LogInformation("Fetching pets::");
            return _petsContext.Pets.ToArrayAsync();
        }

        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<IActionResult> Post(NewPet pet)
        {
            _logger.LogInformation("Adding new pet");
            await _petsContext.Pets.AddAsync(new Pet(Guid.NewGuid(), pet.Name));
            await _petsContext.SaveChangesAsync();
            return new OkResult();
        }
    }
}