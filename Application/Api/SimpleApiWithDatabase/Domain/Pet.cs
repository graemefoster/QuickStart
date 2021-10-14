using System;

namespace SimpleApiWithDatabase.Domain
{
    public class Pet
    {
        public Guid Id { get; set; }
        public string Name { get; set; }

        internal Pet(Guid id, string name)
        {
            Id = id;
            Name = name;
        }
    }
}