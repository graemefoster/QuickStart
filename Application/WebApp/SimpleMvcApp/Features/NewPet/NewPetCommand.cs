using System.ComponentModel.DataAnnotations;

namespace SimpleMvcApp.Features.NewPet
{
    public class NewPetCommand
    {
        [Required]
        [StringLength(100, MinimumLength = 3)]
        public string Name { get; set; }
    }
}