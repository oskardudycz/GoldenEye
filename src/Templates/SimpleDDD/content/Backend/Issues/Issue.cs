using System;
using GoldenEye.Aggregates;
using GoldenEye.Objects.General;
using GoldenEye.WebApi.Template.SimpleDDD.Contracts.Issues;

namespace GoldenEye.WebApi.Template.SimpleDDD.Backend.Issues
{
    public class Issue: Aggregate
    {
        public Issue(Guid id, IssueType type, string title, string description)
        {
            Id = id;
            Type = type;
            Title = title;
            Description = description;
        }

        public IssueType Type { get; private set; }

        public string Title { get; private set; }

        public string Description { get; private set; }

        public void Update(IssueType type, string title, string description)
        {
            Type = type;
            Title = title;
            Description = description;
        }
    }
}
