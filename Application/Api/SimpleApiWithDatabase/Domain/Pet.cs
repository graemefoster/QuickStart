using System;
using System.ComponentModel.DataAnnotations;

namespace SimpleApiWithDatabase.Domain
{
    public class Pet
    {
        public Guid Id { get; set; }
        
        [MaxLength(100), Required]
        public string Name { get; set; }

        internal Pet(Guid id, string name)
        {
            Id = id;
            Name = name;
        }
    }
}