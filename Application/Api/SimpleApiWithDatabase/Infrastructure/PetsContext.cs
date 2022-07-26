using Microsoft.EntityFrameworkCore;
using SimpleApiWithDatabase.Domain;

namespace SimpleApiWithDatabase.Infrastructure
{
    public class PetsContext : DbContext
    {
        public DbSet<Pet> Pets { get; set; }

        public PetsContext(DbContextOptions<PetsContext> options) : base(options)
        {
        }
    }
}