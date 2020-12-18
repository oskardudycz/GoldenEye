using System;
using GoldenEye.Queries;
using GoldenEye.Objects.General;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Events;

namespace GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues.Views
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

        public void Apply(IssueUpdated @event)
        {
            Id = @event.IssueId;
            Type = @event.Type;
            Title = @event.Title;
            Description = @event.Description;
        }
    }
}
