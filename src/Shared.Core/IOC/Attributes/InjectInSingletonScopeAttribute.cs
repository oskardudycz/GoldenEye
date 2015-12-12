using System;

namespace GoldenEye.Shared.Core.IOC.Attributes
{
    [AttributeUsage(AttributeTargets.Class)]
    public class InjectInSingletonScopeAttribute : Attribute
    {
    }
}