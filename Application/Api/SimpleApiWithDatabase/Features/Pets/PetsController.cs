using System;
using System.Collections.Generic;
using System.Threading.Tasks;
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
        public Task<Pet[]> Get()
        {
            _logger.LogInformation("Fetching pets::");
            return _petsContext.Pets.ToArrayAsync();
        }
    }
}
