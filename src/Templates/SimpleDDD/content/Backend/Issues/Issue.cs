using System;
using GoldenEye.DDD.Aggregates;
using GoldenEye.Core.Objects.General;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues;

namespace GoldenEye.WebApi.Template.SimpleDDD.Backend.Issues
{
    public class Issue: IAggregate
    {
        public Issue()
        {
        }

        public Issue(Guid id, IssueType type, string title, string description)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
        }

        public IssueType Type { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }
        object IHaveId.Id => Id;

        public Guid Id { get; set; }

        public void Update(IssueType type, string title, string description)
        {
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
