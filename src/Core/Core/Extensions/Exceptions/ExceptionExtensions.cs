using System;
using System.Text;
using GoldenEye.Core.IOC;
using GoldenEye.Core.Utils.Exceptions;

namespace GoldenEye.Core.Extensions.Exceptions
{
    public static class ExceptionExtensions
    {
        public static string FormatErrorMessage(this Exception exception)
        {
            var exceptionProvider = IOCContainer.Instance.Get<IExceptionProvider>();
            return exceptionProvider.HandleException(exception).Trim();
        }

        public static string FormatErrorMessage(this Exception exception, string header)
        {
            var message = new StringBuilder();

            message.AppendLine(header);
            message.AppendLine();
            message.Append(exception.FormatErrorMessage());

            return message.ToString();
        }
    }
}
