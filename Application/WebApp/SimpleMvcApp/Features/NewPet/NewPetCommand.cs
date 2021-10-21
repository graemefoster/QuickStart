using System.ComponentModel.DataAnnotations;

namespace SimpleMvcApp.Features.NewPet
{
    public class NewPetCommand
    {
        [MinLength(3)]
        public string Name { get; set; }
    }
}