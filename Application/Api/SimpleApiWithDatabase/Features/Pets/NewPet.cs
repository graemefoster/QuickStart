using System.ComponentModel.DataAnnotations;
using SimpleApiWithDatabase.Domain;

namespace SimpleApiWithDatabase.Features.Pets
{
    public class NewPet
    {
        [Required]
        [StringLength(100, MinimumLength = 3)] 
        public string Name { get; set; }
        
        public PetType? Type { get; set; }
    }
}