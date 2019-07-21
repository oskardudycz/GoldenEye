using System;

namespace GoldenEye.Shared.Core.IOC.Attributes
{
    [AttributeUsage(AttributeTargets.Class, Inherited = true)]
    public class NotInjectedWithConventionsAttribute: Attribute
    {
    }
}
