using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.Razor;

namespace SimpleMvcApp
{
    public class FeatureLocationExpander : IViewLocationExpander
    {
        public void PopulateValues(ViewLocationExpanderContext context)
        {
            // Don't need anything here, but required by the interface
        }
        
        public IEnumerable<string> ExpandViewLocations(ViewLocationExpanderContext context, IEnumerable<string> viewLocations)
        {
            return new[] {"/Features/{1}/{0}.cshtml", "/Features/Shared/{0}.cshtml"};
        }
    }
}