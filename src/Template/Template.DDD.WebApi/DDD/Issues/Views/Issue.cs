using System;
using Backend.DDD.Sample.Contracts.Issues.Events;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Shared.Core.Objects.General;

namespace Backend.DDD.Sample.Contracts.Issues.Views
{
    public class Issue : IView<Guid>
    {
        public Guid Id { get; set; }

        public IssueType Type { get; private set; }

        public string Title { get; private set; }

        public string Description { get; private set; }

        object IHasId.Id => Id;

        public Issue()
        {
        }

        public void Apply(IssueCreated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }
    }
}