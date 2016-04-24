using System.Text;
using FluentValidation.Results;

namespace GoldenEye.Shared.Core.Extensions.Validation
{
    public static class ValidationResultExtensions
    {
        public static string FormatErrorMessages(this ValidationResult result)
        {
            if (result.IsValid)
            {
                return null;
            }

            var sb = new StringBuilder();

            foreach (var error in result.Errors)
            {
                sb.AppendFormat("{0}\r\n", error.ErrorMessage);
            }

            return sb.ToString();
        }
    }
}
