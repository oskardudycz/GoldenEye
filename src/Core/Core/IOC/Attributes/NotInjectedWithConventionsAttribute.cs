using System;

namespace GoldenEye.Core.IOC.Attributes
{
    [AttributeUsage(AttributeTargets.Class)]
    public class NotInjectedWithConventionsAttribute: Attribute
    {
    }
}
