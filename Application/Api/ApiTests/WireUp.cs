using System;
using Shouldly;
using Xunit;

namespace ApiTests
{
    public class WireUp
    {
        [Fact]
        public void Test1Is1()
        {
            1.ShouldBe(1);
            
        }
    }
}