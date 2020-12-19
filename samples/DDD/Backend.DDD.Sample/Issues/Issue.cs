using System;
using Backend.DDD.Sample.Contracts.Issues;
using GoldenEye.Entities;
using GoldenEye.Objects.General;

namespace Backend.DDD.Sample.Issues
{
    public class Issue: Entity
    {
        public Issue()
        {
        }

        public Issue(Guid id, IssueType type, string title)
        {
            Id = id;
            Type = type;
            Title = title;
        }

        public IssueType Type { get; set; }

        public string Title { get; set;  }

        public string Description { get; set; }
    }
}
