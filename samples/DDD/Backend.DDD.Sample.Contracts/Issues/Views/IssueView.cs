using System;
using Backend.DDD.Sample.Contracts.Issues.Events;
using GoldenEye.DDD.Queries;
using GoldenEye.Core.Objects.General;

namespace Backend.DDD.Sample.Contracts.Issues.Views
{
    public class IssueView: IView<Guid>
    {
        public IssueType Type { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }
        public Guid Id { get; set; }

        object IHaveId.Id => Id;

        public void Apply(IssueCreated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }
    }
}
