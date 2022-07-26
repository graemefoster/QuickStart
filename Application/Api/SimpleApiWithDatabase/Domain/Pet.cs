using System;
using System.ComponentModel.DataAnnotations;

namespace SimpleApiWithDatabase.Domain
{
    public class Pet
    {
        public Guid Id { get; set; }
        
        [MaxLength(100), Required]
        public string Name { get; set; }

        public PetType PetType { get; private set; }

        internal Pet(Guid id, string name, PetType petType)
        {
            Id = id;
            Name = name;
            PetType = petType;
        }
    }
}