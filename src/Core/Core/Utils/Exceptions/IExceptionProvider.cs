using System;
using System.Collections.Generic;

namespace GoldenEye.Shared.Core.Utils.Exceptions
{
    public interface IExceptionProvider
    {
        IEnumerable<IExceptionHandler> ExceptionHandlers { get; }
        string HandleException(Exception e);
    }
}
