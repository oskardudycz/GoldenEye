using Ardalis.GuardClauses;
using GoldenEye.Commands;

namespace Tickets.Maintenance.Commands
{
    public class RebuildProjection : ICommand
    {
        public string ViewName { get; }

        private RebuildProjection(string viewName)
        {
            ViewName = viewName;
        }


        public static RebuildProjection Create(string viewName)
        {
            Guard.Against.NullOrEmpty(viewName, nameof(viewName));

            return new RebuildProjection(viewName);
        }
    }
}
