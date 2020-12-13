using System;
using System.Collections.Generic;

namespace GoldenEye.Core.Utils.Exceptions
{
    public interface IExceptionProvider
    {
        IEnumerable<IExceptionHandler> ExceptionHandlers { get; }
        string HandleException(Exception e);
    }
}
