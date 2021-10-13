using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using SimpleApiWithDatabase.Domain;

namespace SimpleApiWithDatabase.Features.Pets
{
    [ApiController]
    [Route("[controller]")]
    public class PetsController : ControllerBase
    {
        [HttpGet]
        public IEnumerable<Pet> Get()
        {
            yield return new Pet(Guid.Empty, "Fluffy");
        }
    }
}
